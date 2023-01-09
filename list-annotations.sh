#!/bin/bash

# add your personal access token as a secret named GITHUB_PAT
GITHUB_PAT="${{ secrets.GITHUB_PAT }}"

# Replace REPO_ID with the ID of the repository you want to fetch the workflow runs for
REPO_ID="REPO_ID"

# Set the URL for the List repository workflow runs API
RUNS_URL="https://api.github.com/repositories/${REPO_ID}/actions/runs"

# Set the maximum number of workflow runs per page (max is 100)
RUNS_PER_PAGE=100

# Set the initial page number
PAGE_NUM=1

# Set a flag to indicate whether there are more pages of workflow runs
MORE_PAGES=true

while [ "$MORE_PAGES" = true ]
do
  # Fetch the current page of workflow runs
  RUNS_RESPONSE=$(curl -X GET -H "Authorization: Bearer ${GITHUB_PAT}" "${RUNS_URL}?per_page=${RUNS_PER_PAGE}&page=${PAGE_NUM}")

  # Parse the workflow runs from the response
  WORKFLOW_RUNS=$(echo "$RUNS_RESPONSE" | jq -r '.workflow_runs | .[]')

  # Iterate over the workflow runs
  for RUN in $WORKFLOW_RUNS
  do
    # Extract the ID of the workflow run
    RUN_ID=$(echo "$RUN" | jq -r '.id')

    # Set the URL for the List workflow run jobs API
    JOBS_URL="https://api.github.com/repositories/${REPO_ID}/actions/runs/${RUN_ID}/jobs"

    # Set the maximum number of jobs per page (max is 100)
    JOBS_PER_PAGE=100

    # Set the initial page number
    JOBS_PAGE_NUM=1

    # Set a flag to indicate whether there are more pages of jobs
    JOBS_MORE_PAGES=true

    while [ "$JOBS_MORE_PAGES" = true ]
    do
      # Fetch the current page of jobs
      JOBS_RESPONSE=$(curl -X GET -H "Authorization: Bearer ${GITHUB_PAT}" "${JOBS_URL}?per_page=${JOBS_PER_PAGE}&page=${JOBS_PAGE_NUM}")

      # Parse the jobs from the response
      JOBS=$(echo "$JOBS_RESPONSE" | jq -r '.jobs | .[]')

      # Iterate over the jobs
      for JOB in $JOBS
      do
        # Extract the check run URL of the job
        CHECK_RUN_URL=$(echo "$JOB" | jq -r '.check_run_url')

        # Fetch the annotations for the check run
        ANNOTATIONS_RESPONSE=$(curl -X GET -H "Authorization: Bearer ${GITHUB_PAT}" "${CHECK_RUN_URL}/annotations")

