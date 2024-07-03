# Arango clustering Discussion Outcomes

# Table of Contents
1. [Introduction](#introduction)
2. [Participants](#participants)
3. [Coordinator Load Balancing](#coordinator-load-balancing)
4. [Handling "Lost" Writes in Clusters](#handling-lost-writes-in-clusters)
5. [SmartGraphs for Improved Scalability](#smartgraphs-for-improved-scalability)
6. [Performance Profiling](#performance-profiling)
7. [ArangoDB Random Data and Load Generator - 'feed'](#arangodb-random-data-and-load-generator---feed)
8. [Scaling and Metrics](#scaling-and-metrics)
9. [Enhanced Read Scalability with Dirty Reads in ArangoDB](#enhanced-read-scalability-with-dirty-reads-in-arangodb)
10. [Cluster Rebalancing in ArangoDB](#cluster-rebalancing-in-arangodb)
11. [Conclusion](#conclusion)

## Introduction

This document summarizes the outcomes of a productive discussion held with the ArangoDB team focusing on the optimization and scaling of ArangoDB clusters. The session involved a collaborative effort to address challenges and identify solutions related to coordinator load balancing, handling of "lost" writes, and the implementation of SmartGraphs for improved scalability.

## Participants:

- Kyle Vorster
- Johannes Foley
- Kaveh Vahedipour

## Coordinator Load Balancing

Our ArangoDB cluster has encountered a bottleneck due to disproportionate load on one of the coordinators, resulting in uneven performance and potential risks of a single point of failure. To mitigate this, we are considering a multi-pronged approach that includes:

- Implementing a round-robin scheduling mechanism ie:Loadbalancer to distribute incoming requests evenly across coordinators.
- Monitoring workload patterns to identify coordinator usage.
- Scaling horizontally by adding more coordinator nodes to the cluster to handle increased demand.

## Handling "Lost" Writes in Clusters

"Lost" writes represent a critical issue where write operations do not successfully replicate across all necessary nodes, potentially leading to data inconsistency. The discussion highlighted:

- The need for improved logging to capture and diagnose instances of "lost" writes.
- Error handling on coordinators to prevent data loss.
- Enhancing the replication to ensure higher consistency guarantees during coordinator failures.

## SmartGraphs for Improved Scalability

SmartGraphs offer a way to optimize query performance in distributed graph databases by ensuring related data is co-located on the same machine. Key points include:

- The importance of structuring data into SmartGraphs, particularly when scaling to larger datasets.
- The steps required to convert existing graph structures into SmartGraphs, preserving data integrity and minimizing downtime.
- The long-term benefits of SmartGraphs in terms of query performance and overall system efficiency.

Example of the restructuring:

```bash
{
  "_id":"edge/+49-1725310+49-11111111",
  "_key":"+49-1725310+49-11111111"
}

{
  "_id":"1725310",
  "cc":"+49"
}
{
  "_id":"9725954444",
  "cc":"+1"
}

{
  "_id":"edge/+49:17253109725954444:+1",
  "_key":"+49:17253109725954444:+1"
}
```

[Transforming Graph to SmartGraph](https://arangodb.com/learn/graphs/transforming-graph-to-smartgraph/)

## Performance Profiling

Performance profiling is essential to understand the bottlenecks and optimize the cluster's resources. The team agreed on:

- The use of ArangoDB's built-in profiling tools to gather performance data.
- Regularly scheduled profiling to track the cluster's performance over time.
- Sharing and discussing profiling outputs on Slack to make scaling decisions.

This section was checked yesterday and was not by Kaveh that the profiling on our queries looked fine.

[Query Profiling](https://docs.arangodb.com/3.10/aql/execution-and-performance/query-profiling/)

## ArangoDB Random Data and Load Generator - 'feed'

The ArangoDB 'feed' utility is a powerful tool designed to facilitate performance testing and benchmarking for ArangoDB deployments. It provides developers and database administrators with the capability to generate random datasets and simulate load on an ArangoDB server, allowing them to analyze and optimize the performance characteristics of their databases.

Key Features:

- Data Generation: 'feed' can create structured random data adhering to specified schemas, enabling users to populate collections with a variety of data types and structures.
- Load Simulation: It simulates both read and write operations, making it possible to understand how the database performs under different levels of demand.
- Customizable Workflows: Users can customize the tool to generate specific types of data or simulate particular types of load, aligning the testing environment closely with real-world use cases.
- Scalability Testing: By adjusting the volume and velocity of data generation and load, 'feed' helps in testing the scalability of ArangoDB clusters.
- Ease of Use: It is easy to set up and use, with a configuration that can be as simple or as detailed as needed, depending on the complexity of the test scenarios.

[ArangoDB 'feed' Utility](https://github.com/arangodb/feed)

## Scaling and Metrics

Scaling the ArangoDB cluster to accommodate growing data and workload demands is a priority. Our discussion concluded that:

- Key performance metrics such as request latency, throughput, and error rates must be continuously monitored.
- Decisions on when to scale should be based on these metrics, ensuring that performance remains within acceptable thresholds.
- Both vertical and horizontal scaling strategies should be explored, with a preference for horizontal scaling to improve redundancy and fault tolerance. And the scaling of TMS to monitor performance and thread count.

## Enhanced Read Scalability with Dirty Reads in ArangoDB

ArangoDB introduces the concept of "dirty reads," a feature that allows for increased read throughput by permitting reads directly from follower instances in a replicated setup. This capability is particularly beneficial in scenarios where read performance is critical and where eventual consistency is acceptable.

Key Advantages:

- Increased Read Throughput: By allowing reads from followers, the load is distributed across more instances, effectively increasing the read capacity of the system.
- Lower Latency: In geographically distributed clusters, dirty reads can reduce latency by allowing reads from the nearest replica rather than waiting for the leader.
- Flexibility: Users have the option to choose between strict consistency or higher performance based on their application's requirements.

However, it's important to note that dirty reads might return stale data since the follower may not be fully synchronized with the leader at the time of the read. This trade-off between consistency and performance needs to be considered when using dirty reads.

[Active Failover Administration](https://docs.arangodb.com/3.11/deploy/active-failover/administration/)
[Operational Factors](https://docs.arangodb.com/3.11/develop/operational-factors/)

## Cluster Rebalancing in ArangoDB

Cluster rebalancing is a crucial aspect of managing an ArangoDB deployment to ensure optimal distribution of data and workload across the cluster. The rebalance operation can be triggered via a specific HTTP API endpoint as documented in the ArangoDB manual.

Rebalancing Process:

- API Call: The /_admin/cluster/rebalance API endpoint is used to initiate the rebalancing process.
- Data Redistribution: Rebalancing involves moving shards between different DBServers to optimize the distribution based on current cluster usage and capacity.
- Enhanced Performance: A well-balanced cluster leads to improved performance by avoiding overloaded nodes and ensuring that each node has an appropriate share of the workload.

Use Cases:

- After adding new nodes to a cluster, a rebalance operation can redistribute shards to utilize the additional capacity.
- Periodically triggering rebalancing can maintain optimal performance as data grows and access patterns change.

[Cluster Rebalance](https://docs.arangodb.com/3.12/develop/http-api/cluster/#rebalance)

Using the rebalance API, ArangoDB administrators can maintain an efficient and high-performing cluster, ensuring that the database infrastructure scales effectively with the needs of their applications.

## Conclusion

The discussion with the ArangoDB team was informative in laying out the next steps for enhancing the performance and scalability of our cluster. Action items include implementing load balancing strategies, preparing for the adoption of SmartGraphs, and establishing a rigorous performance profiling routine. Follow-up discussions will be conducted on Slack to monitor progress and adjust strategies as needed.