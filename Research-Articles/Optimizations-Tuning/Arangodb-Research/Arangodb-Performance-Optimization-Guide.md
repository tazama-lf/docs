# ArangoDB Performance Optimization Guide

- [ArangoDB Performance Optimization Guide](#arangodb-performance-optimization-guide)
  - [Introduction](#introduction)
  - [Server Queue Configurations](#server-queue-configurations)
    - [High Priority Queue (Priority 1)](#high-priority-queue-priority-1)
    - [Medium Priority Queue (Priority 2)](#medium-priority-queue-priority-2)
    - [Low/Normal Priority Queue (Priority 3)](#lownormal-priority-queue-priority-3)
    - [Scheduler Queue Size](#scheduler-queue-size)
  - [Memory and Cache Optimizations](#memory-and-cache-optimizations)
    - [AQL Query Memory Limit](#aql-query-memory-limit)
    - [RocksDB Index Caches](#rocksdb-index-caches)
    - [Statistics](#statistics)
    - [Write Buffer Size](#write-buffer-size)
    - [Max Write Buffer Number](#max-write-buffer-number)
  - [Additional ArangoDB Settings on Azure infrastructure](#additional-arangodb-settings-on-azure-infrastructure)
    - [-server.session-timeout=36000000](#-serversession-timeout36000000)
    - [-server.authentication=true](#-serverauthenticationtrue)
    - [-javascript.v8-max-heap=800000000](#-javascriptv8-max-heap800000000)
    - [-cache.size=100000000000](#-cachesize100000000000)
    - [-query.memory-limit=1000000000000](#-querymemory-limit1000000000000)
    - [-query.global-memory-limit=1000000000000](#-queryglobal-memory-limit1000000000000)
    - [-query.cache-entries-max-size=80000000000](#-querycache-entries-max-size80000000000)
    - [-query.cache-mode=on](#-querycache-modeon)
    - [-rocksdb.block-cache-size=80000000000](#-rocksdbblock-cache-size80000000000)
    - [-server.io-threads=192](#-serverio-threads192)
    - [-server.maximal-queue-size=2000000](#-servermaximal-queue-size2000000)
    - [-server.maximal-threads=192](#-servermaximal-threads192)
    - [-server.scheduler-queue-size=192](#-serverscheduler-queue-size192)
    - [-rocksdb.write-buffer-size=10737418240](#-rocksdbwrite-buffer-size10737418240)
  - [Additional ArangoDB Settings on Local infrastructure](#additional-arangodb-settings-on-local-infrastructure)
    - [Explanation of Changes](#explanation-of-changes)
    - [-server.session-timeout=36000000](#-serversession-timeout36000000-1)
    - [-server.authentication=true](#-serverauthenticationtrue-1)
    - [-javascript.v8-max-heap=2147483647](#-javascriptv8-max-heap2147483647)
    - [-cache.size=50000000000](#-cachesize50000000000)
    - [-query.memory-limit=30000000000](#-querymemory-limit30000000000)
    - [-query.global-memory-limit=100000000000](#-queryglobal-memory-limit100000000000)
    - [-query.cache-entries-max-size=10000000000](#-querycache-entries-max-size10000000000)
    - [-query.cache-mode=on](#-querycache-modeon-1)
    - [-rocksdb.block-cache-size=50000000000](#-rocksdbblock-cache-size50000000000)
    - [-server.io-threads=40](#-serverio-threads40)
    - [-server.maximal-queue-size=1000000](#-servermaximal-queue-size1000000)
    - [-server.maximal-threads=40](#-servermaximal-threads40)
    - [-server.scheduler-queue-size=40](#-serverscheduler-queue-size40)
    - [-rocksdb.write-buffer-size=15000000000](#-rocksdbwrite-buffer-size15000000000)
  - [Azure Virtual Machine Settings](#azure-virtual-machine-settings)
  - [Local Virtual Machine Settings](#local-virtual-machine-settings)
  - [References](#references)

## Introduction

This guide is designed for optimizing ArangoDB performance in high-capacity server environments. We focus on two distinct configurations: a primary server with 377.54 GB of RAM and 96 vCPUs, and local testing servers equipped with 200 GB of RAM and 40 CPUs. These specifications provide a robust foundation for high-performance configurations and allow for effective testing and scaling strategies.

## Server Queue Configurations

ArangoDB processes requests through various priority queues. These queues ensure that critical tasks are not starved by lower-priority tasks. For systems with large-scale operations, default queue sizes may be insufficient, leading to potential bottlenecks.

### High Priority Queue (Priority 1)

- **Default Size**: 4096
- **Optimized Size**: 8192 (`--server.prio1-size=8192`)
- **Purpose**: This queue serves the most critical operations that should be processed with minimal delay.
- **Expected Outcome**: Doubling the default size can reduce wait times for high-priority tasks, improving response times for critical operations.

### Medium Priority Queue (Priority 2)

- **Default Size**: 4096
- **Optimized Size**: 8192 (`--server.prio2-size=8192`)
- **Purpose**: This queue handles operations of medium importance.
- **Expected Outcome**: Increasing the size helps in balancing load, preventing medium priority tasks from being delayed by high-volume low-priority tasks.

### Low/Normal Priority Queue (Priority 3)

- **Default Size**: 4096
- **Optimized Size**: 8192 (`--server.maximal-queue-size=8192`)
- **Purpose**: Regular client requests and non-critical operations are managed here.
- **Expected Outcome**: An enlarged queue ensures that even during spikes in low-priority traffic, tasks are not excessively queued, reducing the risk of timeouts and enhancing throughput.

### Scheduler Queue Size

- **Default Size**: 4096
- **Optimized Size**: 8192 (`--server.scheduler-queue-size=8192`)
- **Purpose**: It dictates the number of requests that can be queued within the scheduler awaiting processing.
- **Expected Outcome**: With an increased size, the scheduler can handle a larger number of simultaneous requests, which is essential for high-traffic environments.

## Memory and Cache Optimizations

Proper utilization of available memory can significantly impact database performance, especially for in-memory operations and caching.

### AQL Query Memory Limit

- **Setting**: `--query.global-memory-limit`
- **Default Behavior**: Dynamically set based on available memory.
- **Recommendation**: Monitor queries to determine if the dynamic limit suffices. Adjust manually if necessary to prevent out-of-memory errors or to allocate more memory to queries.
- **Expected Outcome**: Properly configured memory limits prevent individual queries from consuming excessive memory while ensuring enough resources are allocated for complex operations.

### RocksDB Index Caches

- **Auto-Refill on Modify**: `--rocksdb.auto-refill-index-caches-on-modify=true`
  - **Purpose**: Automatically refreshes index caches after insert/update/replace/remove operations.
  - **Expected Outcome**: Can lead to faster subsequent read operations due to preloaded cache, but should be monitored for memory usage.
- **Auto-Fill on Startup**: `--rocksdb.auto-fill-index-caches-on-startup=true`
  - **Purpose**: Loads index caches into memory during system startup.
  - **Expected Outcome**: Provides faster access to indexes post-startup, improving initial read performance at the cost of increased startup time.

### Statistics

- **Setting**: `--server.statistics=false`
- **Purpose**: Disabling server statistics can free up resources that are otherwise used for gathering and storing statistical data.
- **Expected Outcome**: Can reduce CPU and memory load, potentially improving overall performance, especially noticeable in systems under high load.

### Write Buffer Size

- **Setting**: `--rocksdb.write-buffer-size`
- **Default**: 64MB
- **Optimized Value**: 1GB (`--rocksdb.write-buffer-size=1073741824`)
- **Purpose**: Defines the amount of data to buffer before committing it to disk.
- **Expected Outcome**: Larger buffers can improve write performance but require careful monitoring of memory usage.

### Max Write Buffer Number

- **Setting**: `--rocksdb.max-write-buffer-number`
- **Optimized Value**: 10
- **Purpose**: Determines the number of write buffers allowed before flushing to disk.
- **Expected Outcome**: In conjunction with increased buffer size, allows more data to be held in memory, potentially improving write performance at the cost of higher memory usage.

## Additional ArangoDB Settings on Azure infrastructure

These settings have been fine-tuned to leverage our server's capabilities fully:

```
-server.session-timeout=36000000
-server.authentication=true
-javascript.v8-max-heap=800000000
-cache.size=100000000000
-query.memory-limit=1000000000000
-query.global-memory-limit=1000000000000
-query.cache-entries-max-size=80000000000
-query.cache-mode=on
-rocksdb.block-cache-size=80000000000
-server.io-threads=192
-server.maximal-queue-size=2000000
-server.maximal-threads=192
-server.scheduler-queue-size=192
-rocksdb.write-buffer-size=10737418240
```

### -server.session-timeout=36000000

- **Purpose**: This setting controls the session timeout for the ArangoDB server.
- **Value**: `36000000` (milliseconds) is equivalent to 10 hours.
- **Expected Outcome**: By setting a long session timeout, user sessions will remain active for an extended period without needing re-authentication, which can be beneficial for long-running operations but should be used with caution regarding security practices.

### -server.authentication=true

- **Purpose**: Enables authentication on the ArangoDB server.
- **Value**: `true` means that clients must authenticate themselves to the server.
- **Expected Outcome**: This enhances security by ensuring that only authorized users can access the database. It is a critical setting for production environments.

### -javascript.v8-max-heap=800000000

- **Purpose**: Specifies the maximum heap size for V8 engine instances in bytes.
- **Value**: `800000000` (bytes) is approximately 762.94 MB.
- **Expected Outcome**: This limits the amount of memory that JavaScript actions can consume within ArangoDB, preventing them from using all available server memory. It's a balance between resource availability for scripts and overall system stability.

### -cache.size=100000000000

- **Purpose**: Defines the size of the in-memory cache for documents and collections.
- **Value**: `100000000000` (bytes) is about 93.13 GB.
- **Expected Outcome**: A larger cache size can significantly speed up read operations by storing more data in fast-access memory. However, it's crucial to ensure that the server has enough RAM to handle this without affecting other operations.

### -query.memory-limit=1000000000000

- **Purpose**: Sets the maximum amount of memory that a single AQL query can use.
- **Value**: `1000000000000` (bytes) is approximately 931.32 GB.
- **Expected Outcome**: This high limit allows individual queries to use a substantial amount of memory, which is useful for complex queries but must be monitored to prevent a single query from monopolizing system resources.

### -query.global-memory-limit=1000000000000

- **Purpose**: Determines the global memory threshold for all AQL queries combined.
- **Value**: `1000000000000` (bytes), the same as the per-query limit, suggesting a system designed to handle intensive query workloads.
- **Expected Outcome**: With such a high global limit, multiple concurrent queries can run without memory constraints, but this assumes that the server's RAM can support such demand.

### -query.cache-entries-max-size=80000000000

- **Purpose**: Configures the maximum size for individual cache entries in the AQL query result cache.
- **Value**: `80000000000` (bytes) is around 74.51 GB.
- **Expected Outcome**: Large cache entries enable caching of substantial query results, which can improve the performance of repeated queries. It must be balanced against the total available memory and the size of typical query results.

### -query.cache-mode=on

- **Purpose**: Enables the AQL query results cache.
- **Value**: `on` activates caching, which stores the results of queries and serves them directly for subsequent identical queries.
- **Expected Outcome**: This can lead to performance improvements for frequently executed queries, as results are returned from the cache rather than being recomputed.

### -rocksdb.block-cache-size=80000000000

- **Purpose**: Sets the size of the block cache for the RocksDB storage engine.
- **Value**: `80000000000` (bytes) is about 74.51 GB.
- **Expected Outcome**: The block cache will store frequently accessed data, reducing disk I/O and potentially improving performance for read-heavy workloads.

### -server.io-threads=192

- **Purpose**: Determines the number of threads used for I/O operations, such as network communication.
- **Value**: `192` threads, which is aligned with the number of vCPUs on the server.
- **Expected Outcome**: A high number of I/O threads can increase the server's capacity to handle concurrent network requests, which is beneficial in a high-traffic environment.

### -server.maximal-queue-size=2000000

- **Purpose**: Controls the maximum number of requests that can be queued for processing.
- **Value**: `2000000` requests.
- **Expected Outcome**: This large queue size is meant to accommodate a very high number of simultaneous requests, ensuring that the server can handle peak loads without dropping requests.

### -server.maximal-threads=192

- **Purpose**: Specifies the maximum number of threads available for request handling.
- **Value**: `192` threads, matching the number of I/O threads and vCPUs.
- **Expected Outcome**: This setting allows ArangoDB to utilize all available CPU resources for processing requests, which can increase throughput and reduce latency.

### -server.scheduler-queue-size=192

- **Purpose**: Sets the number of scheduler threads.
- **Value**: `192` threads, presumably to match the server's vCPU count.
- **Expected Outcome**: With a scheduler thread for each vCPU, the server can efficiently manage task scheduling without becoming a bottleneck.

### -rocksdb.write-buffer-size=10737418240

- **Purpose**: Defines the size of RocksDB's write buffer.
- **Value**: `10737418240` (bytes) is 10 GB.
- **Expected Outcome**: A larger write buffer allows more data to be collected before flushing to disk, which can improve write performance but requires monitoring to ensure sufficient memory is available.

Each of these settings has been selected to optimize the performance of ArangoDB given the server's substantial resources. However, they should be implemented incrementally, with careful monitoring and potential adjustment based on the observed impact. Documenting each change's outcome is crucial for understanding the effect of the adjustments and for future reference or troubleshooting.

## Additional ArangoDB Settings on Local infrastructure

These settings have been fine-tuned to leverage our server's capabilities fully:

```
args:
  - '-server.session-timeout=36000000'  # No change needed
  - '-server.authentication=true'      # No change needed
  - '-javascript.v8-max-heap=2147483647'  # No change needed
  - '-cache.size=50000000000'  # Adjusted to 50 GB to balance with other memory uses
  - '-query.memory-limit=30000000000'  # Reduced to 30 GB to prevent single queries from using excessive memory
  - '-query.global-memory-limit=100000000000'  # Increased to 100 GB to allow multiple queries more room
  - '-query.cache-entries-max-size=10000000000'  # Reduced to 10 GB for individual query cache entries
  - '-query.cache-mode=on'  # No change needed
  - '-rocksdb.block-cache-size=50000000000'  # Adjusted to 50 GB, balancing read performance and memory usage
  - '-server.io-threads=40'  # No change needed, aligned with vCPUs
  - '-server.maximal-queue-size=1000000'  # Reduced to 1,000,000 for more reasonable queue sizing
  - '-server.maximal-threads=40'  # Adjusted to match the number of vCPUs
  - '-server.scheduler-queue-size=40'  # No change needed
  - '-rocksdb.write-buffer-size=15000000000'  # Reduced to 15 GB to balance memory usage
```

### Explanation of Changes

1. `-cache.size`: Reduced to 50 GB to ensure a balance between caching and other memory requirements.
2. `-query.memory-limit`: Lowered to 30 GB. This prevents a single query from consuming an excessive portion of the server's memory, thus maintaining overall stability.
3. `-query.global-memory-limit`: Increased to 100 GB. This adjustment allows more headroom for running multiple concurrent queries.
4. `-query.cache-entries-max-size`: Reduced to 10 GB. This change is to optimize the memory utilization per cached query entry, ensuring more efficient usage of the cache space.
5. `-rocksdb.block-cache-size`: Adjusted to 50 GB. This size is large enough to enhance read operations while keeping memory usage in check.
6. `-server.maximal-queue-size`: Decreased to 1,000,000. A smaller queue size can help in managing the load more effectively without overburdening the server.
7. `-server.maximal-threads`: Aligned to 40, matching the number of vCPUs. This provides a one-to-one ratio of threads to vCPUs, optimizing thread management and performance.
8. `-rocksdb.write-buffer-size`: Lowered to 15 GB. This reduction helps balance the memory allocation between write buffer and other functions.

### -server.session-timeout=36000000

- **Purpose**: Controls the session timeout for the ArangoDB server.
- **Value**: 36000000 (milliseconds) is equivalent to 10 hours.
- **Expected Outcome**: This setting maintains long session durations, reducing the need for frequent re-authentication. It's beneficial for long-running operations but should be managed with security considerations in mind.

### -server.authentication=true

- **Purpose**: Enables authentication on the ArangoDB server.
- **Value**: `true` means that clients must authenticate to the server.
- **Expected Outcome**: Enhances security by ensuring database access is restricted to authorized users, crucial for any production environment.

### -javascript.v8-max-heap=2147483647

- **Purpose**: Specifies the maximum heap size for V8 engine instances in bytes.
- **Value**: 2147483647 bytes (~2 GB).
- **Expected Outcome**: Limits the memory usage of JavaScript actions, balancing resource availability and system stability.

### -cache.size=50000000000

- **Purpose**: Defines the size of the in-memory cache for documents and collections.
- **Value**: 50000000000 (bytes) is about 50 GB.
- **Expected Outcome**: Optimizes read operations by storing more data in fast-access memory while maintaining enough RAM for other operations.

### -query.memory-limit=30000000000

- **Purpose**: Sets the maximum memory a single AQL query can use.
- **Value**: 30000000000 (bytes) is approximately 30 GB.
- **Expected Outcome**: Reduces the risk of a single query consuming excessive memory, thus ensuring stability across multiple queries.

### -query.global-memory-limit=100000000000

- **Purpose**: Determines the global memory threshold for all AQL queries combined.
- **Value**: 100000000000 (bytes) is approximately 100 GB.
- **Expected Outcome**: Allows multiple concurrent queries more memory, enabling complex operations without overwhelming the system.

### -query.cache-entries-max-size=10000000000

- **Purpose**: Configures the maximum size for individual cache entries in the AQL query result cache.
- **Value**: 10000000000 (bytes) is around 10 GB.
- **Expected Outcome**: Facilitates caching of substantial query results while balancing the total available memory.

### -query.cache-mode=on

- **Purpose**: Enables the AQL query results cache.
- **Value**: `on`.
- **Expected Outcome**: Improves performance for frequently executed queries by serving results from cache.

### -rocksdb.block-cache-size=50000000000

- **Purpose**: Sets the block cache size for the RocksDB storage engine.
- **Value**: 50000000000 (bytes) is about 50 GB.
- **Expected Outcome**: Enhances read performance by reducing disk I/O, beneficial for read-heavy workloads.

### -server.io-threads=40

- **Purpose**: Determines the number of threads for I/O operations.
- **Value**: 40 threads, aligned with the number of vCPUs.
- **Expected Outcome**: Optimizes the server's ability to handle concurrent network requests efficiently.

### -server.maximal-queue-size=1000000

- **Purpose**: Controls the maximum number of requests that can be queued.
- **Value**: 1000000 requests.
- **Expected Outcome**: Balances load handling capacity with a more reasonable queue size to prevent excessive request queuing.

### -server.maximal-threads=40

- **Purpose**: Specifies the maximum number of threads for request handling.
- **Value**: 40 threads, matching the vCPU count.
- **Expected Outcome**: Allows the server to fully utilize CPU resources for processing requests without overextending resources.

### -server.scheduler-queue-size=40

- **Purpose**: Sets the number of scheduler threads.
- **Value**: 40 threads.
- **Expected Outcome**: Ensures efficient task scheduling, matching one scheduler thread per vCPU.

### -rocksdb.write-buffer-size=15000000000

- **Purpose**: Defines the size of RocksDB's write buffer.
- **Value**: 15000000000 (bytes) is 15 GB.
- **Expected Outcome**: Balances write performance improvement with memory usage, ensuring more data can be buffered before committing to disk.

These adjustments aim to optimize the performance of ArangoDB on your local server, taking into account the specific hardware capabilities and ensuring a balance between different operational needs.

## Azure Virtual Machine Settings

To fully utilize the server's hardware, the following system-level settings are recommended:

- **Memory Mappings**: `sudo sysctl -w "vm.max_map_count=6144000"`

  - **Purpose**: Increases the number of allowed memory mappings, enhancing the database's capability to handle memory-mapped files.

  - **Expected Outcome**: Reduces the likelihood of hitting memory mapping limits, which can improve database file I/O performance.

- **Transparent Huge Pages**: `sudo bash -c "echo madvise /sys/kernel/mm/transparent_hugepage/enabled"`

  - **Purpose**: Controls how the kernel uses huge pages for memory management.

  - **Expected Outcome**: Setting to `madvise` allows ArangoDB to better manage its memory usage, potentially reducing latency and increasing performance.

## Local Virtual Machine Settings

To fully utilize the server's hardware, the following system-level settings are recommended:

- **Memory Mappings**: `sudo sysctl -w "vm.max_map_count=2560000"`

  - **Purpose**: Increases the number of allowed memory mappings, enhancing the database's capability to handle memory-mapped files.

  - **Expected Outcome**: Reduces the likelihood of hitting memory mapping limits, which can improve database file I/O performance.

- **Transparent Huge Pages**: `sudo bash -c "echo madvise /sys/kernel/mm/transparent_hugepage/enabled"`

  - **Purpose**: Controls how the kernel uses huge pages for memory management.

  - **Expected Outcome**: Setting to `madvise` allows ArangoDB to better manage its memory usage, potentially reducing latency and increasing performance.

## References

- [ArangoDB Server Options](https://docs.arangodb.com/3.12/components/arangodb-server/options/)

- [RocksDB Tuning Guide](https://github.com/facebook/rocksdb/wiki/RocksDB-Tuning-Guide)
