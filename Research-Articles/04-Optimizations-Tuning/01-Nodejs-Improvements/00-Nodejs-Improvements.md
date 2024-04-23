# NodeJS improvements

Stories:  
- NodeJS v20 upgrade  
- Monitoring & Profiling Tools: Incorporate monitoring and profiling tools like the Node.js built-in profiler, v8-profiler, node-inspect, or commercial solutions to identify performance bottlenecks.  
  - [https://clinicjs.org/flame/](https://clinicjs.org/flame/)  
- [Design]Protobuff vs Smart Deserialization (use headers on Nats for MsgID + E2E Id, RuleRes, etc)  
  - quick win, use nats headers where possible  
- Use other library for json Serialization [https://www.npmjs.com/package/fast-json-stringify](https://www.npmjs.com/package/fast-json-stringify) <- this / [https://www.npmjs.com/package/fast-json-parse](https://www.npmjs.com/package/fast-json-parse) <- prolly same same as nodejs

```
Logs = aren't using pino.js - for async logging with buffers - put logging in worker process with low-prio
Better threading? <https://github.com/piscinajs/piscina>
  -DP, CRSP, TP 
Fastify instead of Koa
```

- Try during Perf Test:  
    V8 Memory Settings:  
    --max-old-space-size: This parameter sets the maximum size of the old generation heap in megabytes. If you have an application that requires a lot of memory, you may need to tweak this.  
    --max-semi-space-size: Specifies the maximum size of the young generation heap in megabytes.  
    V8 Performance Settings:  
    --optimize-for-size: Instructs V8 to optimize memory usage.  
    --always-opt: Forces V8 to always try to optimize functions.  
    --nouse-idle-notification: Instructs V8 not to call the IdleNotification function when the system is idle.  
    Garbage Collection Settings:  
    --expose-gc: This option exposes the manual garbage collection function of V8 in your Node.js code. It can be useful for scenarios where you want to manually trigger garbage collection.  
    --gc-interval: Forces garbage collection to occur every specified number of allocations.  
    libuv Settings:  
    UV__THREADPOOL__SIZE: While not a command-line parameter, this environment variable sets the size of libuv's thread pool, which handles certain asynchronous I/O operations. The default size is 4, but for I/O-heavy applications, increasing this number might improve performance.  
    Cluster Module: The built-in cluster module in Node.js allows you to take advantage of multi-core systems. By creating multiple child processes (workers) that share the same port, you can improve the performance of CPU-bound applications.  
    Miscellaneous:  
    --trace-sync-io: This will print a warning and a stack trace whenever your application uses a synchronous API call. It can be a good way to catch performance hogs related to blocking operations.  
    --no-deprecation: Suppresses deprecation warnings. It won't improve performance parse, but it can clean up logs and improve visibility on other potential issues.

Beyond Node.js Settings: The performance of a Node.js application doesn't depend solely on V8 or Node.js settings. Other factors include:  
The efficiency of the application code.  
Database interactions and their efficiency.  
External services and APIs the application communicates with.  
Network latency and conditions.  
System and OS-level configurations.

APM = 20-30% overhead

Linux-perf - tweaks to get Cache misses etc
