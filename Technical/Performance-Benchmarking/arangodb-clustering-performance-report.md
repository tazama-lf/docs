# ArangoDB Clustering Performance Report

### Table of Contents

1. [Summary](#summary)
2. [Test Environment](#test-environment)
3. [Test Execution](#test-execution)
   1. [Cluster Configuration & Metrics](#1-cluster-configuration--metrics)
   2. [Queries Performance](#2-queries-performance)
   3. [Write Operations Performance](#3-write-operations-performance)
   4. [Database Scaling](#4-database-scaling)
   5. [Performance Bottlenecks](#5-performance-bottlenecks)
   6. [Indexing Efficiency](#6-indexing-efficiency)
4. [Conclusions and Recommendations](#conclusions-and-recommendations)
5. [Attachments and Supporting Documents](#attachments-and-supporting-documents)
   1. [Processor Results](#processor-results)
   2. [Typology Results](#typology-results)
   3. [Rule Results](#rule-results)
6. [Breakdown of the Redis Cluster Dashboard](#breakdown-of-the-redis-cluster-dashboard)
   1. [What is the Dashboard?](#what-is-the-dashboard)
   2. [Why is it There?](#why-is-it-there)
   3. [Why is it Important?](#why-is-it-important)
   4. [What are You Looking At?](#what-are-you-looking-at)
   5. [What Should You Pay Attention To?](#what-should-you-pay-attention-to)
7. [Breakdown of the NATS Server Dashboard](#breakdown-of-the-nats-server-dashboard)
   1. [What is the Dashboard?](#what-is-the-dashboard-1)
   2. [Why is it There?](#why-is-it-there-1)
   3. [Why is it Important?](#why-is-it-important-1)
   4. [What are You Looking At?](#what-are-you-looking-at-1)
   5. [What Should You Pay Attention To?](#what-should-you-pay-attention-to-1)
8. [Summary of JMeter Test Reports](#summary-of-jmeter-test-reports)
   1. [What is JMeter?](#what-is-jmeter)
   2. [Why Use JMeter?](#why-use-jmeter)
   3. [What to Look Out For?](#what-to-look-out-for)
9. [Breakdown of the ArangoDB Dashboard](#breakdown-of-the-arangodb-dashboard)
   1. [What is the Dashboard?](#what-is-the-dashboard-2)
   2. [Why is it There?](#why-is-it-there-2)
   3. [Why is it Important?](#why-is-it-important-2)
   4. [What are You Looking At?](#what-are-you-looking-at-2)
   5. [What Should You Pay Attention To?](#what-should-you-pay-attention-to-2)
10. [Breakdown of the Arango CPU Utilization Graph](#breakdown-of-the-arango-cpu-utilization-graph)
    1. [What is the Graph?](#what-is-the-graph)
    2. [Why is it There?](#why-is-it-there-3)
    3. [Why is it Important?](#why-is-it-important-3)
    4. [What are You Looking At?](#what-are-you-looking-at-3)
    5. [What Should You Pay Attention To?](#what-should-you-pay-attention-to-3)
11. [Breakdown of the AZURE CPU Utilization Graphs](#breakdown-of-the-azure-cpu-utilization-graphs)
    1. [What are the Graphs?](#what-are-the-graphs)
    2. [Why are they There?](#why-are-they-there)
    3. [Why is it Important?](#why-is-it-important-4)
    4. [What are You Looking At?](#what-are-you-looking-at-4)
    5. [What Should You Pay Attention To?](#what-should-you-pay-attention-to-4)
    6. [Detailed Breakdown of the Graphs](#detailed-breakdown-of-the-graphs)

### Summary

This report presents the findings from the recent performance testing focused on the ArangoDB clustering capabilities. The tests were designed to evaluate the efficiency of read and write operations within a clustered environment, using JMeter as the tool to generate the workload. The main points of consideration were the processing times for read queries, CPU utilization on Azure nodes, write operation throughput and impact of scaling operations. 

### Test Environment

- ArangoDB Cluster vs singe deployment test
- Cluster Configuration: Initially 3 nodes with 96 vCPUs each; scaled to 4 nodes with 96 vCPUs each
- Load Testing Tool: Apache JMeter
- Deployment: Azure Kubernetes Service (AKS)

### Test Execution
#### 1. Cluster Configuration & Metrics:
- The ArangoDB cluster was initially set up with 3 Azure nodes, each with 96 vCPUs. Due to performance concerns (maxing CPU), an additional node was added to the cluster.
- Metrics were gathered from the ArangoDB dashboard, showing CPU usage and other performance-related statistics.
#### 2.	 Queries Performance:
- Processing times for read queries were found to be slow, which correlated with high CPU utilization, causing the cluster to max out the CPU resources causing E2E to be extremely slow.
  - **End-to-End (E2E):** Refers to the overall flow of the system from the initial point of input to the final point of output. The reads in the "Rules" stage from ArangoDB are taking a significant amount of time. This delay causes a bottleneck, slowing down subsequent processors that are waiting for the results to come back from the "Rules" stage. Comparisons in rule times can be seen in this document [performance-benchmarking-of-arangodb-single-instance-vs-split-databases-vs-clustering](https://github.com/frmscoe/docs/blob/main/Technical/Performance-Benchmarking/performance-benchmarking-of-arangodb-single-instance-vs-split-databases-vs-clustering.md) 
  - **High CPU utilization:** High CPU utilization means that the CPU is working at or near its maximum capacity. This is often represented as a percentage, with 85-100% indicating that the CPU is fully utilized .The Arango cluster maxing out the CPU resources,is leading to extreme slowness in the End-to-End (E2E) performance. As the CPU load increased, the read operation latencies also increased, heightening the problem. This high CPU utilization on the VMs can be observed in the attached screenshots at the end of the document.
    - **Effects:**
      - **Slow Performance:** When the CPU is overutilized, other processes will slow down because the CPU cannot allocate enough resources to them.
      - **System Instability:** In extreme cases, the system may become unresponsive or crash which could cause a loss in transactions.
- The Azure metrics indicated that as the CPU load increased, the read operation latencies also increased, leading to performance bottlenecks.
#### 3.	Write Operations Performance:
- JMeter tests showed that write operations to ArangoDB were completed quickly, with an ingestion rate of 2500 to 2700 messages per second.
- All transactions were submitted to the Transaction Monitoring Service (TMS) within a 10-second timeframe, indicating that the writes were not affected by the issues impacting read operations.
#### 4.	Database Scaling:
- To address the performance issues (Slow E2E times reading for Arango), the database instances in the cluster were scaled from 3 pods to 4 pods.
- An additional Azure node was provisioned to host the new database instance, aimed at distributing the load and improving read query performance.
#### 5.	Performance Bottlenecks:
- The Azure results screenshots and attached images show that the rules were taking an extended time to process, which contributed to slow END-TO-END time for an evaluation.
#### 6.	Indexing Efficiency:
- There is a suspicion that the indexing strategies used in the clustered deployment of ArangoDB may not be as efficient as those in single-node deployments, possibly contributing to the slow read operations.
  - Extra context regarding the cluster changes needed: [Arango clustering Discussion Outcomes](https://github.com/frmscoe/docs/blob/main/Technical/Performance-Benchmarking/arango-clustering-discussion-outcomes)

### Conclusions and Recommendations:

The performance test results indicate that while ArangoDB is capable of handling high volumes of write operations efficiently, read queries present a significant challenge when under heavy CPU load on the Arango VM's. The clustering mechanism, while scalable, shows signs of read performance degradation, which can be attributed to CPU saturation and possibly suboptimal indexing strategies.

#### To mitigate these issues, the following actions are recommended:
- **Extra context:** Regarding the cluster changes needed: [Arango clustering Discussion Outcomes](https://github.com/frmscoe/docs/blob/main/Technical/Performance-Benchmarking/arango-clustering-discussion-outcomes)
- **Further Investigation:** Detailed analysis of query execution plans and indexing strategies to identify specific causes of read query delays.
- **Index Optimization:** Review and optimize indexes for the clustered environment.
- **Continuous Scaling:** Consider additional scaling strategies, including vertical scaling of nodes and further cluster expansion.

### Attachments and Supporting Documents:
- ArangoDB Dashboard screenshots
- JMeter test results
- Azure performance metrics screenshots
- JSON files with detailed performance metrics

<details>
  <summary>Processor Results</summary>
<pre language="json">
  {
   "result":[
      {
         "startTime":"2024-03-28T13:15:02.515Z",
         "endTime":"2024-03-28T13:21:34.415Z",
         "amount":105000,
         "elapsed":392,
         "ftps":267.85714285714283,
         "TMSStats":[
            {
               "mn":11.161476,
               "mx":784.881829,
               "ave":44.457376340466666,
               "mea":35.301096,
               "ninety":65.690024,
               "ninetynine":238.222998
            }
         ],
         "CRSPStats":[
            {
               "mn":0.052501,
               "mx":90.344961,
               "ave":0.1183132763047619,
               "mea":0.091403,
               "ninety":0.136903,
               "ninetynine":0.225001
            }
         ],
         "TPStats":[
            {
               "mn":0.044501,
               "mx":227.472723,
               "ave":1.0041135019003553,
               "mea":0.2078085,
               "ninety":0.405313,
               "ninetynine":22.309186
            }
         ],
         "TADPStats":[
            {
               "mn":0.952624,
               "mx":31.293195,
               "ave":1.7074791166190477,
               "mea":1.5033215,
               "ninety":2.148924,
               "ninetynine":5.691743
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
         "httpRequests":464,
         "executionTime":5.608667502001481,
         "peakMemoryUsage":20611072,
         "intermediateCommits":0
      }
   },
   "error":false,
   "code":201
}
</pre>
</details>
<details>
  <summary>Processor Results</summary>
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
  <summary>Typology Results</summary>
<pre language="json">
  [
   [
      {
         "typologyId":"028@1.0.0",
         "pcrgTm":{
            "mn":0.0809,
            "mx":173.323064,
            "ave":0.17915340543809524
         }
      },
      {
         "typologyId":"037@1.0.0",
         "pcrgTm":{
            "mn":0.082301,
            "mx":51.316129,
            "ave":0.18326360012380954
         }
      },
      {
         "typologyId":"044@1.0.0",
         "pcrgTm":{
            "mn":0.072701,
            "mx":227.472723,
            "ave":0.16496033053333334
         }
      },
      {
         "typologyId":"047@1.0.0",
         "pcrgTm":{
            "mn":0.059501,
            "mx":93.978671,
            "ave":0.1400642595047619
         }
      },
      {
         "typologyId":"095@1.0.0",
         "pcrgTm":{
            "mn":0.044501,
            "mx":58.545856,
            "ave":0.11184044790476191
         }
      },
      {
         "typologyId":"185@1.0.0",
         "pcrgTm":{
            "mn":0.0487,
            "mx":45.958193,
            "ave":0.1327220721047619
         }
      }
   ]
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

<details>
  <summary>Rule Results</summary>
<pre language="json">
  [
   [
      {
         "ruleId":"001@1.0.0",
         "pcrgTm":{
            "mn":21.339329,
            "mx":477.944352,
            "ave":31.018268044314283
         }
      },
      {
         "ruleId":"003@1.0.0",
         "pcrgTm":{
            "mn":21.251544,
            "mx":479.191989,
            "ave":31.27721671644762
         }
      },
      {
         "ruleId":"004@1.0.0",
         "pcrgTm":{
            "mn":21.196905,
            "mx":632.200569,
            "ave":31.784640084695237
         }
      },
      {
         "ruleId":"006@1.0.0",
         "pcrgTm":{
            "mn":10.112267,
            "mx":1890.12736,
            "ave":32.08764193958095
         }
      },
      {
         "ruleId":"007@1.0.0",
         "pcrgTm":{
            "mn":3.443925,
            "mx":388.36693,
            "ave":12.292808402133332
         }
      },
      {
         "ruleId":"008@1.0.0",
         "pcrgTm":{
            "mn":3.334114,
            "mx":388.354584,
            "ave":11.91420699017143
         }
      },
      {
         "ruleId":"010@1.0.0",
         "pcrgTm":{
            "mn":3.46432,
            "mx":392.207443,
            "ave":12.08402534009524
         }
      },
      {
         "ruleId":"011@1.0.0",
         "pcrgTm":{
            "mn":3.310315,
            "mx":385.887765,
            "ave":11.608750075838094
         }
      },
      {
         "ruleId":"016@1.0.0",
         "pcrgTm":{
            "mn":3.296412,
            "mx":389.765371,
            "ave":12.231460185247618
         }
      },
      {
         "ruleId":"017@1.0.0",
         "pcrgTm":{
            "mn":3.463321,
            "mx":388.35382,
            "ave":12.029514692600001
         }
      },
      {
         "ruleId":"018@1.0.0",
         "pcrgTm":{
            "mn":14.6859,
            "mx":424.734618,
            "ave":23.893470054828573
         }
      },
      {
         "ruleId":"020@1.0.0",
         "pcrgTm":{
            "mn":10.117864,
            "mx":1912.486291,
            "ave":31.999277784495238
         }
      },
      {
         "ruleId":"021@1.0.0",
         "pcrgTm":{
            "mn":9.851964,
            "mx":1890.124356,
            "ave":32.06444890569524
         }
      },
      {
         "ruleId":"024@1.0.0",
         "pcrgTm":{
            "mn":3.802119,
            "mx":4294.829683,
            "ave":32.89448468813333
         }
      },
      {
         "ruleId":"026@1.0.0",
         "pcrgTm":{
            "mn":1.091464,
            "mx":4287.654347,
            "ave":32.624640254219045
         }
      },
      {
         "ruleId":"030@1.0.0",
         "pcrgTm":{
            "mn":3.311405,
            "mx":387.761816,
            "ave":12.34420683167619
         }
      },
      {
         "ruleId":"044@1.0.0",
         "pcrgTm":{
            "mn":3.305615,
            "mx":389.716295,
            "ave":11.770290693657143
         }
      },
      {
         "ruleId":"045@1.0.0",
         "pcrgTm":{
            "mn":3.378215,
            "mx":387.589307,
            "ave":12.150647252380953
         }
      },
      {
         "ruleId":"048@1.0.0",
         "pcrgTm":{
            "mn":10.159074,
            "mx":414.097193,
            "ave":18.420412353095237
         }
      },
      {
         "ruleId":"063@1.0.0",
         "pcrgTm":{
            "mn":10.098665,
            "mx":410.466732,
            "ave":18.883096074190476
         }
      },
      {
         "ruleId":"076@1.0.0",
         "pcrgTm":{
            "mn":3.401697,
            "mx":387.712515,
            "ave":12.557480001428571
         }
      },
      {
         "ruleId":"083@1.0.0",
         "pcrgTm":{
            "mn":3.344814,
            "mx":388.261316,
            "ave":12.69584471432381
         }
      },
      {
         "ruleId":"084@1.0.0",
         "pcrgTm":{
            "mn":3.130007,
            "mx":389.044047,
            "ave":12.513733201704762
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

![arangodb-clustering-redis1](/images/arangodb-clustering-redis1.png)
![arangodb-clustering-redis2](/images/arangodb-clustering-redis12.png)

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

![arangodb-clustering-nats-server-dashboard](/images/arangodb-clustering-nats-server-dashboard.png)
### Summary of JMeter Test Reports

#### What is JMeter?

Apache JMeter is an open-source software designed to load test functional behavior and measure performance. It is used to simulate a heavy load on a server, group of servers, network, or object to test its strength or to analyze overall performance under different load types.

#### Why Use JMeter?

1. **Performance Testing:** To ensure that the server can handle the expected load without any performance degradation.
2. **Load Testing:** To check the server's ability to handle increasing loads.
3. **Stress Testing:** To determine the server's breaking point or maximum capacity.
4. **Functional Testing:** To validate the correctness of the application's behavior under load.

#### What to Look Out For?

1. **APDEX (Application Performance Index):** Measures the performance of the application based on user satisfaction. It is calculated using a tolerance threshold (T) and a frustration threshold (F).
2. **Requests Summary:** Indicates the pass/fail status of the requests.
3. **Statistics:** Includes details such as the number of samples, error percentage, response times, throughput, and network usage.
4. **Response Times:** Important to measure the time taken to respond to requests.
5. **Throughput:** Indicates the number of transactions handled by the TMS per second.
6. **Network Usage:** Measures the data sent and received during the test.
![arangodb-clustering-jmeter1](/images/arangodb-clustering-jmeter1.png)
![arangodb-clustering-jmeter1](/images/arangodb-clustering-jmeter2.png)
![arangodb-clustering-jmeter1](/images/arangodb-clustering-jmeter3.png)
![arangodb-clustering-jmeter1](/images/arangodb-clustering-jmeter4.png)
![arangodb-clustering-jmeter1](/images/arangodb-clustering-jmeter5.png)
![arangodb-clustering-jmeter1](/images/arangodb-clustering-jmeter6.png)
![arangodb-clustering-jmeter1](/images/arangodb-clustering-jmeter7.png)

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
![arangodb-clustering-arango-dashboard](/images/arangodb-clustering-arango-dashboard.png)
![arangodb-clustering-arango-dashboard2](/images/arangodb-clustering-arango-dashboard2.png)

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
![arangodb-clustering-cpu-rate](/images/arangodb-clustering-cpu-rate.png)

### Breakdown of the AZURE CPU Utilization Graphs

#### What are the Graphs?

These graphs show the CPU utilization for different Virtual Machine Scale Sets (VMSS) in an Azure Kubernetes Service (AKS) cluster. Each graph represents the CPU usage over a specific time period, indicating how different virtual machines (VMs) within the scale sets are performing.

#### Why are they There?

The graphs are used to monitor and visualize the CPU usage of different VMs in the cluster. They help in identifying performance bottlenecks, understanding resource utilization, and ensuring that the cluster is operating efficiently.

#### Why is it Important?

1. **Performance Monitoring:** Helps in tracking CPU usage to identify and resolve performance issues.
2. **Resource Management:** Ensures efficient use of CPU resources across the VMs.
3. **Operational Insights:** Provides insights into the CPU demands of different components of the cluster.

#### What are You Looking At?

- **Max Percentage CPU:** Displays the maximum CPU usage percentage for each VM within the VMSS over time.
- **VMName:** Each line represents a different VM within the VMSS, identified by its name.

#### What Should You Pay Attention To?

1. **CPU Spikes:**
   - Look for any sudden increases in CPU usage which might indicate a performance issue or a spike in demand.
   - High CPU spikes could lead to throttling or degraded performance if not managed properly.

2. **Sustained High CPU Usage:**
   - Identify any VMs with consistently high CPU usage, which may need optimization or scaling.
   - Consistent high usage can indicate that the VM is under heavy load and may benefit from additional resources.

3. **Low CPU Usage:**
   - VMs with consistently low CPU usage might indicate over-provisioning.
   - Consider scaling down or re-allocating resources from underutilized VMs.

4. **Comparative Analysis:**
   - Compare CPU usage across different VMs to identify any outliers.
   - Significant differences in CPU usage might suggest uneven load distribution or specific issues with certain VMs.

### Detailed Breakdown of the Graphs

#### Graph 1: aks-natsvm-32821002-vmss
- **Max Percentage CPU:** 27.71%
- **Observation:** Notable spike around 15:16, indicating a temporary increase in CPU usage.

#### Graph 2: aks-redisvm-3228634-vmss
- **Max Percentage CPU:** 11.23%
- **Observation:** Moderate CPU usage with spikes around 15:16 and a gradual increase towards the end.

#### Graph 3: aks-arangoagent-29738581-vmss
- **Max Percentage CPU:** 1.13%
- **Observation:** Low CPU usage overall, with minor fluctuations.

#### Graph 4: aks-arangococo-21805707-vmss
- **Max Percentage CPU:** 65.11%
- **Observation:** High CPU usage with significant spikes, suggesting heavy load or intensive tasks.

#### Graph 5: aks-arangodb2-14244936-vmss
- **Max Percentage CPU:** 96.13%
- **Observation:** Very high CPU usage, indicating the need for scaling or optimization.

#### Graph 6: aks-crsppool-31592436-vmss
- **Max Percentage CPU:** 25.32%
- **Observation:** Moderate CPU usage with a notable spike around 15:16.

#### Graph 7: aks-tmspool-31166388-vmss
- **Max Percentage CPU:** 52.35%
- **Observation:** High CPU usage with a significant spike, suggesting possible performance issues.

#### Graph 8: aks-tppool-60891139-vmss
- **Max Percentage CPU:** 21.06%
- **Observation:** Moderate CPU usage with notable spikes, indicating varying load levels.

#### Graph 9: aks-rulespool-2207873-vmss
- **Max Percentage CPU:** 43.59%
- **Observation:** Moderate to high CPU usage with a spike around 15:16, indicating fluctuating demand.

#### Graph 10: aks-tadppool-2601946-vmss
- **Max Percentage CPU:** 3.58%
- **Observation:** Low CPU usage overall, with minor fluctuations.

![arangodb-clustering-nats-redis-azure](/images/arangodb-clustering-nats-redis-azure.png)
![arangodb-clustering-arango-azure](/images/arangodb-clustering-arango-azure.png)
![arangodb-clustering-tms-tp-crsp-azure](/images/arangodb-clustering-tms-tp-crsp-azure.png)
![arangodb-clustering-rules-tadp-crsp-azure](/images/arangodb-clustering-rules-tadp-crsp-azure.png)
