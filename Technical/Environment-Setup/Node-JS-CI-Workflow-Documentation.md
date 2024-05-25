# Node JS CI Workflow Documentation

## Overview

Node JS CI workflow intends to make integration testing automatically available across the platform, this means the projects are securely guarded by making sure that the services can provide the objectives, and incoming code changes do not break any objective intended for the projects in addition, Node JS CI workflow adds a convenient way for developers to make sure that every change is in the best interest of the projects in terms of performance, code formatting style, objectives.

### Workflow Trigger

The workflow is triggered whenever there is a push to the `main` branch or a pull request is opened or updated against the `main` branch. This ensures that the CI process runs for changes to the main branch.

### 2. Job: `build`

This job runs on an Ubuntu-latest machine and utilizes a matrix strategy to test the Node.js application with different versions of Node.js and Redis. The matrix allows testing across multiple configurations.

### 3. Job Steps

#### 3.1 to 3.7: Setup Databases and Services

The workflow starts by setting up various databases and services required for the Node.js application. These include ArangoDB, Nats, Redis, and Nats-Rest Proxy.

#### 3.8 to 3.13: Setup Node.js Environment and Run Tests

The Node.js environment is set up, including installing dependencies and running tests using Newman. Newman is used for testing APIs, and the test results are collected for further analysis.

#### 3.14 to 3.22: Build and Test Node.js Application

The Node.js application is built, and the built artifacts are started for testing. Newman is then used to run tests on the deployed Node.js application. The results are stored in a file called `fullReport.json`.

#### 3.23 to 3.27: Extract and Output Test Results

Specific fields, such as response average, minimum, maximum, and standard deviation, are extracted from the Newman test report. These values are then set as output variables for later use.

#### 3.28: Upload Results

The full test report (`fullReport.json`) is uploaded as an artifact. This allows for easy access to the detailed test results.

### 4. Output Job: `output`

This job runs after the `build` and `pastbench` jobs and depends on its completion. It extracts the output variables (test results) and posts a comment on the pull request with the key test metrics. This provides a quick overview of the test results directly in the pull request conversation.

Example of output:

![cicd_nodejs_ci_output_job.png](/../../images/cicd-nodejs-ci-output-job.png)

### 5. Store Job

On this job, there is only one step for storing the current data of the benchmark on the temporal branch the data gets appended to the main branch only when the pull request is merged to the main branch. This job is dependent on an integration test job, which means this job cannot run if the job it depends on has not run successfully, Store job does not run when the PR is merged to make sure that the same data is stored twice

to read about how data get moved from the temporal branch to the main branch here is the link: [Benchmark CI Workflow Documentation](Benchmark-CI-Workflow-Documentation.md)

### 6. Pastbench

The purpose of this job is to retrieve historical benchmark data from the 'performance-benchmark' repository and subsequently utilize it for comparison with the current benchmark results. Triggered independently upon each push to the 'main' branch, the job involves cloning the benchmark repository and extracting the processor's CSV file from past runs. Subsequently, a dependent job, named 'Output,' is responsible for checking out the current repository, retrieving and processing the present benchmark data, and finally comparing it with the historical data. It is crucial to note that this workflow ensures the availability of past benchmark data specifically for comparison and is not activated when a pull request is merged into the 'main' branch, as the historical data is only relevant during the pull request stage and becomes obsolete after the merge.

### 7. Error cases

During each step execution, an error can be thrown, which will result in the workflow returning the error state which should prevent the merge of the code, some of the considerable cases could be an error with the new postman collection update from the postman repository or one of the services not starting successfully this can probably be solved by re-running the workflow

## The Flow of the Node Ci workflow

![flow_of_the_node_Ci_workflow](/../../images/flow_of_the_node_Ci_workflow.png)

### 8. Summary

The workflow is designed to ensure a clean installation, testing, and reporting process for a Node.js application. It leverages GitHub Actions to automate the CI/CD pipeline, providing insights into the performance and behavior of the application with each push or pull request to the main branch.

The link: [raw.githubusercontent.com/frmscoe/transaction-aggregation-decisioning-processor/main/.github/workflows/node.js.yml](https://raw.githubusercontent.com/frmscoe/transaction-aggregation-decisioning-processor/main/.github/workflows/node.js.yml)
