# Performance Benchmarking of ArangoDB: Single Instance vs. Split Databases vs. Clustering

<span style="font-size: 34px;">**Table of Contents**</span>
- [Summary](#summary)
- [Introduction](#introduction)
  - [Background](#background)
  - [Objective](#objective)
  - [Scope](#scope)
- [Cost Analysis](#cost-analysis)
  - [Objective](#objective-1)
  - [Scope](#scope-1)
  - [Cost Components Considered](#cost-components-considered)
  - [Cost Breakdown for Each Configuration](#cost-breakdown-for-each-configuration)
    - [Single Instance](#single-instance)
    - [2 Split Databases](#2-split-databases)
    - [4 Split Databases](#4-split-databases)
    - [Clustering](#clustering)
- [Methodology](#methodology)
  - [Configuration Details](#configuration-details)
  - [Benchmarking Criteria](#benchmarking-criteria)
- [Results and Analysis](#results-and-analysis)
  - [Performance Metrics](#performance-metrics)
    - [Single Instance](#single-instance-1)
    - [2 Split Databases](#2-split-databases-1)
    - [4 Split Databases](#4-split-databases-1)
    - [Clustering](#clustering-1)
  - [Analysis](#analysis)
  - [JSON End-to-End Times](#json-end-to-end-times)
- [Next Steps](#next-steps)
- [Screenshots](#screenshots)
  - [Single Instance](#single-instance-2)
  - [2 Split Databases](#2-split-databases-2)
  - [4 Split Databases](#4-split-databases-2)
  - [Clustering](#clustering-2)


<span style="font-size: 34px;">**Summary**</span>

This report presents a comprehensive performance benchmarking analysis of ArangoDB deployed in three distinct configurations on Azure: <span style="color:red;">**a Single Instance, Split Databases, and Clustering.**</span>  The aim was to include the best performing configurations and the most cost-efficient setups. It will highlight the FTPS value as a critical performance metric and its impact on choosing the right configuration for deployment.

**Note** The Arangodb Clustering is only available for a licensed deployment of ArangoDB.

The highest **FTPS** that was reached was <span style="color:green; font-size: 16px;">****2496.83****</span> using the **4 SplitDB** approach of Arango.

**2 SplitDB:** <span style="color:green; font-size: 16px;">****2304.5****</span> **FTPS**

**Standalone** (Single Instance)**:** <span style="color:green; font-size: 16px;">****2240****</span> **FTPS**

**Cluster:** <span style="color:green; font-size: 16px;">****264.5****</span> **FTPS**


****2 SplitDB explanation:****
![arangodb-benchmarking-split2](../../images/arangodb-benchmarking-split2.png)

During the performance benchmarking of ArangoDB, the utilization of a split database approach was used to optimize the FTPS. This configuration involved two main ArangoDB instances.

In the first instance, **Arango 1**, the split of data across distinct databases for specific purposes: **Pseudonyms**, **NetworkMap** for network configurations,  **TransactionHistory** to keep a record of transaction histories and the **Configuration** database stores rules and settings.

In the second instance, **Arango 2**, the **EvaluationResults** database was dedicated to storing the outcomes of transaction evaluations. This separation facilitated focused performance testing, allowing for precise measurement of the system’s response to distinct data management tasks within a multi-model database environment when reading and writing the data.

****4 SplitDB explaination:****

![arangodb-benchmarking-split4](../../images/arangodb-benchmarking-split4.png)


**Arango 1 - Configuration/NetworkMap Database**

The first instance, **Arango 1**, is responsible for storing configuration-related data. It contains the following databases and collections:

**Configuration**
- `transaction`
- `typologyExpression`
- `channelExpression`
- `configuration`

These collections are used for storing and retrieving configuration settings that dictate transaction processing and management rules.

**NetworkMap**

- `networkConfiguration`

This collection is crucial for maintaining the structural data of the network configurations.

**Arango 2 - Pseudonyms Database**

**Arango 2** focuses on pseudonymity and identity management within the system. The collections housed here are:

- `pseudonyms`
- `accounts`
- `account_holder`
- `entities`
- `transactionRelationship`

This instance is integral for privacy and identity management, ensuring that user data is mapped and managed securely.

**Arango 3 - Transaction History Database**

The **Arango 3** instance is tailored for transaction history storage. It includes:

- `transactionHistoryPacs002`
- `transactionHistoryPacs008`
- `transactionHistoryPain001`
- `transactionHistoryPain013`
- `list`
- `watchlist`

This instance serves as a historical data store, capturing all transaction details for auditing and reporting purposes.

**Arango 4 - Evaluation Results Database**

Lastly, **Arango 4** is dedicated to storing evaluation results in the `transactions` collection. It holds the output of transaction evaluations, serving as a data store for post-transaction analysis.

****The benchmarking includes:****
- Defining key performance indicators (KPIs) such as transactions per second (FTPS), latency, and resource utilization.
- Establishing a consistent test environment across all configurations to ensure comparability of results.
- Implementing repeatable test cases that simulate real-world usage scenarios to accurately measure database performance under each configuration.
- Utilizing Azure's native monitoring tools along with third-party benchmarking suites for a comprehensive performance assessment.
- Conducting multiple test iterations to account for variability and ensure statistical significance.

*****
<span style="font-size: 34px;">**Introduction**</span>

<span style="color:green; font-size: 24px;">****Background****</span>

ArangoDB is a multi-model database that supports graph, document, and key/value data models, making it a versatile choice for a wide range of applications. In our organization, ArangoDB has been pivotal in driving the efficiency of our data-driven applications, offering the flexibility to accommodate diverse data types and complex relationships within a single, unified platform.

<span style="color:green; font-size: 24px;">****Objective****</span>

The purpose of this benchmarking exercise was to evaluate the performance and scalability of ArangoDB under four different configurations: a Single Instance, 2 Split Databases, 4 Split Databases, and Clustering. This analysis aims to identify the optimal deployment strategy that balances performance with cost, scalability, and reliability for our specific use cases.

<span style="color:green; font-size: 24px;">****Scope****</span>

The benchmarking focused on testing a variety of operations including read, write, and mixed workloads. By understanding the performance of each configuration under these operations, we can make informed decisions on the appropriate architecture for different application requirements.

********

<span style="font-size: 34px;">**Cost Analysis**</span>

<span style="color:green; font-size: 24px;">****Objective****</span>

This cost analysis aims to provide a comprehensive understanding of the financial implications associated with deploying ArangoDB in three different configurations on Azure: Single Instance, Split Databases, and Clustering. By evaluating both performance and cost-efficiency, we aim to identify the most economically viable configuration for various use cases within our organization.

<span style="color:green; font-size: 24px;">****Scope****</span>

The analysis surrounding the costs related to running ArangoDB on Azure, including expenses for compute resources, storage, networking, and any additional services


<span style="color:green; font-size: 24px;">****Cost Components Considered****</span>

- **Compute (Virtual Machines):** Costs associated with Azure VM instances.
- **Storage:** Costs for disk storage.

<span style="color:green; font-size: 24px;">****Cost Breakdown for Each Configuration****</span>

- <span style="color:olive; font-size: 18px;">****Single Instance****</span>

| Processor/Service Deployment                        | Node Spec | Node Count |
|-----------------------------------------------------|-----------|------------|
| Processors                                          | D32as_v5  | 20         |
| Redis                                               | D32as_v5  | 3          |
| NATS                                                | D32as_v5  | 3          |
| ArangoDB                                            | D96s_v5   | 1          |
| CoreDNS/ Kubernetes                                 | D4s_v4    | 4          |

| Category         | Type                         | Number of nodes  | Month-to-Month | 3-Year Reserved |
|------------------|------------------------------|------------------|----------------|-----------------|
| Virtual Machines | D32as_V5 (32 vcpu 128 gbs RAM| 26               | $33 708.48     | $12 809.41      |
| Virtual Machines | D4s_v4 (4 vcpu 16 gbs RAM    | 4                | $648.24        | $243.79         |
| Virtual Machines | D96s_v5 (96 vcpu 384 gbs RAM | 1                | $4590.24       | $1744.28        |
| Storage         | Managed Disks (Premium SSD v2)| 1                | $46.36         | $46.36          |
| **Total**        |                              |                |  **$38 993.32**  |    **$14 843.84**  |

![arangodb-benchmarking-disk-price1](../../images/arangodb-benchmarking-disk-price1.png)
   
- <span style="color:maroon; font-size: 18px;">****2 Split Databases****</span>

| Processor/Service Deployment                        | Node Spec | Node Count |
|-----------------------------------------------------|-----------|------------|
| Processors                                          | D32as_v5  | 25         |
| Redis                                               | D32as_v5  | 3          |
| NATS                                                | D32as_v5  | 6          |
| ArangoDB                                            | D96s_v5   | 2          |
| CoreDNS/ Kubernetes                                 | D4s_v4    | 4          |

| Category         | Type                         | Number of nodes  | Month-to-Month | 3-Year Reserved |
|------------------|------------------------------|------------------|----------------|-----------------|
| Virtual Machines | D32as_V5 (32 vcpu 128 gbs RAM| 34               | $44 080.32     | $16 750.77      |
| Virtual Machines | D4s_v4 (4 vcpu 16 gbs RAM    | 4                | $648.24        | $243.79         |
| Virtual Machines | D96s_v5 (96 vcpu 384 gbs RAM | 2                | $9180.48       | $3488.55        |
| Storage         | Managed Disks (Premium SSD v2)| 2                | $92.71         | $92.71          |
| **Total**        |                              |                  |  **$54 001.75**  |    **$20 575.82**  |

![arangodb-benchmarking-disk-price2](../../images/arangodb-benchmarking-disk-price2.png)

- <span style="color:orange; font-size: 18px;">****4 Split Databases****</span>

| Processor/Service Deployment                        | Node Spec | Node Count |
|-----------------------------------------------------|-----------|------------|
| Processors                                          | F32s_v2   | 30         |
| Redis                                               | F32s_v2   | 3          |
| NATS                                                | F32s_v2   | 3          |
| ArangoDB (Config)                                   | F32s_v2   | 1          |
| ArangoDB (History / Pseudonym and EvalResults)      | D96s_v5   | 3          |
| CoreDNS/ Kubernetes                                 | D4s_v3    | 4          |

| Category         | Type                         | Number of nodes  | Month-to-Month | 3-Year Reserved |
|------------------|------------------------------|------------------|----------------|-----------------|
| Virtual Machines | F32s_v2 (32 vcpu 64 gbs RAM  | 37               | $43 648.16     | $13 393.99      |
| Virtual Machines | D4s_v3 (4 vcpu 16 gbs RAM    | 4                | $648.24        | $243.79         |
| Virtual Machines | D96s_v5 (96 vcpu 384 gbs RAM | 3                | $11 668.32     | $4317.26        |
| Storage         | Managed Disks (Premium SSD v2)| 2                | $46.36         | $46.36          |
| Storage         | Managed Disks (Ultra Disk)    | 3                | $801.71        | $801.71         |
| **Total**        |                              |                  |  **$56 812.80**  |    **$18 803.11**  |

- <span style="color:navy; font-size: 18px;">****Clustering****</span>

| Processor/Service Deployment                        | Node Spec | Node Count |
|-----------------------------------------------------|-----------|------------|
| Transaction Monitoring Service (TMS)                | D32as_v5  | 4          |
| Channel Router Setup Processor (CRSP)               | D32as_v5  | 4          |
| Typology Processor (TP)                             | D32as_v5  | 4          |
| Transaction Aggregation Decisioning Processor (TADP)| D32as_v5  | 4          |
| Rule processors                                     | D32as_v5  | 4          |
| Redis                                               | D32as_v5  | 3          |
| NATS                                                | D32as_v5  | 3          |
| Arango Coordinator                                  | D32as_v5  | 3          |
| Arango Agents                                       | D32as_v5  | 3          |
| Arango DB server                                    | D96s_v5   | 4          |


| Category         | Type                         | Number of nodes  | Month-to-Month | 3-Year Reserved |
|------------------|------------------------------|------------------|----------------|-----------------|
| Virtual Machines | D32as_V5 (32 vcpu 128 gbs RAM| 32               | $41 487.36     | $15 765.43      |
| Virtual Machines | D4s_v4 (4 vcpu 16 gbs RAM    | 4                | $648.24        | $243.79         |
| Virtual Machines | D96s_v5 (96 vcpu 384 gbs RAM | 4                | $18 360.96     | $6977.11        |
| Storage         | Managed Disks (Ultra Disk)    | 4                | $1068.94       | $1068.94        |
| **Total**        |                              |                  |  **$61 565.5**  |    **$24 055.27**  |

![arangodb-benchmarking-disk-price3](../../images/arangodb-benchmarking-disk-price3.png)

*****

<span style="font-size: 34px;">**Methodology**</span>

The benchmarking methodology was formulated to ensure a fair and precise comparison across the different configurations. With utilizing Jmeter as a benchmarking tool to generate messages sent throught to the TMS API to reflect real-world use cases. The methodology also accounted for the setup and removing any data related to a previous tests, ensuring that each test was conducted in a clean-state environment.

<span style="color:green; font-size: 24px;">****Configuration Details****</span>

The configuration details for the Kubernetes cluster hosting the ArangoDB instances were as follows:

- ****Single Instance Pod Allocation:**** Aimed at applications with moderate traffic, ensuring minimal resource allocation for cost savings.
- ****Split Databases Pod Allocation:**** Targeted at balancing load across instances, ideal for read-heavy applications requiring higher availability.
- ****Clustering Pod Allocation:**** Designed for maximum performance and fault tolerance, suitable for write-heavy workloads and applications demanding high availability.

Each pod configuration was meticulously planned to align resource allocation with expected load, ensuring each pod type (TMS, CRSP, TP, TADP, Rules, Redis, Nats, Arango) was optimized for the specific demands of the deployment.


<span style="color:olive; font-size: 18px;">****Single Instance Pod Allocation****</span>
| TMS | CRSP | TP | TADP | Rules | Redis | Nats | Arango |
|-----|------|----|------|-------|-------|------|--------|
| 80  | 155  | 440| 385  |   15  |  60   |  12  |   1    |


<span style="color:maroon; font-size: 18px;">****2 Split Databases Pod Allocation****</span>
| TMS | CRSP | TP | TADP | Rules | Redis | Nats | Arango |
|-----|------|----|------|-------|-------|------|--------|
| 200 | 190  | 500| 460  |    20 |   60  |  18  |   2    |

<span style="color:orange; font-size: 18px;">****4 Split Databases Pod Allocation****</span>
| TMS | CRSP | TP | TADP | Rules | Redis | Nats | Arango |
|-----|------|----|------|-------|-------|------|--------|
| 100 | 150  | 400| 400  |    16 |   60  |  12  |   4    |

<span style="color:navy; font-size: 18px;">****Clustering Pod Allocation****</span>
| TMS | CRSP | TP | TADP | Rules | Redis | Nats | Arango |
|-----|------|----|------|-------|-------|------|--------|
| 100 | 150  | 400| 400  |   15  |  60   |  12  |   12   |


<span style="color:green; font-size: 24px;">****Benchmarking Criteria****</span>

The criteria for the benchmarks included several key performance indicators:

- ****Throughput:**** Measured in transactions per second (FTPS), to determine the raw processing power of each configuration.
- ****Latency:**** The time taken for a single transaction to be processed, indicating responsiveness.
- ****Concurrency:**** The ability to handle multiple simultaneous operations, which reflects on the robustness of the system under peak loads.
- ****Resource Utilization:**** Monitoring of CPU, memory, and I/O usage to assess the efficiency of the configuration.
- ****Stability:**** Monitored the consistency of performance over extended periods.
- ****Scalability:**** Evaluated the ease and impact of scaling each configuration on performance.


*****

<span style="font-size: 34px;">**Results and Analysis**</span>

<span style="color:green; font-size: 24px;">****Performance Metrics****</span>

**Processor Table Explanation:** 
- **mn:** Minimum processing time for the processor.
- **mx:** Maximum processing time for the processor.
- **ave:** Average response time for the processor, indicating overall performance efficiency.
- **mean:** Mean processing time for the processor.
- **ninety:** 90th percentile of processing time for the processor.
- **ninety-nine:** 99th percentile of processing time for the processor.
- **TMS, CRSP, TP, TADP:** Different processors.

**Typology Table Explanation:** 
- **Typology ID:** Identifier for each typology.
- **mn:** Minimum processing time for the typology.
- **mx:** Maximum processing time for the typology.
- **ave:** Average processing time, useful for understanding overall typology performance.

**Rule Table Explanation:** 
- **Rule ID:** Identifier for each rule.
- **mn:** Minimum execution time for the rule.
- **mx:** Maximum execution time for the rule.
- **ave:** Average execution time for the rule, helping identify efficiency and potential bottlenecks in a rule.

<span style="color:olive; font-size: 18px;">****Single Instance****</span>

****Jmeter ingestion rate:**** 2859 MPS

****Total messages**** 168 000

****FTPS:**** 2240

<span style="color:blue;">**Processors**</span>


| Results    | TMS       | CRSP       | TP         | TADP      |
|------------|-----------|------------|------------|-----------|
| mn         | 3.064528  | 0.0793     | 0.044      | 1.079506  |
| mx         | 454.65403 | 1081.280548| 4.181393   | 14.106027 |
| ave        | 23.14637  | 0.19622855 | 0.33655242 | 3.6996955 |
| mean       | 17.910068 | 0.139      | 0.321499   | 4.3133815 |
| ninety     | 37.057844 | 0.212601   | 0.541701   | 5.635591  |
| ninety-nine| 68.164748 | 0.291901   | 0.900599   | 6.441988  |

<span style="color:blue;">**Rules**</span>

| Rule ID    | mn       | mx          | ave         |
|------------|----------|-------------|-------------|
| 001@1.0.0  | 1.113302 | 1077.96542  | 6.120189498 |
| 002@1.0.0  | 0.725699 | 1077.004096 | 5.895627134 |
| 003@1.0.0  | 1.108798 | 1088.811725 | 6.129941848 |
| 004@1.0.0  | 1.063909 | 1082.020102 | 6.097922832 |
| 006@1.0.0  | 0.8134   | 1067.232368 | 5.990952735 |
| 007@1.0.0  | 0.721097 | 1080.692918 | 5.910856622 |
| 008@1.0.0  | 0.760997 | 1088.025851 | 5.951014326 |
| 010@1.0.0  | 0.739799 | 1072.31674  | 5.937875009 |
| 011@1.0.0  | 0.779906 | 1036.949571 | 5.909404689 |
| 016@1.0.0  | 0.677206 | 1081.916948 | 5.888669653 |
| 017@1.0.0  | 0.773099 | 1078.981549 | 5.870956482 |
| 018@1.0.0  | 0.8535   | 290.056776  | 6.023577596 |
| 020@1.0.0  | 0.874799 | 1077.3577   | 6.016764928 |
| 021@1.0.0  | 0.876203 | 1086.230327 | 6.03004266  |
| 024@1.0.0  | 1.086795 | 1068.43552  | 6.092602155 |
| 025@1.0.0  | 0.926799 | 1081.769341 | 6.055373837 |
| 026@1.0.0  | 1.1591   | 289.111856  | 6.144004829 |
| 027@1.0.0  | 0.947296 | 1074.914651 | 6.034760396 |
| 030@1.0.0  | 0.7495   | 1086.258279 | 5.880513724 |
| 044@1.0.0  | 0.646405 | 1056.480635 | 5.89352992  |
| 045@1.0.0  | 0.749406 | 1086.22068  | 5.885170113 |
| 048@1.0.0  | 0.862896 | 1096.811963 | 6.019056448 |
| 054@1.0.0  | 0.842896 | 1073.326955 | 6.008695988 |
| 063@1.0.0  | 0.860796 | 1080.558745 | 5.974419518 |
| 076@1.0.0  | 0.724596 | 1066.238811 | 5.899825062 |
| 083@1.0.0  | 0.658999 | 1078.322306 | 5.844439689 |
| 084@1.0.0  | 0.700498 | 1086.041934 | 5.871424179 |
| 090@1.0.0  | 1.217299 | 1079.610022 | 6.229023929 |
| 091@1.0.0  | 0.714199 | 1073.19271  | 5.838245966 |

<span style="color:blue;">**Typologies**</span>

| Typology ID | mn       | mx        | ave       |
|-------------|----------|-----------|-----------|
| 000@1.0.0   | 0.158701 | 2.466020  | 0.288668  |
| 028@1.0.0   | 0.079700 | 2.964291  | 0.160390  |
| 037@1.0.0   | 0.073400 | 4.181393  | 0.158434  |
| 044@1.0.0   | 0.067400 | 3.937698  | 0.149746  |
| 047@1.0.0   | 0.056201 | 2.684114  | 0.128343  |
| 095@1.0.0   | 0.044000 | 4.145997  | 0.107915  |
| 185@1.0.0   | 0.045100 | 2.265298  | 0.100534  |


<span style="color:maroon; font-size: 18px;">****2 Split Databases****</span>

****Jmeter ingestion rate:**** 2731.7 MPS

****Total transactions**** 210 000

****FTPS:**** 2304.5

<span style="color:blue;">**Processors**</span>

| Results     | TMS        | CRSP       | TP          | TADP       |
|-------------|------------|------------|-------------|------------|
| mn          | 4.005121   | 0.0816     | 0.045       | 1.102403   |
| mx          | 1381.084974| 36.496003  | 110.286111  | 141.520514 |
| ave         | 18.385852 **( - 4.76)**  | 0.167768 **( - 0.03)**  | 0.722904 **( + 0.39)**   | 2.893244 **( - 0.81)**  |
| mean        | 10.211779  | 0.1407     | 0.3942005   | 1.904989   |
| ninety      | 27.628587  | 0.227099   | 1.052695    | 3.219406   |
| ninety-nine | 238.041629 | 0.372901   | 6.447483    | 22.967093  |



<span style="color:blue;">**Rules**</span>

| Rule ID   | mn       | mx         | ave      |
|-----------|----------|------------|----------|
| 001@1.0.0 | 0.364900 | 90.689206  | 8.029009 |
| 002@1.0.0 | 0.453499 | 124.144644 | 7.799126 |
| 003@1.0.0 | 0.362105 | 103.066451 | 8.028117 |
| 004@1.0.0 | 0.348802 | 112.311267 | 8.000257 |
| 006@1.0.0 | 0.475602 | 87.301762  | 7.926438 |
| 007@1.0.0 | 0.420099 | 102.175491 | 7.820823 |
| 008@1.0.0 | 0.487103 | 99.338016  | 7.824589 |
| 010@1.0.0 | 0.511601 | 90.160395  | 7.827316 |
| 011@1.0.0 | 0.364398 | 89.293083  | 7.829234 |
| 016@1.0.0 | 0.357401 | 106.103893 | 7.798360 |
| 017@1.0.0 | 0.380902 | 143.433357 | 7.802874 |
| 018@1.0.0 | 0.315001 | 82.471641  | 7.949069 |
| 020@1.0.0 | 0.417101 | 81.713837  | 7.927967 |
| 021@1.0.0 | 0.397101 | 123.341554 | 7.929615 |
| 024@1.0.0 | 0.517802 | 127.300566 | 8.006649 |
| 025@1.0.0 | 0.416704 | 98.192060  | 7.946224 |
| 026@1.0.0 | 0.861398 | 100.090159 | 8.050497 |
| 027@1.0.0 | 0.394402 | 124.468013 | 7.945226 |
| 030@1.0.0 | 0.746798 | 88.444151  | 7.810905 |
| 044@1.0.0 | 0.379603 | 119.946893 | 7.782911 |
| 045@1.0.0 | 0.372702 | 124.402356 | 7.784252 |
| 048@1.0.0 | 0.550003 | 97.333589  | 7.910835 |
| 054@1.0.0 | 0.378301 | 92.189809  | 7.888777 |
| 063@1.0.0 | 0.377203 | 90.599108  | 7.897787 |
| 076@1.0.0 | 0.343598 | 85.630458  | 7.818762 |
| 083@1.0.0 | 0.450699 | 97.241607  | 7.767084 |
| 084@1.0.0 | 0.450005 | 90.279298  | 7.774046 |
| 090@1.0.0 | 0.513398 | 87.407738  | 8.110916 |
| 091@1.0.0 | 1.037015 | 111.627498 | 7.787655 |

<span style="color:blue;">**Typologies**</span>

| Typology ID | mn       | mx         | ave      |
|-------------|----------|------------|----------|
| 000@1.0.0   | 0.161001 | 69.364884  | 0.314190 |
| 028@1.0.0   | 0.077601 | 110.286111 | 0.184849 |
| 037@1.0.0   | 0.072700 | 62.399059  | 0.179058 |
| 044@1.0.0   | 0.067600 | 42.221434  | 0.171269 |
| 047@1.0.0   | 0.057300 | 56.685083  | 0.151608 |
| 095@1.0.0   | 0.045000 | 36.492085  | 0.129223 |
| 185@1.0.0   | 0.045500 | 60.330876  | 0.119353 |

<span style="color:orange; font-size: 18px;">****4 Split Databases****</span>

****Jmeter ingestion rate:**** 3525.23 MPS

****Total transactions**** 210 000

****FTPS:**** 2496.83

<span style="color:blue;">**Processors**</span>

| Results     | TMS        | CRSP       | TP          | TADP       |
|-------------|------------|------------|-------------|------------|
| mn          | 2.472165   | 0.066502   | 0.058101    | 1.307124   |
| mx          | 1384.909064| 28.868027  | 1424.011354 | 578.523762 |
| ave         | 12.650283 **( - 10.50)** | 0.129437 **( - 0.07)**  | 0.994189 **( + 0.66)**   | 4.289472 **( + 0.59)**  |
| mean        | 8.0592315  | 0.1097025  | 0.326906   | 2.1575375  |
| ninety      | 18.816924  | 0.159903   | 2.262551   | 5.894816   |
| ninety-nine | 56.299422  | 0.262403   | 12.509207  | 39.106534  |

<span style="color:blue;">**Rules**</span>

| Rule ID    | mn       | mx          | ave      |
|------------|----------|-------------|----------|
| 001@1.0.0  | 0.285404 | 48.507559   | 5.641019 |
| 003@1.0.0  | 0.461703 | 1047.250824 | 5.662649 |
| 004@1.0.0  | 0.464005 | 1050.889407 | 5.668137 |
| 006@1.0.0  | 0.348706 | 1444.151114 | 5.464872 |
| 007@1.0.0  | 0.462911 | 1042.167066 | 5.355661 |
| 008@1.0.0  | 0.663108 | 47.359632   | 5.342817 |
| 010@1.0.0  | 0.651109 | 1043.065197 | 5.365784 |
| 011@1.0.0  | 0.491506 | 46.341512   | 5.365501 |
| 016@1.0.0  | 0.347908 | 1040.274874 | 5.331757 |
| 017@1.0.0  | 0.355808 | 47.928598   | 5.339621 |
| 018@1.0.0  | 0.352409 | 1445.053024 | 5.491575 |
| 020@1.0.0  | 0.484412 | 1443.411684 | 5.484118 |
| 021@1.0.0  | 0.495808 | 47.291114   | 5.480013 |
| 024@1.0.0  | 0.670317 | 1450.582894 | 5.437627 |
| 026@1.0.0  | 0.547011 | 52.046978   | 5.446453 |
| 030@1.0.0  | 0.478806 | 46.524069   | 5.331704 |
| 044@1.0.0  | 0.561813 | 46.727582   | 5.330345 |
| 045@1.0.0  | 0.407705 | 1446.019938 | 5.295632 |
| 048@1.0.0  | 0.647011 | 1442.796469 | 5.453452 |
| 063@1.0.0  | 0.579109 | 1444.119047 | 5.392714 |
| 076@1.0.0  | 0.380909 | 47.289631   | 5.338894 |
| 083@1.0.0  | 0.422310 | 1437.688890 | 5.298740 |
| 084@1.0.0  | 0.564714 | 47.443165   | 5.319797 |

<span style="color:blue;">**Typologies**</span>

| Typology ID | mn       | mx          | ave      |
|-------------|----------|-------------|----------|
| 028@1.0.0   | 0.111903 | 137.458595  | 0.236355 |
| 037@1.0.0   | 0.099302 | 145.159369  | 0.227551 |
| 044@1.0.0   | 0.093403 | 60.321459   | 0.232938 |
| 047@1.0.0   | 0.074102 | 1424.011354 | 0.201989 |
| 095@1.0.0   | 0.058101 | 166.151141  | 0.160237 |
| 185@1.0.0   | 0.066001 | 179.999053  | 0.176558 |

<span style="color:navy; font-size: 18px;">****Clustering****</span>

****Jmeter ingestion rate:**** 2557.36 MPS

****Total transactions**** 105 000

****FTPS:**** 264.5

<span style="color:blue;">**Processors**</span>

| Results     | TMS         | CRSP       | TP          | TADP       |
|-------------|-------------|------------|-------------|------------|
| mn          | 7.525951    | 0.052402   | 0.041901    | 0.898524   |
| mx          | 922.721903  | 75.595687  | 3.698223    | 19.255050  |
| ave         | 42.663585 **( + 19.52)**   | 0.120988 **( - 0.08)**  | 0.184822 **( - 0.15)**   | 1.582370 **( - 2.12)**  |
| mean        | 35.107836   | 0.092802   | 0.174003    | 1.424517   |
| ninety      | 59.306448   | 0.135903   | 0.272412    | 1.981621   |
| ninety-nine | 201.375115  | 0.190901   | 0.459916    | 4.650432   |

<span style="color:blue;">**Rules**</span>

| Rule ID   | mn       | mx         | ave      |
|-----------|----------|------------|----------|
| 001@1.0.0 | 21.392369| 776.231998 | 31.329460|
| 003@1.0.0 | 21.440985| 778.777175 | 32.344057|
| 004@1.0.0 | 21.152663| 767.317377 | 31.306244|
| 006@1.0.0 | 10.151482| 2030.684397| 32.329461|
| 007@1.0.0 | 3.453696 | 636.700504 | 12.457783|
| 008@1.0.0 | 3.267281 | 635.356175 | 12.557751|
| 010@1.0.0 | 3.352423 | 637.366123 | 13.002234|
| 011@1.0.0 | 3.250219 | 635.340887 | 11.702650|
| 016@1.0.0 | 3.240390 | 634.069046 | 12.183998|
| 017@1.0.0 | 3.402584 | 638.599880 | 12.676839|
| 018@1.0.0 | 14.578591| 753.388747 | 24.876592|
| 020@1.0.0 | 10.044415| 2025.032002| 32.132250|
| 021@1.0.0 | 10.007269| 2034.604899| 32.422788|
| 024@1.0.0 | 3.667936 | 4293.391405| 35.916917|
| 026@1.0.0 | 4.782916 | 4294.219848| 36.489679|
| 030@1.0.0 | 3.284214 | 637.090915 | 12.275286|
| 044@1.0.0 | 3.331982 | 637.016113 | 12.042566|
| 045@1.0.0 | 3.444328 | 636.593884 | 12.602838|
| 048@1.0.0 | 10.063772| 739.655676 | 18.856578|
| 063@1.0.0 | 10.034572| 736.915010 | 18.674327|
| 076@1.0.0 | 3.296081 | 635.388283 | 13.008618|
| 083@1.0.0 | 3.304015 | 637.017334 | 12.434935|
| 084@1.0.0 | 3.389799 | 635.764099 | 12.602417|

<span style="color:blue;;">**Typologies**</span>

| Typology ID | mn       | mx       | ave      |
|-------------|----------|----------|----------|
| 028@1.0.0   | 0.079802 | 3.140593 | 0.139582 |
| 037@1.0.0   | 0.080601 | 3.142096 | 0.139708 |
| 044@1.0.0   | 0.070701 | 3.303908 | 0.122282 |
| 047@1.0.0   | 0.062301 | 3.698223 | 0.100181 |
| 095@1.0.0   | 0.041901 | 3.031201 | 0.075914 |
| 185@1.0.0   | 0.047101 | 3.589418 | 0.090269 |

<span style="color:green; font-size: 24px;">****Analysis****</span>

In this comprehensive analysis, which is based on examining the throughput of each configuration, as indicated by the FTPS metric. The analysis includes an evaluation of how effectively the configurations handle load, their responsiveness under stress, and their resilience in terms of fault tolerance and failover capabilities.

- **Single Instance:** With an **FTPS** of 2240, this configuration demonstrated reliable performance for scenarios not requiring high availability or distributed processing. It's particularly suited for development, testing, or smaller-scale production environments.
  - Cost for a small scale setup can be found here: [Infrastructure Spec for Tazama Sandbox](https://github.com/frmscoe/docs/blob/main/Technical/Environment-Setup/Infrastructure/Infrastructure-Spec-For-Tazama.md) 
- **2 Split Databases:** The **FTPS** of 2304.5 suggests a robust capability to handle more substantial workloads, especially read-heavy ones, while offering some level of scalability without the full complexity of clustering.
- **4 Split Databases:** The **FTPS** of 2496.83 indicates a strong ability to manage larger workloads, particularly those that are read-intensive. It also provides a degree of scalability without the need for the complete complexity of clustering.
- **Clustering:** Despite an **FTPS** of 264.5, the clustering configuration shines in high availability and horizontal scalability. It's built to endure high-load scenarios and provides the foundation for a resilient, enterprise-level deployment.

****Performance vs. Cost:****

The evaluation of performance against cost reveals an interesting dynamic between the configurations. The **Single Instance** configuration proved to be the most cost-effective, nearly matching the highest FTPS achieved by the Split Databases setup, which boasted the top performance. This demonstrates a high return on investment for the Single Instance in terms of performance per dollar. On the other end, the Clustering configuration, while being the most expensive and the slowest, is valued for its superior resilience and fault tolerance, features that are often required for mission-critical applications.

When considering the non-linear relationship between performance and cost, the Single Instance stands out for low- to medium-load scenarios where cost savings are paramount. In contrast, the additional expense of the Clustering setup is justified by its advanced capabilities, which are crucial for high-availability requirements despite its lower FTPS.

| Setup       | FTPS     | 3 Year Reserved $ Cost | 
|-------------|----------|------------------------|
| Single      | 2240     | **$14 843.84**        | 
| 2 SplitDB   | 2304.5   | **$20 575.82**        |
| 4 SplitDB   | 2496.83  | **$18 803.11**        |
| Cluser      | 264.5    | **$24 055.27**        |

****Cost-Performance Ratio:****

The cost-performance ratio is an essential metric for understanding the economic value of each configuration. A lower ratio signals better cost efficiency relative to performance:

- **Single Instance:** Demonstrates the best cost-performance ratio, indicating its status as the most economical option for the performance provided. It’s an ideal choice for organizations seeking to maximize their budget while still achieving robust performance levels.
- **2 Split Databases:** This configuration achieved the second FTPS. Although it comes with a higher cost than the Single Instance, its performance merits may justify the additional expense for workload scenarios that require swift read and write operations.
- **4 Split Databases:** This configuration achieved the highest FTPS, making it the top performer. While it is slightly more expensive than the Single Instance, it is more affordable than the 2 Split Database setup. Its exceptional performance may justify the additional expense for scenarios requiring fast read and write operations.
- **Clustering:** Despite having a less favorable cost-performance ratio due to its higher cost and lower FTPS, the Clustering configuration’s value lies in its ability to maintain service continuity and manage distributed data, which can be critical for certain business operations.

In summary, the 4 Split Databases setup presents the most significant advantage in FTPS, yet organizations must weigh whether the performance gains are worth the additional costs, especially when compared to the surprisingly efficient Single Instance.

| Setup      | FTPS   | 3 Year Reserved $ Cost | Cost-Performance Ratio (Cost/FTPS) |
|------------|--------|------------------------|-------------------------------------|
| Single     | 2240   | **$14,843.84**         | 6.63                                |
| 2 SplitDB  | 2304.5 | **$20,575.82**         | 8.93                                |
| 4 SplitDB  | 2496.83| **$18,803.11**         | 7.53                                |
| Cluster    | 264.5  | **$24,055.27**         | 90.97                               |

<span style="color:green; font-size: 24px;">****Improvement Steps****</span>

****Clustering****

For the Clustering configuration, our next step is a thorough review of our key usage within ArangoDB. The objective is to fully harness the capabilities of smart graphs, as detailed in ArangoDB’s guide on transforming graphs to smart graphs ([Transforming Graphs to SmartGraphs](https://arangodb.com/learn/graphs/transforming-graph-to-smartgraph/)). By optimizing key distribution and ensuring that related data is co-located on the same shard, we anticipate a significant boost in performance for graph-related queries. SmartGraphs offer a promising path to achieve horizontal scalability and improved query efficiency for our graph data models, especially in distributed database setups.

**Example of the restructuring:**
<pre language="json">
{
  _id:"edge/+49-1725310+49-11111111"
  _key:"+49-1725310+49-11111111"
}


{_id:"1725310", cc:"+49"}
{_id:"9725954444", cc:"+1"}

{
  _id:"edge/+49:17253109725954444:+1"
  _key:"+49:17253109725954444:+1"
}
</pre>

By adopting these two enhancements—splitting databases across individual ArangoDB instances and optimizing our Clustering configuration with smart graph technology we can achieve not only higher transactions per second (FTPS) but also to establish a more cost-effective infrastructure. These advancements will be pivotal in scaling our database capabilities to meet the expanding demands of our applications while simultaneously maximizing performance and managing costs.

<span style="color:green; font-size: 24px;">****Final Completed Steps****</span>

Continuing to refine and enhance the ArangoDB deployment strategies, the aim to implement significant improvements that will further optimize performance, scalability, and efficiency. The focus was on two main areas: SplitDbs and Clustering.

****4 SplitDbs****

The final test for the SplitDbs configuration involves splitting each database onto its own dedicated ArangoDB single instance. This approach showed distribute the read and write operations more evenly, leveraging multiple instances of ArangoDB. By isolating databases, we improved the overall performance by parallelizing the operations but also enhance the maintainability and scalability of the system. This split enabled the fine-tune resources and configurations specific to the workload and usage patterns of each database.

![arangodb-benchmarking-split4](../../images/arangodb-benchmarking-split4.png)

<span style="color:green; font-size: 24px;">****JSON End-to-End Times****</span>

#### What are These JSON References?

Here, we will present the detailed JSON files that reflect the end-to-end processing times, providing a clear picture of how each transaction is handled by the system. This data is critical for understanding the latency and efficiency of each configuration.And provides detailed statistics and results from performance tests for end-to-end (E2E) performance, typology processing times, and rule execution times. 

#### Why Are These JSON References Important?

1. **Performance Monitoring:** They offer insights into the performance of various system components under load.
2. **Resource Optimization:** By analyzing these metrics, you can make informed decisions on resource allocation and optimization.
3. **Bottleneck Identification:** Detailed performance data helps pinpoint specific areas that may be causing delays or inefficiencies.

#### What Am I Looking At?

1. **Prcoessor JSON:**
   - **Transaction Data:** Metrics on the entire transaction flow, including start and end times, amount of data processed, and elapsed time.
   - **TMSStats:** Statistics related to the Transaction Monitoring Service, including minimum, maximum, average, median, 90th percentile, and 99th percentile response times.
   - **CRSPStats:** Metrics for another service, similar to TMSStats.
   - **TPStats and TADPStats:** Additional service-specific statistics.

2. **Typology Results JSON:**
   - **Processing Times:** Metrics for different typologies, including minimum, maximum, and average processing times.
   - **Typology IDs:** Unique identifiers for each typology.

3. **Rule JSON:**
   - **Processing Times for Rules:** Metrics for different rules, including minimum, maximum, and average processing times.
   - **Rule IDs:** Unique identifiers for each rule.

#### What Should I Pay Attention To?

1. **Service-Specific Metrics:**
   - **TMSStats, CRSPStats, TPStats, TADPStats:** Look at these to understand the performance of individual services or components within the system.

2. **Typology and Rule Processing Times:**
   - **Min, Max, Average:** These times help identify which typologies or rules are performing well and which may need optimization.

By closely monitoring and analyzing these JSON references, you can gain valuable insights into the performance and health of your system, enabling you to make informed decisions to improve its efficiency and reliability.

<span style="color:olive; font-size: 18px;">****Single Instance****</span>

<details>
  <summary><span style="color:red; text-decoration: underline;">Processors</span></summary>
<pre language="json">
  [
   {
      "startTime":"2024-01-12T11:28:54.706Z",
      "endTime":"2024-01-12T11:30:10.136Z",
      "amount":168000,
      "elapsed":75,
      "ftps":2240,
      "TMSStats":[
         {
            "mn":3.064528,
            "mx":454.65403,
            "ave":23.146369636410714,
            "mea":17.910068,
            "ninety":37.057844,
            "ninetynine":68.164748
         }
      ],
      "CRSPStats":[
         {
            "mn":0.0793,
            "mx":1081.280548,
            "ave":0.19622855382738097,
            "mea":0.139,
            "ninety":0.212601,
            "ninetynine":0.291901
         }
      ],
      "TPStats":[
         {
            "mn":0.044,
            "mx":4.181393,
            "ave":0.33655242437212063,
            "mea":0.321499,
            "ninety":0.541701,
            "ninetynine":0.900599
         }
      ],
      "TADPStats":[
         {
            "mn":1.079506,
            "mx":14.106027,
            "ave":3.6996955052083336,
            "mea":4.3133815,
            "ninety":5.635591,
            "ninetynine":6.441988
         }
      ]
   }
]
</pre>
</details>
<details>
  <summary><span style="color:red; text-decoration: underline;">Rules</span></summary>
<pre language="json">
  [
   [
      {
         "ruleId":"001@1.0.0",
         "pcrgTm":{
            "mn":1.113302,
            "mx":1077.96542,
            "ave":6.12018949877381
         }
      },
      {
         "ruleId":"002@1.0.0",
         "pcrgTm":{
            "mn":0.725699,
            "mx":1077.004096,
            "ave":5.895627134380953
         }
      },
      {
         "ruleId":"003@1.0.0",
         "pcrgTm":{
            "mn":1.108798,
            "mx":1088.811725,
            "ave":6.129941848011905
         }
      },
      {
         "ruleId":"004@1.0.0",
         "pcrgTm":{
            "mn":1.063909,
            "mx":1082.020102,
            "ave":6.097922832470238
         }
      },
      {
         "ruleId":"006@1.0.0",
         "pcrgTm":{
            "mn":0.8134,
            "mx":1067.232368,
            "ave":5.990952735083333
         }
      },
      {
         "ruleId":"007@1.0.0",
         "pcrgTm":{
            "mn":0.721097,
            "mx":1080.692918,
            "ave":5.910856622005952
         }
      },
      {
         "ruleId":"008@1.0.0",
         "pcrgTm":{
            "mn":0.760997,
            "mx":1088.025851,
            "ave":5.951014326952381
         }
      },
      {
         "ruleId":"010@1.0.0",
         "pcrgTm":{
            "mn":0.739799,
            "mx":1072.31674,
            "ave":5.937875009386905
         }
      },
      {
         "ruleId":"011@1.0.0",
         "pcrgTm":{
            "mn":0.779906,
            "mx":1036.949571,
            "ave":5.909404689767857
         }
      },
      {
         "ruleId":"016@1.0.0",
         "pcrgTm":{
            "mn":0.677206,
            "mx":1081.916948,
            "ave":5.888669653613095
         }
      },
      {
         "ruleId":"017@1.0.0",
         "pcrgTm":{
            "mn":0.773099,
            "mx":1078.981549,
            "ave":5.870956482190476
         }
      },
      {
         "ruleId":"018@1.0.0",
         "pcrgTm":{
            "mn":0.8535,
            "mx":290.056776,
            "ave":6.023577596791667
         }
      },
      {
         "ruleId":"020@1.0.0",
         "pcrgTm":{
            "mn":0.874799,
            "mx":1077.3577,
            "ave":6.0167649286369045
         }
      },
      {
         "ruleId":"021@1.0.0",
         "pcrgTm":{
            "mn":0.876203,
            "mx":1086.230327,
            "ave":6.030042660005952
         }
      },
      {
         "ruleId":"024@1.0.0",
         "pcrgTm":{
            "mn":1.086795,
            "mx":1068.43552,
            "ave":6.092602155928572
         }
      },
      {
         "ruleId":"025@1.0.0",
         "pcrgTm":{
            "mn":0.926799,
            "mx":1081.769341,
            "ave":6.055373837940476
         }
      },
      {
         "ruleId":"026@1.0.0",
         "pcrgTm":{
            "mn":1.1591,
            "mx":289.111856,
            "ave":6.144004829922619
         }
      },
      {
         "ruleId":"027@1.0.0",
         "pcrgTm":{
            "mn":0.947296,
            "mx":1074.914651,
            "ave":6.034760396761905
         }
      },
      {
         "ruleId":"030@1.0.0",
         "pcrgTm":{
            "mn":0.7495,
            "mx":1086.258279,
            "ave":5.8805137245535715
         }
      },
      {
         "ruleId":"044@1.0.0",
         "pcrgTm":{
            "mn":0.646405,
            "mx":1056.480635,
            "ave":5.893529920523809
         }
      },
      {
         "ruleId":"045@1.0.0",
         "pcrgTm":{
            "mn":0.749406,
            "mx":1086.22068,
            "ave":5.885170113327381
         }
      },
      {
         "ruleId":"048@1.0.0",
         "pcrgTm":{
            "mn":0.862896,
            "mx":1096.811963,
            "ave":6.01905644872619
         }
      },
      {
         "ruleId":"054@1.0.0",
         "pcrgTm":{
            "mn":0.842896,
            "mx":1073.326955,
            "ave":6.008695988898809
         }
      },
      {
         "ruleId":"063@1.0.0",
         "pcrgTm":{
            "mn":0.860796,
            "mx":1080.558745,
            "ave":5.974419518458334
         }
      },
      {
         "ruleId":"076@1.0.0",
         "pcrgTm":{
            "mn":0.724596,
            "mx":1066.238811,
            "ave":5.899825062089286
         }
      },
      {
         "ruleId":"083@1.0.0",
         "pcrgTm":{
            "mn":0.658999,
            "mx":1078.322306,
            "ave":5.844439689083333
         }
      },
      {
         "ruleId":"084@1.0.0",
         "pcrgTm":{
            "mn":0.700498,
            "mx":1086.041934,
            "ave":5.871424179416667
         }
      },
      {
         "ruleId":"090@1.0.0",
         "pcrgTm":{
            "mn":1.217299,
            "mx":1079.610022,
            "ave":6.229023929154762
         }
      },
      {
         "ruleId":"091@1.0.0",
         "pcrgTm":{
            "mn":0.714199,
            "mx":1073.19271,
            "ave":5.8382459660297625
         }
      }
   ]
]
</pre>
</details>

<details>
  <summary><span style="color:red; text-decoration: underline;">Typologies</span></summary>
<pre language="json">
  [
   [
      {
         "typologyId":"000@1.0.0",
         "pcrgTm":{
            "mn":0.161001,
            "mx":69.364884,
            "ave":0.3141896668893289
         }
      },
      {
         "typologyId":"028@1.0.0",
         "pcrgTm":{
            "mn":0.077601,
            "mx":110.286111,
            "ave":0.1848494145003839
         }
      },
      {
         "typologyId":"037@1.0.0",
         "pcrgTm":{
            "mn":0.0727,
            "mx":62.399059,
            "ave":0.17905803596038206
         }
      },
      {
         "typologyId":"044@1.0.0",
         "pcrgTm":{
            "mn":0.0676,
            "mx":42.221434,
            "ave":0.17126919095899165
         }
      },
      {
         "typologyId":"047@1.0.0",
         "pcrgTm":{
            "mn":0.0573,
            "mx":56.685083,
            "ave":0.15160782387078928
         }
      },
      {
         "typologyId":"095@1.0.0",
         "pcrgTm":{
            "mn":0.045,
            "mx":36.492085,
            "ave":0.12922257361132305
         }
      },
      {
         "typologyId":"185@1.0.0",
         "pcrgTm":{
            "mn":0.0455,
            "mx":60.330876,
            "ave":0.1193527648711028
         }
      }
   ]
]
</pre>
</details>

<span style="color:maroon; font-size: 18px;">****2 Split Databases****</span>

<details>
  <summary><span style="color:red; text-decoration: underline;">Processors</span></summary>
<pre language="json">
  [
   {
      "startTime":"2024-01-18T11:39:44.814Z",
      "endTime":"2024-01-18T11:41:15.817Z",
      "amount":209710,
      "elapsed":91,
      "ftps":2304.5054945054944,
      "TMSStats":[
         {
            "mn":4.005121,
            "mx":1381.084974,
            "ave":18.385851768346765,
            "mea":10.2117785,
            "ninety":27.628587,
            "ninetynine":238.041629
         }
      ],
      "CRSPStats":[
         {
            "mn":0.0816,
            "mx":36.496003,
            "ave":0.16776833982165848,
            "mea":0.1407,
            "ninety":0.227099,
            "ninetynine":0.372901
         }
      ],
      "TPStats":[
         {
            "mn":0.045,
            "mx":110.286111,
            "ave":0.722903514573991,
            "mea":0.3942005,
            "ninety":1.052695,
            "ninetynine":6.447483
         }
      ],
      "TADPStats":[
         {
            "mn":1.102403,
            "mx":141.520514,
            "ave":2.893244217748319,
            "mea":1.904989,
            "ninety":3.219406,
            "ninetynine":22.967093
         }
      ]
   }
]
</pre>
  </details>
<details>
  <summary><span style="color:red; text-decoration: underline;">Rules</span></summary>
<pre language="json">
  [
   [
      {
         "ruleId":"001@1.0.0",
         "pcrgTm":{
            "mn":0.3649,
            "mx":90.689206,
            "ave":8.02900883009917
         }
      },
      {
         "ruleId":"002@1.0.0",
         "pcrgTm":{
            "mn":0.453499,
            "mx":124.144644,
            "ave":7.799125932418828
         }
      },
      {
         "ruleId":"003@1.0.0",
         "pcrgTm":{
            "mn":0.362105,
            "mx":103.066451,
            "ave":8.02811704280474
         }
      },
      {
         "ruleId":"004@1.0.0",
         "pcrgTm":{
            "mn":0.348802,
            "mx":112.311267,
            "ave":8.000257142922555
         }
      },
      {
         "ruleId":"006@1.0.0",
         "pcrgTm":{
            "mn":0.475602,
            "mx":87.301762,
            "ave":7.926437934504544
         }
      },
      {
         "ruleId":"007@1.0.0",
         "pcrgTm":{
            "mn":0.420099,
            "mx":102.175491,
            "ave":7.820823292703462
         }
      },
      {
         "ruleId":"008@1.0.0",
         "pcrgTm":{
            "mn":0.487103,
            "mx":99.338016,
            "ave":7.824588947430092
         }
      },
      {
         "ruleId":"010@1.0.0",
         "pcrgTm":{
            "mn":0.511601,
            "mx":90.160395,
            "ave":7.827315641910776
         }
      },
      {
         "ruleId":"011@1.0.0",
         "pcrgTm":{
            "mn":0.364398,
            "mx":89.293083,
            "ave":7.829234229438845
         }
      },
      {
         "ruleId":"016@1.0.0",
         "pcrgTm":{
            "mn":0.357401,
            "mx":106.103893,
            "ave":7.79835962549624
         }
      },
      {
         "ruleId":"017@1.0.0",
         "pcrgTm":{
            "mn":0.380902,
            "mx":143.433357,
            "ave":7.802873785316816
         }
      },
      {
         "ruleId":"018@1.0.0",
         "pcrgTm":{
            "mn":0.315001,
            "mx":82.471641,
            "ave":7.949069246842042
         }
      },
      {
         "ruleId":"020@1.0.0",
         "pcrgTm":{
            "mn":0.417101,
            "mx":81.713837,
            "ave":7.927967083837581
         }
      },
      {
         "ruleId":"021@1.0.0",
         "pcrgTm":{
            "mn":0.397101,
            "mx":123.341554,
            "ave":7.929615394508629
         }
      },
      {
         "ruleId":"024@1.0.0",
         "pcrgTm":{
            "mn":0.517802,
            "mx":127.300566,
            "ave":8.006648555812564
         }
      },
      {
         "ruleId":"025@1.0.0",
         "pcrgTm":{
            "mn":0.416704,
            "mx":98.19206,
            "ave":7.946223786759549
         }
      },
      {
         "ruleId":"026@1.0.0",
         "pcrgTm":{
            "mn":0.861398,
            "mx":100.090159,
            "ave":8.0504971048743
         }
      },
      {
         "ruleId":"027@1.0.0",
         "pcrgTm":{
            "mn":0.394402,
            "mx":124.468013,
            "ave":7.9452260083975474
         }
      },
      {
         "ruleId":"030@1.0.0",
         "pcrgTm":{
            "mn":0.746798,
            "mx":88.444151,
            "ave":7.810904539884698
         }
      },
      {
         "ruleId":"044@1.0.0",
         "pcrgTm":{
            "mn":0.379603,
            "mx":119.946893,
            "ave":7.782910758151728
         }
      },
      {
         "ruleId":"045@1.0.0",
         "pcrgTm":{
            "mn":0.372702,
            "mx":124.402356,
            "ave":7.784251618274031
         }
      },
      {
         "ruleId":"048@1.0.0",
         "pcrgTm":{
            "mn":0.550003,
            "mx":97.333589,
            "ave":7.910834719992623
         }
      },
      {
         "ruleId":"054@1.0.0",
         "pcrgTm":{
            "mn":0.378301,
            "mx":92.189809,
            "ave":7.888776794574993
         }
      },
      {
         "ruleId":"063@1.0.0",
         "pcrgTm":{
            "mn":0.377203,
            "mx":90.599108,
            "ave":7.897786872577968
         }
      },
      {
         "ruleId":"076@1.0.0",
         "pcrgTm":{
            "mn":0.343598,
            "mx":85.630458,
            "ave":7.8187620910530455
         }
      },
      {
         "ruleId":"083@1.0.0",
         "pcrgTm":{
            "mn":0.450699,
            "mx":97.241607,
            "ave":7.767084203501767
         }
      },
      {
         "ruleId":"084@1.0.0",
         "pcrgTm":{
            "mn":0.450005,
            "mx":90.279298,
            "ave":7.774045784528919
         }
      },
      {
         "ruleId":"090@1.0.0",
         "pcrgTm":{
            "mn":0.513398,
            "mx":87.407738,
            "ave":8.110915802533578
         }
      },
      {
         "ruleId":"091@1.0.0",
         "pcrgTm":{
            "mn":1.037015,
            "mx":111.627498,
            "ave":7.787655471918315
         }
      }
   ]
]
</pre>
</details>
<details>
  <summary><span style="color:red; text-decoration: underline;">Typologies</span></summary>
<pre language="json">
  [
   [
      {
         "typologyId":"000@1.0.0",
         "pcrgTm":{
            "mn":0.161001,
            "mx":69.364884,
            "ave":0.3141896668893289
         }
      },
      {
         "typologyId":"028@1.0.0",
         "pcrgTm":{
            "mn":0.077601,
            "mx":110.286111,
            "ave":0.1848494145003839
         }
      },
      {
         "typologyId":"037@1.0.0",
         "pcrgTm":{
            "mn":0.0727,
            "mx":62.399059,
            "ave":0.17905803596038206
         }
      },
      {
         "typologyId":"044@1.0.0",
         "pcrgTm":{
            "mn":0.0676,
            "mx":42.221434,
            "ave":0.17126919095899165
         }
      },
      {
         "typologyId":"047@1.0.0",
         "pcrgTm":{
            "mn":0.0573,
            "mx":56.685083,
            "ave":0.15160782387078928
         }
      },
      {
         "typologyId":"095@1.0.0",
         "pcrgTm":{
            "mn":0.045,
            "mx":36.492085,
            "ave":0.12922257361132305
         }
      },
      {
         "typologyId":"185@1.0.0",
         "pcrgTm":{
            "mn":0.0455,
            "mx":60.330876,
            "ave":0.1193527648711028
         }
      }
   ]
]
</pre>
</details>

<span style="color:orange; font-size: 18px;">****4 Split Databases****</span>

<details>
  <summary><span style="color:red; text-decoration: underline;">Processors</span></summary>
<pre language="json">
[
   {
      "startTime":"2024-06-04T15:16:55.624Z",
      "endTime":"2024-06-04T15:18:19.790Z",
      "amount":209734,
      "elapsed":84,
      "ftps":2496.8333333333335,
      "TMSStats":[
         {
            "mn":2.472165,
            "mx":1384.909064,
            "ave":12.650283793204727,
            "mea":8.0592315,
            "ninety":18.816924,
            "ninetynine":56.299422
         }
      ],
      "CRSPStats":[
         {
            "mn":0.066502,
            "mx":28.868027,
            "ave":0.12943702493634796,
            "mea":0.1097025,
            "ninety":0.159903,
            "ninetynine":0.262403
         }
      ],
      "TPStats":[
         {
            "mn":0.058101,
            "mx":1424.011354,
            "ave":0.9941893043555046,
            "mea":0.326906,
            "ninety":2.262551,
            "ninetynine":12.509207
         }
      ],
      "TADPStats":[
         {
            "mn":1.307124,
            "mx":578.523762,
            "ave":4.2894723433301225,
            "mea":2.1575375,
            "ninety":5.894816,
            "ninetynine":39.106534
         }
      ]
   }
]
</pre>
  </details>
<details>
  <summary><span style="color:red; text-decoration: underline;">Rules</span></summary>
<pre language="json">
[
   [
      {
         "ruleId":"001@1.0.0",
         "pcrgTm":{
            "mn":0.285404,
            "mx":48.507559,
            "ave":5.6410194537457965
         }
      },
      {
         "ruleId":"003@1.0.0",
         "pcrgTm":{
            "mn":0.461703,
            "mx":1047.250824,
            "ave":5.662649381847493
         }
      },
      {
         "ruleId":"004@1.0.0",
         "pcrgTm":{
            "mn":0.464005,
            "mx":1050.889407,
            "ave":5.668136525666342
         }
      },
      {
         "ruleId":"006@1.0.0",
         "pcrgTm":{
            "mn":0.348706,
            "mx":1444.151114,
            "ave":5.464872304763949
         }
      },
      {
         "ruleId":"007@1.0.0",
         "pcrgTm":{
            "mn":0.462911,
            "mx":1042.167066,
            "ave":5.355660705665237
         }
      },
      {
         "ruleId":"008@1.0.0",
         "pcrgTm":{
            "mn":0.663108,
            "mx":47.359632,
            "ave":5.342816623716786
         }
      },
      {
         "ruleId":"010@1.0.0",
         "pcrgTm":{
            "mn":0.651109,
            "mx":1043.065197,
            "ave":5.365783594678063
         }
      },
      {
         "ruleId":"011@1.0.0",
         "pcrgTm":{
            "mn":0.491506,
            "mx":46.341512,
            "ave":5.365500844165486
         }
      },
      {
         "ruleId":"016@1.0.0",
         "pcrgTm":{
            "mn":0.347908,
            "mx":1040.274874,
            "ave":5.331756582391742
         }
      },
      {
         "ruleId":"017@1.0.0",
         "pcrgTm":{
            "mn":0.355808,
            "mx":47.928598,
            "ave":5.339621210302149
         }
      },
      {
         "ruleId":"018@1.0.0",
         "pcrgTm":{
            "mn":0.352409,
            "mx":1445.053024,
            "ave":5.491574793593505
         }
      },
      {
         "ruleId":"020@1.0.0",
         "pcrgTm":{
            "mn":0.484412,
            "mx":1443.411684,
            "ave":5.484117952848456
         }
      },
      {
         "ruleId":"021@1.0.0",
         "pcrgTm":{
            "mn":0.495808,
            "mx":47.291114,
            "ave":5.48001259290174
         }
      },
      {
         "ruleId":"024@1.0.0",
         "pcrgTm":{
            "mn":0.670317,
            "mx":1450.582894,
            "ave":5.437627297950314
         }
      },
      {
         "ruleId":"026@1.0.0",
         "pcrgTm":{
            "mn":0.547011,
            "mx":52.046978,
            "ave":5.4464532991913055
         }
      },
      {
         "ruleId":"030@1.0.0",
         "pcrgTm":{
            "mn":0.478806,
            "mx":46.524069,
            "ave":5.331704409425318
         }
      },
      {
         "ruleId":"044@1.0.0",
         "pcrgTm":{
            "mn":0.561813,
            "mx":46.727582,
            "ave":5.330344745683322
         }
      },
      {
         "ruleId":"045@1.0.0",
         "pcrgTm":{
            "mn":0.407705,
            "mx":1446.019938,
            "ave":5.295632345163491
         }
      },
      {
         "ruleId":"048@1.0.0",
         "pcrgTm":{
            "mn":0.647011,
            "mx":1442.796469,
            "ave":5.453452345886866
         }
      },
      {
         "ruleId":"063@1.0.0",
         "pcrgTm":{
            "mn":0.579109,
            "mx":1444.119047,
            "ave":5.392713577877199
         }
      },
      {
         "ruleId":"076@1.0.0",
         "pcrgTm":{
            "mn":0.380909,
            "mx":47.289631,
            "ave":5.338893640765865
         }
      },
      {
         "ruleId":"083@1.0.0",
         "pcrgTm":{
            "mn":0.42231,
            "mx":1437.68889,
            "ave":5.298740350862213
         }
      },
      {
         "ruleId":"084@1.0.0",
         "pcrgTm":{
            "mn":0.564714,
            "mx":47.443165,
            "ave":5.3197971069793395
         }
      }
   ]
]
</pre>
</details>
<details>
  <summary><span style="color:red; text-decoration: underline;">Typologies</span></summary>
<pre language="json">
[
   [
      {
         "typologyId":"028@1.0.0",
         "pcrgTm":{
            "mn":0.111903,
            "mx":137.458595,
            "ave":0.23635505984536648
         }
      },
      {
         "typologyId":"037@1.0.0",
         "pcrgTm":{
            "mn":0.099302,
            "mx":145.159369,
            "ave":0.22755116771673445
         }
      },
      {
         "typologyId":"044@1.0.0",
         "pcrgTm":{
            "mn":0.093403,
            "mx":60.321459,
            "ave":0.23293783756052186
         }
      },
      {
         "typologyId":"047@1.0.0",
         "pcrgTm":{
            "mn":0.074102,
            "mx":1424.011354,
            "ave":0.20198902018169246
         }
      },
      {
         "typologyId":"095@1.0.0",
         "pcrgTm":{
            "mn":0.058101,
            "mx":166.151141,
            "ave":0.16023746898903193
         }
      },
      {
         "typologyId":"185@1.0.0",
         "pcrgTm":{
            "mn":0.066001,
            "mx":179.999053,
            "ave":0.17655784176439449
         }
      }
   ]
]
</pre>
</details>

<span style="color:navy; font-size: 18px;">****Clustering****</span>

<details>
  <summary><span style="color:red; text-decoration: underline;">Processors</span></summary>
<pre language="json">
  {
   "result":[
      {
         "startTime":"2024-03-28T13:30:58.796Z",
         "endTime":"2024-03-28T13:37:35.462Z",
         "amount":105000,
         "elapsed":397,
         "ftps":264.4836272040302,
         "TMSStats":[
            {
               "mn":7.525951,
               "mx":922.721903,
               "ave":42.66358546847619,
               "mea":35.1078355,
               "ninety":59.306448,
               "ninetynine":201.375115
            }
         ],
         "CRSPStats":[
            {
               "mn":0.052402,
               "mx":75.595687,
               "ave":0.12098821221904763,
               "mea":0.092802,
               "ninety":0.135903,
               "ninetynine":0.190901
            }
         ],
         "TPStats":[
            {
               "mn":0.041901,
               "mx":3.698223,
               "ave":0.18482163925187034,
               "mea":0.1740025,
               "ninety":0.272412,
               "ninetynine":0.459916
            }
         ],
         "TADPStats":[
            {
               "mn":0.898524,
               "mx":19.25505,
               "ave":1.5823704247142856,
               "mea":1.424517,
               "ninety":1.981621,
               "ninetynine":4.650432
            }
         ]
      }
   ],
   "hasMore":false,
   "cached":false,
   "extra":{
      "warnings":[
         
      ],
      "stats":{
         "writesExecuted":0,
         "writesIgnored":0,
         "scannedFull":525000,
         "scannedIndex":0,
         "cursorsCreated":0,
         "cursorsRearmed":0,
         "cacheHits":0,
         "cacheMisses":0,
         "filtered":0,
         "httpRequests":460,
         "executionTime":5.415963553998154,
         "peakMemoryUsage":22478848,
         "intermediateCommits":0
      }
   },
   "error":false,
   "code":201
}
</pre>
</details>
<details>
  <summary><span style="color:red; text-decoration: underline;">Rules</span></summary>
<pre language="json">
  [
   [
      {
         "ruleId":"001@1.0.0",
         "pcrgTm":{
            "mn":21.392369,
            "mx":776.231998,
            "ave":31.32945970465714
         }
      },
      {
         "ruleId":"003@1.0.0",
         "pcrgTm":{
            "mn":21.440985,
            "mx":778.777175,
            "ave":32.3440573710381
         }
      },
      {
         "ruleId":"004@1.0.0",
         "pcrgTm":{
            "mn":21.152663,
            "mx":767.317377,
            "ave":31.306244314961905
         }
      },
      {
         "ruleId":"006@1.0.0",
         "pcrgTm":{
            "mn":10.151482,
            "mx":2030.684397,
            "ave":32.32946094691429
         }
      },
      {
         "ruleId":"007@1.0.0",
         "pcrgTm":{
            "mn":3.453696,
            "mx":636.700504,
            "ave":12.457782804895238
         }
      },
      {
         "ruleId":"008@1.0.0",
         "pcrgTm":{
            "mn":3.267281,
            "mx":635.356175,
            "ave":12.557751136561905
         }
      },
      {
         "ruleId":"010@1.0.0",
         "pcrgTm":{
            "mn":3.352423,
            "mx":637.366123,
            "ave":13.002233980619048
         }
      },
      {
         "ruleId":"011@1.0.0",
         "pcrgTm":{
            "mn":3.250219,
            "mx":635.340887,
            "ave":11.70264975747619
         }
      },
      {
         "ruleId":"016@1.0.0",
         "pcrgTm":{
            "mn":3.24039,
            "mx":634.069046,
            "ave":12.183998341857142
         }
      },
      {
         "ruleId":"017@1.0.0",
         "pcrgTm":{
            "mn":3.402584,
            "mx":638.59988,
            "ave":12.676839050361906
         }
      },
      {
         "ruleId":"018@1.0.0",
         "pcrgTm":{
            "mn":14.578591,
            "mx":753.388747,
            "ave":24.87659235520952
         }
      },
      {
         "ruleId":"020@1.0.0",
         "pcrgTm":{
            "mn":10.044415,
            "mx":2025.032002,
            "ave":32.132249957238095
         }
      },
      {
         "ruleId":"021@1.0.0",
         "pcrgTm":{
            "mn":10.007269,
            "mx":2034.604899,
            "ave":32.42278760831429
         }
      },
      {
         "ruleId":"024@1.0.0",
         "pcrgTm":{
            "mn":3.667936,
            "mx":4293.391405,
            "ave":35.9169174460381
         }
      },
      {
         "ruleId":"026@1.0.0",
         "pcrgTm":{
            "mn":4.782916,
            "mx":4294.219848,
            "ave":36.4896787284
         }
      },
      {
         "ruleId":"030@1.0.0",
         "pcrgTm":{
            "mn":3.284214,
            "mx":637.090915,
            "ave":12.275286463133334
         }
      },
      {
         "ruleId":"044@1.0.0",
         "pcrgTm":{
            "mn":3.331982,
            "mx":637.016113,
            "ave":12.042566271361904
         }
      },
      {
         "ruleId":"045@1.0.0",
         "pcrgTm":{
            "mn":3.444328,
            "mx":636.593884,
            "ave":12.602838461200001
         }
      },
      {
         "ruleId":"048@1.0.0",
         "pcrgTm":{
            "mn":10.063772,
            "mx":739.655676,
            "ave":18.856577709657145
         }
      },
      {
         "ruleId":"063@1.0.0",
         "pcrgTm":{
            "mn":10.034572,
            "mx":736.91501,
            "ave":18.674327010342857
         }
      },
      {
         "ruleId":"076@1.0.0",
         "pcrgTm":{
            "mn":3.296081,
            "mx":635.388283,
            "ave":13.008618317723808
         }
      },
      {
         "ruleId":"083@1.0.0",
         "pcrgTm":{
            "mn":3.304015,
            "mx":637.017334,
            "ave":12.434934702209523
         }
      },
      {
         "ruleId":"084@1.0.0",
         "pcrgTm":{
            "mn":3.389799,
            "mx":635.764099,
            "ave":12.602416828438097
         }
      }
   ]
]
</pre>
</details>
<details>
  <summary><span style="color:red; text-decoration: underline;">Typologies</span></summary>
<pre language="json">
  [
   [
      {
         "typologyId":"028@1.0.0",
         "pcrgTm":{
            "mn":0.079802,
            "mx":3.140593,
            "ave":0.13958241032380952
         }
      },
      {
         "typologyId":"037@1.0.0",
         "pcrgTm":{
            "mn":0.080601,
            "mx":3.142096,
            "ave":0.13970823563809523
         }
      },
      {
         "typologyId":"044@1.0.0",
         "pcrgTm":{
            "mn":0.070701,
            "mx":3.303908,
            "ave":0.12228206685714285
         }
      },
      {
         "typologyId":"047@1.0.0",
         "pcrgTm":{
            "mn":0.062301,
            "mx":3.698223,
            "ave":0.10018067380000001
         }
      },
      {
         "typologyId":"095@1.0.0",
         "pcrgTm":{
            "mn":0.041901,
            "mx":3.031201,
            "ave":0.07591413400000001
         }
      },
      {
         "typologyId":"185@1.0.0",
         "pcrgTm":{
            "mn":0.047101,
            "mx":3.589418,
            "ave":0.09026867119047619
         }
      }
   ]
]
</pre>
</details>

<span style="color:green; font-size: 24px;">****Screenshots****</span>

#### What are These Graphs?

These graphs show the maximum CPU utilization percentages for various Virtual Machine Scale Sets (VMSS) in an Azure Kubernetes Service (AKS) cluster. Each graph represents the CPU usage over a specific period, indicating how different virtual machines (VMs) within the scale sets are performing.

#### Why Are These Graphs Important?

1. **Performance Monitoring:** These graphs help in tracking the CPU usage of different VMs to identify and resolve performance issues.
2. **Resource Management:** By monitoring CPU usage, you can ensure efficient use of CPU resources across the VMs.
3. **Operational Insights:** They provide insights into the CPU demands of different components of the cluster, helping in optimizing resource allocation and preventing resource exhaustion.
4. **Bottleneck Identification:** By observing which components are using the most CPU, you can pinpoint potential bottlenecks and areas that may require optimization.
5. **Troubleshooting:** These graphs help in identifying performance issues related to CPU usage, enabling quicker resolutions.

#### What Am I Looking At?

- **Y-Axis:** Represents the CPU utilization percentage, which can range from 0% to 100%.
- **X-Axis:** Represents the time period over which the CPU utilization is measured.
- **Colored Lines:** Each line corresponds to a different VM within the VMSS, showing its CPU usage over time. The legend below the graph indicates which color corresponds to which VM.

#### What Should I Pay Attention To?

1. **CPU Spikes:** Look for any sudden increases in CPU usage which might indicate a performance issue or a spike in demand.
2. **Sustained High CPU Usage:** Identify any VMs with consistently high CPU usage, which may need optimization or scaling.
3. **Low CPU Usage:** VMs with consistently low CPU usage might indicate over-provisioning.
4. **Comparative Analysis:** Compare CPU usage across different VMs to identify any outliers or anomalies.
5. **Time Correlation:** Note the times when CPU usage peaks occur. Correlate these times with any specific operations or workloads to understand what is causing the increased load.

By closely monitoring and analyzing these graphs, you can gain valuable insights into the performance and health of your AKS cluster, enabling you to make informed decisions to improve its efficiency and reliability.

<span style="color:olive; font-size: 18px;">****Single Instance****</span>

![arangodb-benchmarking-azure-single1](../../images/arangodb-benchmarking-azure-single1.png)
![arangodb-benchmarking-azure-single2](../../images/arangodb-benchmarking-azure-single2.png)
![arangodb-benchmarking-azure-single3](../../images/arangodb-benchmarking-azure-single3.png)
![arangodb-benchmarking-azure-single4](../../images/arangodb-benchmarking-azure-single4.png)

<span style="color:maroon; font-size: 18px;">****2 Split Databases****</span>

![arangodb-benchmarking-azure-2split1](../../images/arangodb-benchmarking-azure-2split1.png)
![arangodb-benchmarking-azure-2split2](../../images/arangodb-benchmarking-azure-2split2.png)
![arangodb-benchmarking-azure-2split3](../../images/arangodb-benchmarking-azure-2split3.png)
![arangodb-benchmarking-azure-2split4](../../images/arangodb-benchmarking-azure-2split4.png)
![arangodb-benchmarking-azure-2split5](../../images/arangodb-benchmarking-azure-2split5.png)

<span style="color:orange; font-size: 18px;">****4 Split Databases****</span>

![arangodb-benchmarking-azure-4split1](../../images/arangodb-benchmarking-azure-4split1.png)
![arangodb-benchmarking-azure-4split2](../../images/arangodb-benchmarking-azure-4split2.png)
![arangodb-benchmarking-azure-4split3](../../images/arangodb-benchmarking-azure-4split3.png)
![arangodb-benchmarking-azure-4split4](../../images/arangodb-benchmarking-azure-4split4.png)
![arangodb-benchmarking-azure-4split5](../../images/arangodb-benchmarking-azure-4split5.png)
![arangodb-benchmarking-azure-4split6](../../images/arangodb-benchmarking-azure-4split6.png)
![arangodb-benchmarking-azure-4split7](../../images/arangodb-benchmarking-azure-4split7.png)
![arangodb-benchmarking-azure-4split8](../../images/arangodb-benchmarking-azure-4split8.png)
![arangodb-benchmarking-azure-4split9](../../images/arangodb-benchmarking-azure-4split9.png)

<span style="color:navy; font-size: 18px;">****Clustering****</span>

![arangodb-benchmarking-azure-cluster1](../../images/arangodb-benchmarking-azure-cluster1.png)
![arangodb-benchmarking-azure-cluster2](../../images/arangodb-benchmarking-azure-cluster2.png)
![arangodb-benchmarking-azure-cluster3](../../images/arangodb-benchmarking-azure-cluster3.png)
![arangodb-benchmarking-azure-cluster4](../../images/arangodb-benchmarking-azure-cluster4.png)
![arangodb-benchmarking-azure-cluster5](../../images/arangodb-benchmarking-azure-cluster5.png)

### Breakdown of the ArangoDB Dashboard

#### What is the Dashboard?

This dashboard provides various performance metrics related to I/O operations for ArangoDB. It includes key statistics such as memory table sizes, cache sizes, CPU rate, read/write operations, and more.

#### Why is it There?

The dashboard is designed to monitor and visualize the I/O performance and health of ArangoDB instances. It helps in identifying potential issues, optimizing resource usage, and ensuring that the database is running efficiently.

#### Why is it Important?

1. **Performance Monitoring:** It provides real-time data on I/O operations, helping to quickly identify and troubleshoot issues.
2. **Resource Management:** By monitoring metrics like memory usage and CPU rate, you can optimize resource allocation and prevent resource exhaustion.
3. **Operational Insights:** Understanding metrics such as read/write operations and cache usage can provide insights into the operational behavior of the database.

#### What are You Looking At?

- **Current Size Mem Tables:** Displays the current size of memory tables over time. The Y-axis represents the size in bytes, and the X-axis represents the time period.
- **Search Column Cache Size:** Shows the size of the search column cache over time. The Y-axis represents the size in bytes, and the X-axis represents the time period.
- **Allocated Cache Size:** Displays the allocated cache size over time. The Y-axis represents the size in bytes, and the X-axis represents the time period.
- **CPU Rate:** Shows the CPU usage rate over time. The Y-axis represents the percentage of CPU utilization, and the X-axis represents the time period.
- **Level 0-6 Files:** Displays the number of files in different levels over time. The Y-axis represents the number of files, and the X-axis represents the time period.
- **Bytes Read/Written:** Shows the number of bytes read and written over time. The Y-axis represents the number of bytes, and the X-axis represents the time period.
- **Compaction Written/Read:** Displays the amount of data written/read during compaction operations over time. The Y-axis represents the number of bytes, and the X-axis represents the time period.
- **Pending Compaction:** Shows the amount of data pending for compaction over time. The Y-axis represents the number of bytes, and the X-axis represents the time period.
- **Writes Stopped:** Indicates if write operations were stopped at any point. The Y-axis represents the status (stopped/not stopped), and the X-axis represents the time period.
- **Threads:** Displays the number of threads in use over time. The Y-axis represents the number of threads, and the X-axis represents the time period.
- **RocksDB Cache Usage:** Shows the usage of RocksDB cache over time. The Y-axis represents the size in bytes, and the X-axis represents the time period.
- **Cluster Communication Lease Duration:** Displays the duration of lease for cluster communication over time. The Y-axis represents the duration, and the X-axis represents the time period.

#### What Should You Pay Attention To?

1. **Memory Table Sizes:**
   - Monitor the size of memory tables to ensure they do not grow excessively, which can impact performance.
   - Look for any sudden increases or patterns that may indicate issues.

2. **Cache Sizes:**
   - Check the search column and allocated cache sizes to ensure efficient cache usage.
   - Observe any trends or changes in cache sizes over time.

3. **CPU Rate:**
   - Monitor the CPU usage rate to ensure the database is not running out of CPU resources.
   - Look for any spikes or sustained periods of high CPU usage.

4. **File Levels:**
   - Keep an eye on the number of files in different levels, as a high number can indicate compaction issues.
   - Observe any trends or changes in file levels over time.

5. **Read/Write Operations:**
   - Monitor the number of bytes read and written to ensure efficient I/O operations.
   - Look for any patterns or spikes that may indicate issues.

6. **Compaction Operations:**
   - Check the amount of data written/read during compaction operations to ensure they are running efficiently.
   - Observe any trends or changes in compaction operations over time.

7. **Pending Compaction:**
   - Monitor the amount of data pending for compaction to ensure it does not grow excessively.
   - Look for any sudden increases or patterns that may indicate issues.

8. **Writes Stopped:**
   - Ensure that write operations are not being stopped frequently, which can impact performance.
   - Observe any patterns or trends in write stoppages.

9. **Threads:**
   - Monitor the number of threads in use to ensure efficient resource usage.
   - Look for any spikes or sustained periods of high thread usage.

10. **RocksDB Cache Usage:**
    - Check the usage of RocksDB cache to ensure efficient cache management.
    - Observe any trends or changes in cache usage over time.

11. **Cluster Communication Lease Duration:**
    - Monitor the duration of lease for cluster communication to ensure efficient cluster operations.
    - Look for any patterns or changes in lease duration over time.

By closely monitoring these metrics, you can maintain the health and performance of your ArangoDB instances, ensuring they operate efficiently and effectively.

![arangodb-benchmarking-azure-cluster6](../../images/arangodb-benchmarking-azure-cluster6.png)
### Breakdown of the Arango CPU Utilization Graph

#### What is the Graph?

This graph displays the CPU utilization rates for various ArangoDB components over a specified time period. Each line represents the CPU usage of a different component or node within the ArangoDB cluster.

#### Why is it There?

The graph is included to monitor and visualize the performance of the ArangoDB cluster, specifically focusing on the CPU usage of each component. This helps in identifying performance bottlenecks and understanding the load distribution across the cluster.

#### Why is it Important?

1. **Performance Monitoring:** High CPU utilization can indicate that the system is under heavy load, which can lead to performance degradation or failures.
2. **Bottleneck Identification:** By observing which components are using the most CPU, you can pinpoint potential bottlenecks and areas that may require optimization.
3. **Resource Allocation:** Understanding CPU usage patterns helps in making informed decisions about resource allocation and scaling to ensure balanced performance across the cluster.

#### What are You Looking At?

- **Y-Axis:** Represents the CPU utilization percentage, ranging from 0% to 100%.
- **X-Axis:** Represents the time period over which the CPU utilization is measured.
- **Colored Lines:** Each line corresponds to a different ArangoDB component or node, showing its CPU usage over time. The legend on the right side of the graph indicates which color corresponds to which component.

#### What Should You Pay Attention To?

1. **Spikes in CPU Utilization:** Look for any spikes or sustained periods of high CPU usage. This could indicate that a particular node or component is under heavy load and might be a bottleneck.
2. **Comparison Between Components:** Compare the CPU usage across different components. If one component consistently uses more CPU than others, it might be a candidate for optimization or scaling.
3. **Time Correlation:** Note the times when CPU usage peaks occur. Correlate these times with any specific operations or workloads to understand what is causing the increased load.
4. **Overall CPU Usage:** Pay attention to the overall trend in CPU usage. If the entire cluster is showing high CPU utilization, it might indicate the need for additional resources or a more efficient load balancing strategy.

By closely monitoring and analyzing this graph, you can gain valuable insights into the performance and health of your ArangoDB cluster, enabling you to make informed decisions to improve its efficiency and reliability.

![arangodb-benchmarking-azure-cluster7](../../images/arangodb-benchmarking-azure-cluster7.png)

### Breakdown of the Redis Cluster Dashboard

#### What is the Dashboard?

This dashboard provides various performance metrics for a Redis cluster running in a Kubernetes environment. It includes key statistics such as memory usage, network I/O, hit/miss rates, total items per database, and more.

#### Why is it There?

The dashboard is designed to monitor and visualize the performance and health of the Redis cluster. It helps in identifying potential issues, optimizing resource usage, and ensuring that the cluster is running efficiently.

#### Why is it Important?

1. **Performance Monitoring:** It provides real-time data on the cluster's performance, helping to quickly identify and troubleshoot issues.
2. **Resource Management:** By monitoring metrics like memory usage and network I/O, you can optimize resource allocation and prevent resource exhaustion.
3. **Operational Insights:** Understanding metrics such as hit/miss rates and expiring keys can provide insights into the operational behavior of the Redis cluster.

#### What are You Looking At?

- **Uptime:** Displays the total uptime of the Redis cluster.
- **Clients:** Shows the number of connected clients.
- **Memory Usage:** Displays the current memory usage of the Redis cluster. The gauge indicates the percentage of memory used.
- **Commands Executed/sec:** Shows the number of commands executed per second (currently no data is displayed).
- **Hits/Misses per Sec:** Shows the number of cache hits and misses per second.
- **Total Memory Usage:** Displays a graph of total memory usage over time, showing both used and maximum memory.
- **Network I/O:** Displays a graph of network input/output over time.
- **Total Items per DB:** Shows the total number of items in the database over time.
- **Expiring vs Not-Expiring Keys:** Shows the number of keys that are expiring versus those that are not expiring over time.
- **Expired/Evicted:** Displays the number of keys that have expired or been evicted over time.
- **Redis Connected Clients:** Shows the number of connected clients over time.
- **Command Calls/sec:** Shows the number of command calls per second (currently no data is displayed).

#### What Should You Pay Attention To?

1. **Memory Usage:**
   - Monitor the memory usage gauge to ensure that the cluster is not running out of memory. High memory usage can lead to performance degradation.
   - Check the total memory usage graph to observe any spikes or sustained high usage.

2. **Hit/Miss Rates:**
   - The hits/misses per second graph can help you understand the efficiency of the cache. High miss rates may indicate that the cache is not effectively storing frequently accessed data.

3. **Network I/O:**
   - The network I/O graph shows the volume of data being transferred. Sudden spikes in network I/O could indicate unusual activity or potential issues.

4. **Total Items per DB:**
   - The total items per DB graph helps you monitor the growth of the database. Rapid growth may indicate the need for additional resources or optimization.

5. **Expiring vs Not-Expiring Keys:**
   - This graph shows the balance between expiring and non-expiring keys. A high number of expiring keys may impact performance, as the system needs to continuously manage these keys.

6. **Expired/Evicted:**
   - Monitoring expired and evicted keys helps in understanding the lifecycle and retention of data in the Redis cluster. High eviction rates might indicate memory pressure or suboptimal key expiration policies.

7. **Redis Connected Clients:**
   - The number of connected clients is an important metric for understanding the load on the Redis server. Sudden changes in this number can indicate issues with client connections or network problems.

8. **Command Calls/sec:**
   - This metric, although currently not displaying data, is important for understanding the rate at which commands are being processed by the Redis server.

By closely monitoring these metrics, you can maintain the health and performance of your Redis cluster, ensuring it operates efficiently and effectively.

![arangodb-benchmarking-azure-cluster8](../../images/arangodb-benchmarking-azure-cluster8.png)

### Breakdown of the NATS Server Dashboard

#### What is the Dashboard?

This dashboard provides various performance metrics for NATS servers. It includes key statistics such as server CPU and memory usage, throughput (bytes in/out and messages in/out), client metrics (connections and subscriptions), and more.

#### Why is it There?

The dashboard is designed to monitor and visualize the performance and health of NATS servers. It helps in identifying potential issues, optimizing resource usage, and ensuring that the servers are running efficiently.

#### Why is it Important?

1. **Performance Monitoring:** It provides real-time data on the servers' performance, helping to quickly identify and troubleshoot issues.
2. **Resource Management:** By monitoring metrics like CPU and memory usage, you can optimize resource allocation and prevent resource exhaustion.
3. **Operational Insights:** Understanding metrics such as throughput and client connections can provide insights into the operational behavior of the NATS servers.

#### What are You Looking At?

- **Server CPU:** Displays the CPU usage of the NATS servers over time. The Y-axis represents the percentage of CPU utilization, and the X-axis represents the time period.
- **Server Memory:** Shows the memory usage of the NATS servers over time. The Y-axis represents the amount of memory used, and the X-axis represents the time period.
- **Throughput (Bytes In/Out):** Displays the amount of data being transferred in and out of the NATS servers over time. The Y-axis represents the amount of data, and the X-axis represents the time period.
- **Throughput (Messages In/Out):** Shows the number of messages being transferred in and out of the NATS servers over time. The Y-axis represents the number of messages, and the X-axis represents the time period.
- **Client Metrics (Connections):** Displays the number of client connections to the NATS servers over time. The Y-axis represents the number of connections, and the X-axis represents the time period.
- **Client Metrics (Subscriptions):** Shows the number of subscriptions on the NATS servers over time. The Y-axis represents the number of subscriptions, and the X-axis represents the time period.
- **Client Metrics (Slow Consumers):** Displays metrics related to slow consumers over time. The Y-axis represents the number of slow consumers, and the X-axis represents the time period.

#### What Should You Pay Attention To?

1. **Server CPU Usage:**
   - Monitor the CPU usage graph to ensure that the servers are not running out of CPU resources. High CPU usage can lead to performance degradation.
   - Look for any spikes or sustained periods of high CPU usage.

2. **Server Memory Usage:**
   - Check the memory usage graph to ensure that the servers have enough memory available. High memory usage can lead to performance issues.
   - Observe any spikes or trends in memory usage over time.

3. **Throughput (Bytes In/Out):**
   - Monitor the amount of data being transferred in and out of the servers. Sudden spikes in data transfer could indicate unusual activity or potential issues.
   - Compare the bytes in and out to understand the data flow and balance.

4. **Throughput (Messages In/Out):**
   - Observe the number of messages being transferred in and out of the servers. High message rates can indicate heavy usage and potential bottlenecks.
   - Look for trends and spikes in message transfer rates.

5. **Client Connections:**
   - Monitor the number of client connections to the servers. Sudden changes in the number of connections can indicate issues with client connectivity or network problems.

6. **Subscriptions:**
   - Keep an eye on the number of subscriptions. A high number of subscriptions can impact server performance.
   - Observe any trends or changes in subscription counts over time.

7. **Slow Consumers:**
   - Monitor metrics related to slow consumers to ensure that there are no performance issues caused by clients that cannot keep up with the data rate.
   - Look for trends and spikes in the number of slow consumers.

By closely monitoring these metrics, you can maintain the health and performance of your NATS servers, ensuring they operate efficiently and effectively.

![arangodb-benchmarking-azure-cluster9](../../images/arangodb-benchmarking-azure-cluster9.png)