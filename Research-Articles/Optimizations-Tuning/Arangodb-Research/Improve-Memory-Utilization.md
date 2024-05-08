# Improve Memory Utilization

### Server Queue settings

ArangoDB out of the box has a set default queue sizes

**Priority 1 Queue (Max Priority) is defaulted to 4096 - Suggested for large scale: try 8192**

```
--server.prio1-size
```

**Priority 2 Queue (Medium Priority) is defaulted to 4096 - Suggested for large scale: try 8192**

```
--server.prio2-size
```

**Priority 3 Queue (Low/Normal Priority) is defaulted to 4096 - Suggested for large scale: try 8192**

```
--server.maximal-queue-size
```

**There is also the scheduler queue size (also defaulted to 4096) - Suggested for large scale: try 8192**

The number of simultaneously queued requests inside the scheduler

```
--server.scheduler-queue-size 
```

There are also some options that can be tweaked that may improve timeouts and CPU usage

**The memory threshold for all AQL queries combined (defaulted to be dynamic based on available memory) - Suggested to keep as but take note of if need arise for query memory demands**

```
--query.global-memory-limit
```

“Whether to automatically (re-)fill the in-memory index caches with entries from edge indexes and cache-enabled persistent indexes on insert/update/replace/remove operations by default” **(off by default, suggest to put on but monitor)**

```
--rocksdb.auto-refill-index-caches-on-modify
```

Also to load indexes caches in memory on startup **(def: off, Suggested to turn on)**

Note: Indexes are created to be stored in cache during POSTMAN setup using the `cacheEnabled:true` property

```
--rocksdb.auto-fill-index-caches-on-startup
```

And in high intensive situations like our performance can be improved by turning off statistics which periodically take CPU and Memory loads **(true by default)** - **Suggested to turn off**

```
--server.statistics 
```

increase the amount of memory before disk write **(default 64mb, Suggested to try 1GB)**

```
--rocksdb.write-buffer-size
```

maximum number of write buffers that build up in memory before flushing **(def 10, try 10 x 1GB as above)**

**Current: 64MB; Suggestion: 1GB**

```
--rocksdb.max-write-buffer-number
```

Learn more here

[https://www.arangodb.com/docs/stable/programs-arangod-options.html](https://www.arangodb.com/docs/stable/programs-arangod-options.html)

and related Rocksdb tuning insights

[https://github.com/EighteenZi/rocksdb\_wiki/blob/master/RocksDB-Tuning-Guide.md](https://github.com/EighteenZi/rocksdb_wiki/blob/master/RocksDB-Tuning-Guide.md)

## Additional

*   `--server.maximal-threads`: This configuration parameter specifies the maximum size of the thread pool. The default value is set to 64.

Docstring about scheduler and queues

[https://github.com/arangodb/arangodb/blob/3.11.1/arangod/Scheduler/SchedulerFeature.cpp](https://github.com/arangodb/arangodb/blob/3.11.1/arangod/Scheduler/SchedulerFeature.cpp)

Snippet on how thread count and scheduler queues go hand in hand to throttle throughput.

“There are some countermeasures built into  
Coordinators to prevent a cluster from being overwhelmed by too many  
concurrently executing requests.

If a request is executed on a Coordinator but needs to wait for some operation  
on a DB-Server, the operating system thread executing the request can often  
postpone execution on the Coordinator, put the request to one side and do  
something else in the meantime. When the response from the DB-Server arrives,  
another worker thread continues the work. This is a form of asynchronous  
implementation, which is great to achieve better thread utilization and enhance  
throughput.

On the other hand, this runs the risk that work is started on new requests  
faster than old ones can be finished off. Before version 3.8, this could  
overwhelm the cluster over time, and lead to out-of-memory situations and other  
unwanted side effects. For example, it could lead to excessive latency for  
individual requests.

There is a limit as to how many requests coming from the low priority queue  
(most client requests are of this type), can be executed concurrently.  
The default value for this is 4 times as many as there are scheduler threads  
(see `--server.minimal-threads` and --server.maximal-threads), which is good  
for most workloads. Requests in excess of this are not started but remain on  
the scheduler's input queue (see `--server.maximal-queue-size`).

Very occasionally, 4 is already too much. You would notice this if the latency  
for individual requests is already too high because the system tries to execute  
too many of them at the same time (for example, if they fight for resources).

On the other hand, in rare cases it is possible that throughput can be improved  
by increasing the value, if latency is not a big issue and all requests  
essentially spend their time waiting, so that a high concurrency is acceptable.  
This increases memory usage, though.”

**Recommend: Use of VelocyPacks** [https://github.com/arangodb/velocystream](https://github.com/arangodb/velocystream)
