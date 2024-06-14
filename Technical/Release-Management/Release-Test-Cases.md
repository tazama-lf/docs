# Release Test Cases

- [Release Test Cases](#release-test-cases)
  - [Test Cases for Jenkins Job and Milestone Workflow:](#test-cases-for-jenkins-job-and-milestone-workflow)
    - [Test Case 1: Successful Execution of Jenkins Job and Milestone Workflow](#test-case-1-successful-execution-of-jenkins-job-and-milestone-workflow)
    - [Test Case 2: Milestone ID Validation](#test-case-2-milestone-id-validation)
    - [Test Case 3: Release Workflow Triggered by Milestone Workflow](#test-case-3-release-workflow-triggered-by-milestone-workflow)
    - [Test Case 4: Release Creation Validation](#test-case-4-release-creation-validation)

## Test Cases for Jenkins Job and Milestone Workflow:

### Test Case 1: Successful Execution of Jenkins Job and Milestone Workflow

1. **Description:** Verify that the Jenkins job successfully triggers the milestone workflow and the milestone workflow executes without errors.

2. **Test Steps:**

- Execute the Jenkins job manually or wait for it to be triggered automatically.
- Monitor the console output of the Jenkins job for any errors or failures.
- Verify that the milestone workflow is triggered in the GitHub repository.
- Verify that the milestone workflow completes without errors.

3. **Expected Result:** The Jenkins job and milestone workflow execute successfully without any errors or failures.

### Test Case 2: Milestone ID Validation

1. **Description:** Validate that the Jenkins job correctly uses the provided milestone ID to trigger the milestone workflow.
2. **Test Steps:**

   - Execute the Jenkins job with a known milestone ID.
   - Verify that the milestone workflow is triggered in the GitHub repository.
   - Verify that the milestone ID used in the milestone workflow matches the provided ID.

3. **Expected Result:** The milestone workflow is triggered with the correct milestone ID.

### Test Case 3: Release Workflow Triggered by Milestone Workflow

1. **Description:** Verify that the milestone workflow successfully triggers the release workflow upon completion.

2. **Test Steps:**

   - Execute the Jenkins job to trigger the milestone workflow.
   - Monitor the console output of the Jenkins job for the completion of the milestone workflow.
   - Verify that the release workflow is triggered in the GitHub repository.
   - Verify that the release workflow completes without errors.

3. **Expected Result:** The milestone workflow triggers the release workflow, and the release workflow executes without any errors.

### Test Case 4: Release Creation Validation

1. **Description:** Validate that the release workflow creates a release in the GitHub repository.
2. **Test Steps:**

   - Execute the Jenkins job to trigger the milestone workflow.
   - Monitor the console output of the Jenkins job for the completion of the release workflow.
   - Verify that a new release is created in the GitHub repository.
   - Verify that the release contains the expected version and release notes.

3. **Expected Result:** The release workflow creates a new release with the correct version and release notes in the GitHub repository.
