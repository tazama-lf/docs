<!-- SPDX-License-Identifier: Apache-2.0 -->

# Performance Run Analytics on a Jupyter Notebook

## Motivation:

Currently, our processors have a `prcgTm` field which is attached to each message that that particular processor receives. This field represents the time that was recorded by the processor handling that particular message. That’s one of the tools we can use to have an overall idea of where we are spending a lot of time in the platform.  

Naturally, we may want to compare how the different times stack up against each other.

## Workflow:

Do a performance run (`n` number of transactions are sent through the platform).

1. Get the respective times for each processor in the run and display how they compare:

    - For all transactions, total up the processors' `prcgTm`

    ![](../../images/image-20231002-142838.png)

2. Generate a frequency distribution diagram for the current run showing how many transactions performed better than the average value (of that run)

    ![](../../images/image-20231002-143655.png)

3. Show different percentile values for each different processor:

    ![](../../images/image-20231002-144324.png)
4. Show percentiles for the different rules

    - So we can easily pinpoint which rule is the slowest

    ![](../../images/image-20231002-144546.png)

5. Write the dataset to persistent storage, recording the `min`, `max` and `average` for each processor in the run so it can be used for comparison against future runs.

6. Select the last best `n` runs in terms of transaction average in the run (`run duration` / `number of transactions in the run`)

    1. Then compare the different processors `min` `max` and `average` values
