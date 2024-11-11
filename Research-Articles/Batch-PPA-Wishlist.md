# Batch PPA Wishlist features

## Current Functionality

### Sending in Preparation messages pain001, pain013, pacs008
### Allow Quoting while sending Preparation message pacs008
### Sending pacs008 for Tazama Fraud Evaluation

### Additional Functionality

#### 1. **Batch Identity**
   - **Goal**: Assign a unique identifier to each batch for tracking purposes, allowing for the monitoring of active batches and facilitating post-evaluation analysis.
   - **Implementation**: 
     - Add a `batch_id` field to each transaction. Track the batch's status (e.g., `processing`, `completed`, `failed`).
     - Provide an endpoint to retrieve active batches and their associated `batch_id` values.

#### 2. **Multiple Transactions Per Batch**
   - **Goal**: Allow multiple transactions per batch to increase processing efficiency.
   - **Implementation**:
     - Modify the current batch structure to accept and process multiple transactions simultaneously.
     - Update processing components to handle bulk transactions in batches, especially for `pacs002`, which would require transactional integrity and efficient message parsing.

#### 3. **Multiple Batches Handling**
   - **Goal**: Allow concurrent batch processing, so one batch doesn’t block the initiation or processing of another.
   - **Implementation**:
     - Implement queuing mechanisms to manage batch concurrency without blocking.
     - Use unique `batch_id` tracking to separate processing across multiple threads or processes.

#### 4. **Batch Reporting**
   - **Goal**: Access real-time or post-processing reports for specific batches.
   - **Implementation**:
     - Create an endpoint or an asynchronous notification service (e.g., WebSocket) to provide live reporting on a batch's status.
     - For post-processing reports, generate summary files or JSON outputs that can be downloaded or viewed through an API.

#### 5. **Shifting Batch Preparation Messages Creation Time**
   - **Goal**: Enable time-shifting of preparation messages’ creation dates to align with the sending time of `pacs008` messages.
   - **Implementation**:
     - Add a function to update the `creation_time` of preparation messages within a specific batch without affecting unrelated transactions.
     - Set conditions to ensure time shifts apply only to selected batches.

---

### Failure Support Functionality

#### 1. **Mechanism for Resending Failed Transactions**
   - **Goal**: Enable failed transactions to be retried without duplicating records.
   - **Implementation**:
     - Track the status of each transaction and store retry attempts.
     - Introduce a retry mechanism with status checks to prevent resending of successfully completed transactions.

#### 2. **Verification of Reports**
   - **Goal**: Confirm the accuracy of reports for each batch.
   - **Implementation**:
     - Use validation checks after report generation, comparing expected transaction outcomes with actual results.
     - Log any discrepancies and offer error reporting.

#### 3. **Retry of Missed Transactions**
   - **Goal**: Ensure missed transactions are retried without creating duplicates.
   - **Implementation**:
     - Build a deduplication mechanism that checks existing records before retrying any missed transactions.
     - Provide a unique identifier for each transaction and validate before insertion.

---

These enhancements will likely require database schema modifications, queuing and concurrency controls, and robust logging to support reporting, debugging, and monitoring across batches and transactions.
