# Node.js V8 Settings and Performance Optimization

Node.js is a powerful JavaScript runtime that uses the V8 JavaScript engine, developed by Google. To ensure optimal performance and memory management for your Node.js applications, it's crucial to understand and configure various V8 settings. This document will explain the most important V8 settings and provide insights into their impact on your Node.js application's performance.

## V8 Memory Settings

### --max-old-space-size

This parameter sets the maximum size of the old generation heap in megabytes. The old generation heap stores long-lived objects, and adjusting this value can significantly impact memory usage. For instance, on a machine with 2 GiB of memory, setting it to 1536 (1.5 GiB) leaves memory for other tasks and avoids swapping.

**Default value:** 2GB

### --max-semi-space-size

Specifies the maximum size of the young generation heap in megabytes. The young generation heap stores short-lived objects. To optimize memory usage for your application, experiment with different values when benchmarking.

**Default value:** 16 MiB for 64-bit systems, 8 MiB for 32-bit systems

## V8 Performance Settings

### --optimize-for-size

Instructs V8 to optimize memory usage, but this might impact execution speed. It's essential for applications with stringent memory constraints.

**Default:** false

```
/nodejs/bin/node: --optimize-for-size= is not allowed in NODE_OPTIONS
```

### --always-opt

Forces V8 to always try to optimize functions, which can enhance execution speed.

**Default:** false

```
/nodejs/bin/node: --always-opt= is not allowed in NODE_OPTIONS
```

### --nouse-idle-notification (Not available in v20)

Instructs V8 not to call the IdleNotification function when the system is idle. This option may not be available in certain versions of Node.js.

## Garbage Collection Settings

### --expose-gc

This option exposes V8's manual garbage collection function in your Node.js code. It's useful when you need to trigger garbage collection manually for specific scenarios.

**Default:** false

```
/nodejs/bin/node: --expose-gc= is not allowed in NODE_OPTIONS
```

### --gc-interval

Forces garbage collection to occur after a specified number of allocations. Adjust this value as needed for your application's memory management.

**Default:** -1

```
/nodejs/bin/node: --gc-interval= is not allowed in NODE_OPTIONS
```

## libuv Settings

### UV_THREADPOOL_SIZE

Although not a command-line parameter, this environment variable sets the size of libuv's thread pool, which handles asynchronous I/O operations. Increasing this value can benefit I/O-heavy applications.

## Cluster Module

Node.js provides a built-in cluster module that takes advantage of multi-core systems. By creating multiple child processes (workers) that share the same port, you can improve the performance of CPU-bound applications.

## Miscellaneous

### --trace-sync-io

Prints a warning and a stack trace whenever your application uses a synchronous API call. Use this flag to identify performance bottlenecks related to blocking operations.

### --no-deprecation

Suppresses deprecation warnings. While this won't directly impact performance, it can clean up logs and enhance visibility for other potential issues.

### Additional Flags for Performance Tuning

- **--turbo-inline**: Enables inlining of functions, potentially improving performance but increasing code size.

- **--turbo-optimize-basic-blocks**: Optimizes basic blocks heavily to enhance execution speed, at the potential cost of higher memory usage.

- **--turbo-short-paths**: Optimizes short paths in the code for improved execution speed, possibly using more CPU.

- **--max-opt-inlined-notify**: Specifies the maximum number of inlined functions before V8 emits a notification, influencing inlining decisions.

- **--max-inlined-source-size**: Specifies the maximum source size considered for inlining, helping control code size.

- **--max-inlined-uses**: Specifies the maximum number of uses of a function before it's inlined, influencing inlining decisions.

- **--trace-turbo**: Enables tracing of TurboFan, V8's optimizing compiler operations, aiding optimization behavior analysis.

## Allowed V8 Options

Node.js allows several additional V8 options that can impact performance and behavior. Consider these options based on your specific requirements:

- --abort-on-uncaught-exception
- --disallow-code-generation-from-strings
- --enable-etw-stack-walking (Windows only)
- --huge-max-old-generation-size
- --interpreted-frames-native-stack
- --jitless
- --max-old-space-size
- --max-semi-space-size
- --perf-basic-prof-only-functions (Linux only)
- --perf-basic-prof (Linux only)
- --perf-prof-unwinding-info (Linux only)
- --perf-prof (Linux only)
- --stack-trace-limit

By understanding and fine-tuning these Node.js V8 settings and options, you can optimize the performance and memory usage of your Node.js applications for various use cases and hardware configurations. Experiment with different values and configurations to find the best settings for your specific application requirements.

[https://nodejs.org/api/v8.html](https://nodejs.org/api/v8.html)  
[https://nodejs.org/api/cli.html](https://nodejs.org/api/cli.html)  
[https://stackoverflow.com/questions/43585185/node-max-old-space-size-is-not-working](https://stackoverflow.com/questions/43585185/node-max-old-space-size-is-not-working)  
[https://medium.com/the-node-js-collection/node-js-memory-management-in-container-environments-7eb8409a74e8](https://medium.com/the-node-js-collection/node-js-memory-management-in-container-environments-7eb8409a74e8)  
[https://stackoverflow.com/questions/56742334/how-to-use-the-node-options-environment-variable-to-set-the-max-old-space-size-g](https://stackoverflow.com/questions/56742334/how-to-use-the-node-options-environment-variable-to-set-the-max-old-space-size-g)
