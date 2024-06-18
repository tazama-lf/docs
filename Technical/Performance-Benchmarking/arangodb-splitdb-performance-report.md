# ArangoDB SplitDB Performance Report

## Overview

This document outlines the architecture of a split database setup using four separate instances of ArangoDB and the performance outcomes on Azure cloud testing to evaluate the efficiency of read and write operations within a splitdb environment, using JMeter as the tool to generate the workload. The main points of consideration were the CPU utilization on Azure nodes, write operation throughput and impact of scaling operations.

## ArangoDB Instances

[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/hEHjK0t1K2Pbei9t-image-1718284785203.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/hEHjK0t1K2Pbei9t-image-1718284785203.png)

<details>
  <summary>PlantUML</summary>
@startuml
!define RECTANGLE(x) rectangle x <<Database>>

package "Arango 1" {
  RECTANGLE(Configuration) {
    [transaction]
    [typologyExpression]
    [channelExpression]
    [configuration]
  }
  RECTANGLE(NetworkMap) {
    [networkConfiguration]
  }
}

package "Arango 2" {
  RECTANGLE(Pseudonyms) {
    [pseudonyms]
    [accounts]
    [account_holder]
    [entities]
    [transactionRelationship]
  }
}

package "Arango 3" {
  RECTANGLE(TransactionHistory) {
    [transactionHistoryPacs002]
    [transactionHistoryPacs008]
    [transactionHistoryPain001]
    [transactionHistoryPain013]
    [list]
    [watchlist]
  }
}

package "Arango 4" {
  RECTANGLE(EvaluationResults) {
    [transactions]
  }
}
@enduml

</details>

### Arango 1 - Configuration/NetworkMap Database

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

### Arango 2 - Pseudonyms Database

**Arango 2** focuses on pseudonymity and identity management within the system. The collections housed here are:

- `pseudonyms`
- `accounts`
- `account_holder`
- `entities`
- `transactionRelationship`

This instance is integral for privacy and identity management, ensuring that user data is mapped and managed securely.

### Arango 3 - Transaction History Database

The **Arango 3** instance is tailored for transaction history storage. It includes:

- `transactionHistoryPacs002`
- `transactionHistoryPacs008`
- `transactionHistoryPain001`
- `transactionHistoryPain013`
- `list`
- `watchlist`

This instance serves as a historical data store, capturing all transaction details for auditing and reporting purposes.

### Arango 4 - Evaluation Results Database

Lastly, **Arango 4** is dedicated to storing evaluation results in the `transactions` collection. It holds the output of transaction evaluations, serving as a data store for post-transaction analysis.

## Test Environment

- ArangoDB SplitDB test
- SPlitDB Configuration: 3 nodes with 96 vCPUs and 1 node 32vCPUs
- Load Testing Tool: Apache JMeter
- Deployment: Azure Kubernetes Service (AKS)

### List of Applications
- **NATS**: High-performance messaging system.
- **ArangoDB**: Multi-model database system.
- **Redis**: In-memory data structure store.
- **Typology Processor (TP)**: Calculates a typology score for any and every typology in the platform.
- **Transaction Aggregation Decisioning Processor (TADP)**: Aggregates and decides on transaction data.
- **Transaction Monitoring Service (TMS)**: Analyzes transaction data.
- **Channel Router Setup Processor (CRSP)**: Determines which channels and typologies a transaction must be submitted for processing.

### Application Deployment Configuration
The deployment configuration for each application across the servers is as follows:

| Processor/Service Deployment              | Node Spec | Node Count | Cost Per Hour $ | Additional Notes        |
|-------------------------------------------|-----------|------------|-----------------|-------------------------|
| **Transaction Monitoring Service (TMS)**  | F32s v2   | 5          | 1.353           | 32 CPU / 64 gigs RAM    |
| **Channel Router Setup Processor (CRSP)** | F32s v2   | 4          | 1.353           | 32 CPU / 64 gigs RAM    |
| **Typology Processor (TP)**               | F32s v2   | 8          | 1.353           | 32 CPU / 64 gigs RAM    |
| **Transaction Aggregation Decisioning Processor (TADP)** | F32s v2   | 5          | 1.353           | 32 CPU / 64 gigs RAM    |
| **Rule processors**                       | F32s v2   | 8          | 1.353           | 32 CPU / 64 gigs RAM    |
| **Redis**                                 | F32s v2   | 3          | 1.353           | 32 CPU / 64 gigs RAM    |
| **NATS**                                  | F32s v2   | 3          | 1.353           | 32 CPU / 64 gigs RAM    |
| **ArangoDB (Config)**                     | F32s v2   | 1          | 1.353           | 32 CPU / 64 gigs RAM    |
| **ArangoDB (History / Pseudonym and EvalResults)** | D96s_v5 | 3          | 4.86            | 96 CPU / 320 gigs RAM   |
|<span style="color:green;">**Total**</span>|           | **40**     | **68.70**       |                         |
| **JMeter**                                 | D8as_V4   | 10         | 0.4             | 8 CPU / 32 gigs RAM     |
|<span style="color:green;">**Total**</span>|           | **10**     | **4**           |                         |
| **Corends**                               | D4s_V3    | 4          | 0.23            | 4 CPU / 16 gigs RAM     |
|<span style="color:green;">**Total**</span>|           | **4**      | **0.92**        |                         |

| Database Component| Disk Type | Disk Count | Total Disk Price | Additional Notes     |
|---------------------|-----------|------------|------------------|----------------------|  
| **Storage Account** |           |            | 0.00188 per GB |The loads sent through wont use more than one gig   
| **Managed Disks**   | SSD       | 1          | 0.000127          |                     |
| **Managed Disks**   | Ultra     | 3          | 0.000085          |                     |
|<span style="color:green;">**Total**</span>|           | **4**      | 0.000508          |                     |

| Cluster Uptime & Costs                    |           |
|-------------------------------------------|-----------|
| **Setup Time (Hours)**                    | 1         |
| **Testing Duration (Hours)**              | 7         |
| **Total Uptime (Hours)**                  | 8         |
| **Total Cost Per Hour**                   | $73.62    |
| **Total Cost Per Day**                    | $588.96   | 

### 3 year Reserved Costing

|Spec | Node Count | Cost Per Month $ | Additional Notes        |
-----------|-------|-----------------|-------------------------|
| Azure K8s  | 4     | 483.25        | 4 CPU / 16 gigs RAM    |
| F32s v2    | 37    | 4317.23       | 32 CPU / 64 gigs RAM    |
| D96s_v5    | 3     | 13393.99      | 96 CPU / 320 gigs RAM   |
|<span style="color:green;">**Total**</span>|           | **18194.49**      | 

[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/Gnb4C5IaG2LVh18x-image-1718202981006.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/Gnb4C5IaG2LVh18x-image-1718202981006.png)


### Test Execution
#### 1. SplitDB Configuration & Metrics
- The Arango SplitDB set up with 3 96 vCPUs and 1 32 vCPU for the configuration database.
- The Config , transaction History and Evaluation databases only used about 20% of its CPU . The Pseudonyms database was using about 50% of its CPU.
- Metrics were gathered from the Azure dashboard, showing CPU usage.
#### 2. Read Queries Performance
- Processing times for read queries were found to be slow.
- The Azure metrics indicated that as the CPU load increased, the read operation latencies also increased, leading to performance bottlenecks.
#### 3. Write Operations Performance
- JMeter tests showed that write operations to ArangoDB were completed quickly, with an ingestion rate of 3525 messages per second.
- All transactions were submitted to the Transaction Monitoring Service (TMS) within a 1-minute timeframe, indicating that the writes were not affected by the issues impacting read operations.
#### 4. Database Scaling
- 4 database instances.
- An additional Azure node was provisioned to host the new database instance, aimed at distributing the load and improving read query performance.
#### 5. Network Topology Optimization
- The typologies were changed from 26 to 6  to improve the performance of the Typology Processor, Transaction Aggregatorand Decision Processor.
- This change was made in response to the observed delays in rule processing.

#### 6. MaxCPU
- The CPU consumption on the processors were never maxing out CPU like they use too , scaled the max CPU from 1 to 2 to use more CPU on the processors.

### Benchmarking Results
Benchmarking involves sending transactions through the system to replicate real-life scenarios. Below are the details of the scaled applications and their configurations:

**ELK Stack** - <span style="color:red;">**Disabled**</span>

<span style="color:green;">**TPS -**</span> **3525.23** 

<span style="color:green;">**FTPS -**</span> **2496.83** 

**210 000 transactions processed in 83.99 seconds**

**Jmeter Setup:**
| Jmeter Pod Count | Threads | Iterations per thread | Total iterations (Transactions) | Total Financial Transactions |
|------------------|---------|-----------------------|------------------|------------------------------|
| 10               | 100     | 210                   | 420 000          | 210 000                      | 

<span style="color:red;">**Note:**</span> **Each processor is set to MaxCPU = 2 to maximize CPU utilization.**

**Pod Counts:**
| TMS | CRSP | # Rules | Rule Pods | # Typologies | TP | TADP | REDIS | NATS | ArangoDB |
|-----|------|---------|-----------|--------------|----|------|-------|------|----------|
| 100 | 150  | 23      | 16        | 6            | 400  | 400   | 60     | 12    | 4        |


## Attachments and Supporting Documents
- ArangoDB Dashboard screenshots
- JMeter test results
- Azure performance metrics screenshots
- JSON files with detailed performance metrics

<details>
  <summary>Jmeter Statistics</summary>
<pre language="json">
{
  "HTTP pacs002 Request" : {
    "transaction" : "HTTP pacs002 Request",
    "sampleCount" : 210000,
    "errorCount" : 0,
    "errorPct" : 0.0,
    "meanResTime" : 16.341590476190635,
    "medianResTime" : 9.0,
    "minResTime" : 3.0,
    "maxResTime" : 498.0,
    "pct1ResTime" : 17.0,
    "pct2ResTime" : 21.0,
    "pct3ResTime" : 74.0,
    "throughput" : 3527.2510673575132,
    "receivedKBytesPerSec" : 3290.6804060071245,
    "sentKBytesPerSec" : 8092.218112451425
  },
  "HTTP pacs008 Request" : {
    "transaction" : "HTTP pacs008 Request",
    "sampleCount" : 210000,
    "errorCount" : 0,
    "errorPct" : 0.0,
    "meanResTime" : 40.83254285714323,
    "medianResTime" : 28.0,
    "minResTime" : 5.0,
    "maxResTime" : 1047.0,
    "pct1ResTime" : 45.0,
    "pct2ResTime" : 78.0,
    "pct3ResTime" : 102.0,
    "throughput" : 3523.2443276163354,
    "receivedKBytesPerSec" : 6742.5854313636655,
    "sentKBytesPerSec" : 17755.69618269044
  },
  "Total" : {
    "transaction" : "Total",
    "sampleCount" : 420000,
    "errorCount" : 0,
    "errorPct" : 0.0,
    "meanResTime" : 28.587066666666377,
    "medianResTime" : 21.0,
    "minResTime" : 3.0,
    "maxResTime" : 1047.0,
    "pct1ResTime" : 33.0,
    "pct2ResTime" : 42.0,
    "pct3ResTime" : 91.0,
    "throughput" : 7050.487201721321,
    "receivedKBytesPerSec" : 10029.462602931422,
    "sentKBytesPerSec" : 25838.390589358223
  }
}
</pre>
</details>

<details>
  <summary>E2E Results</summary>
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
  <summary>Typology Results</summary>
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

<details>
  <summary>Rule Results</summary>
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

**AZURE USAGES**
[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/92XuxzdOAWPsdQBu-image-1718102843061.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/92XuxzdOAWPsdQBu-image-1718102843061.png)

[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/MNeS0Fm9LjZUEZa6-image-1718102869445.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/MNeS0Fm9LjZUEZa6-image-1718102869445.png)

[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/10mvNFUScQ3S9rfa-image-1718102892401.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/10mvNFUScQ3S9rfa-image-1718102892401.png)

[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/V4BS0DWK8LQA2JDV-image-1718102963680.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/V4BS0DWK8LQA2JDV-image-1718102963680.png)

[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/PsgTpPDfIV5XRcaS-image-1718102911817.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/PsgTpPDfIV5XRcaS-image-1718102911817.png)

[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/QObTNmCk4ebknonl-image-1718103083149.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/QObTNmCk4ebknonl-image-1718103083149.png)

[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/fy8fNjaAnxcFuPPo-image-1718103103693.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/fy8fNjaAnxcFuPPo-image-1718103103693.png)

[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/XSxF1vEUzl6hp36Z-image-1718103129008.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/XSxF1vEUzl6hp36Z-image-1718103129008.png)

[![](https://developer.sybrin.com/uploads/images/gallery/2024-06/scaled-1680-/4JmCKDUmyEEmFHWB-image-1718103150269.png)](https://developer.sybrin.com/uploads/images/gallery/2024-06/4JmCKDUmyEEmFHWB-image-1718103150269.png)

## Conclusions and Recommendations
The Tazama project's Azure Cloud servers provide a robust environment for testing and benchmarking the anti-fraud and money laundering system. The use of K8s facilitates efficient management of various critical applications, ensuring high performance and reliability during benchmarking.

The performance test results indicate that while ArangoDB is capable of handling high volumes of write operations efficiently, read queries present a significant challenge. 

**To mitigate these issues, the following actions are recommended:**
- **Further Investigation:** Indexing strategies to identify specific causes of read query delays.
- **Index Optimization:** Review and optimize indexes for the splitDB environment to see if arango uses all indexes , the first one picked up or the best index.
- **Different VM for Pseudonyms:** Look into using the H-Series VM which is high performance vm for the database that gets used the most.
- **Networking:** Research if networking between the different vms could cause a delay.