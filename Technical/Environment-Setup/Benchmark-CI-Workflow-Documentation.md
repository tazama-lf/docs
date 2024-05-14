# Benchmark CI Workflow Documentation

## Overview

The "Benchmark CI" workflow is designed to automate benchmarking tasks and update a main repository ('performance-benchmark') with data from a processor repository. This GitHub Actions workflow is triggered on pushes to the 'main' branch of the processor repository.

## Workflow Structure

### Environment Variables

- **GITHUB_TOKEN:** GitHub token used for authentication.
- **REPO_NAME:** Static name of the main repository ('performance-benchmark').
- **PROCCESSOR_REPO_NAME:** Dynamic variable based on the repository name from the push event.

### Trigger

The workflow is triggered on a push event to the 'main' branch of the processor repository.

### Jobs

#### 1. `bench`

- **Runs on:** Ubuntu latest.
- **Steps:**

1. **Clone repo:**
   - Clones the 'performance-benchmark' repository.  
   - Configures local user information for the GitHub Action.  
2. **Switch to temp branch:**
    - Switches to a temporary branch ('temp-holder').
    - Pulls the latest changes from the temp-holder.
    - Appends data from the processor repository's CSV file to a temporary file.
    - Stashes changes and switches back to the main branch.
3. **Write data:**
   - Modifies the main CSV file by adding a new line.
   - Appends data from the temporary file to the main CSV file.
   - Resets changes to the temporary file.
   - Adds and commits the updated CSV file with a commit message indicating the push event number and the updated processor repository.
4. **Push data:**
    - Pushes the committed changes to the main branch of the 'performance-benchmark' repository.

## How to Use

1. Ensure that the necessary environment variables are set in the GitHub repository secrets.
   - GITHUB_TOKEN: Obtain a personal access token with the required permissions.
   - REPO_NAME: Set to 'performance-benchmark'.
   - PROCCESSOR_REPO_NAME: Automatically set based on the push event.
2. Trigger the workflow by pushing changes to the 'main' branch of the processor repository.
3. The workflow will clone the 'performance-benchmark' repository, update the data, and push the changes back to the main branch.

## Notes

- The workflow utilizes a temporary branch ('temp-holder') to manage changes to the CSV file.
- The commit message includes the push event number and the name of the updated processor repository.

* * *
