# Logging Framework Architecture

- [Logging Framework Architecture](#logging-framework-architecture)
  - [Previous Implementation](#previous-implementation)
  - [Current Implementation](#current-implementation)
    - [Overview](#overview)
    - [Payload Details](#payload-details)
    - [High Level Overview](#high-level-overview)

Our logging system has received various overhauls in our development cycles.  
Initially, it was pretty much as you would expect. At each log event in code, a log message is sent to a consumer somewhere, [ELK](https://www.elastic.co/elastic-stack/), in our case.

For our use case, we wanted to keep the log level controllable through an environment variable. `LOGSTASH_LEVEL`.  
Keeping in mind the typical log level hierarchy `trace < debug < info < warn < error`, when we profiled our code in our initial implementation, we discovered that whilst logs below the current configured levels were not sent to our log consumer, they were not completely ignored either.

## Previous Implementation

To make an example: suppose at each log event we have 4 major steps:

- Capture timestamp
- Capture host (where log came from)
- Create log payload (timestamp + host + message)
- Send to consumer  
    Steps 1-3 would still be done for log levels below the current configured one and our profiling tools would expose that. As a result, we refactored our `LoggerService` to flip the level evaluation to be the first task performed when a logging event is encountered.

## Current Implementation  

As logging is not per-se part of the business logic, we thought to offload it to a separate processor that will then batch and send logs to our consumer.  
As part of the refactor, we substituted [log4js](https://github.com/log4js-node/log4js-node) for [pino](https://github.com/pinojs/pino) as the underlying logging engine mainly because of its [performance benefits](https://github.com/pinojs/pino#low-overhead).

### Overview

In terms of implementation, we needed two new microservices

- An `event-sidecar`:
  - A gRPC server which listens for log messages
- A logging service which listens for a particular NATS subject
  - Upon receiving a message, we would then deserialise it and batch/send the logs:

![](../../images/image-20231206-102932.png)

### Payload Details

We wanted to attach a bit of context to our log messages. The overall payload contains:

| **Field** | **Data Type** | **Description** |
| --- | --- | --- |
| `message` | string/text | field which is your typical log message |
| `channel` | string/text | denotes the name of the application generating the log |
| `id` | string/text | identifier for the object being processed to help trace the state of the application when that log was generated |
| `serviceOperation` | string/text | which operation generated the log event (e.g function) |
| `level` | enum (one of the aforementioned log levels) | The log level for the current item |

We opted for this structure to maintain loose coupling between services which in turn makes them more flexible with little to no consequences on functionality. In terms of flexibility, the `event-sidecar` is purely a gRPC server which expects a message in a format it understands, which could come from anywhere, really.  
For example, you aren't confined to the availability of the specific SDKs to get logs in this approach. A simple gRPC request would do.

A processor would then send logs to the `event-sidecar` which would then forward them through to the logging-service.

### High Level Overview

`[tms-service]`

- startup
  - Initialise a logger service
    - Logger service reads the environment for the lowest loglevel
      - For unrequired log levels, no work is done at log events
    - If `sidecarHost` specified
      - Initialise a gRPC client to send logs to gRPC server
- At each log event:
  - if `sidecarHost` is specified:
    - create a callback which sends the data to the gRPC Server
    - gRPC server encodes the message and sends to NATS listener
    - NATS listener batches and emits to consumer
  - If `sidecarHost` is not specified
    - Send logs to consumer directly

Keeping in mind that we would not want to block the event loop along with maintaining the asynchronous nature of the platform, so the entire implementation is callback based.
