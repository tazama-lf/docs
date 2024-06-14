<!-- SPDX-License-Identifier: Apache-2.0 -->

# Performance: a journey

- [Performance: a journey](#performance-a-journey)
  - [The ask](#the-ask)
  - [First - how](#first---how)
  - [Second - issues](#second---issues)
    - [One - scaling is great but…](#one---scaling-is-great-but)
  - [Topics](#topics)

## The ask

We set out to build a fraud and risk management system that’s able to both run on laptop and scale up to handle 3000 financial transactions per second, within 35ms time spent per transaction.

For Mojaloop a financial transaction is made up of 4 different related ISO messages in the Tazama platform - Pain.001, Pain.013, Pacs.008 and Pacs.002. So 3K FTPS = 12K TPS going to the platform.

What this means in terms of events flowing through our system, below are some indications as to how many messages would be flowing through the tools our application uses, namely Arango (database), Nats (events) and Redis (cache).

This is to state the amount of interactions to the different services during a Financial Transaction lifespan.  <br>*This expects all config-caching to have happened (eg, not cold start)

|              |                            |     |              |     |     |     |     |
| ------------ | -------------------------- | --- | ------------ | --- | --- | --- | --- |
| # rules      | 31                         |     | # Rules/Typo | 10  |     |     |     |
| # typologies | 31                         |     |              |     |     |     |     |
|              | Interactions per Processor |     |              |     |     |     |     |

|               | TMS                        | CRSP | Rules        | TP  | TADP | **Per transaction** | **@ 3K TPS**  |
| ------------- | -------------------------- | ---- | ------------ | --- | ---- | ------------------- | ------------- |
| Redis Reads   | 2                          | 1    | 0            | 341 | 31   | **375**             | **1 125 000** |
| Redis Writes  | 2                          | 0    | 0            | 310 | 31   | **343**             | **1 029 000** |
| Nats Reads    | 0                          | 2    | 31           | 31  | 31   | **95**              | **285 000**   |
| Nats Writes   | 2                          | 31   | 31           | 31  | 1    | **96**              | **288 000**   |
| Arango Reads  | 3                          | 0    | 31           | 0   | 0    | **34**              | **102 000**   |
| Arango Writes | 6                          | 0    | 0            | 0   | 1    | **7**               | **21 000**    |

## First - how

How do you submit 3K Financial transactions, or 12K related messages, to a system per second over a period of time, in order? You need to submit the Pain.001, wait for it to be done, then submit the Pain.013 that’s related to the Pain.001 (shared accounting information, debtor, creditor, end-to-end ID, etc.), then the pacs.008 and finally the pacs.002 that will be evaluated by the system for fraud.

If you work with a pre-set list of transactions, the tool used to do load test needs to be able to read these messages from a file. Let’s say we’d like to run the tool for 5 minutes. That would be 5 min x60 seconds x3000 financial transactions x4 message = 3 600 000 messages in a file. Reading such a big file is going to take some time. Furthermore, to achieve 12K messages per second, means we’ll need some sort of concurrency. Reading a flat file from multiple different threads and not duplicating will be challenging. In one of our earlier attempts at achieving this task, we went this route, ending up with multiple smaller files, so that each thread of the load testing tool used to submit the data to the platform can read its own file with the pre-created files.

Since this approach is very rigid we had to move away from this approach. So what we ended up with is a JMeter test suite that generates 4 related messages and sends them in order. This approach allowed us to dynamically scale the amount of JMeter threads and instances scaled across multiple nodes in a Kubernetes instance able to send the large amount of messages per second to the platform.

That’s a good start - now we’ve got a tool capable of sending this large amount of messages to our system and effectively load test. Once we start running, we’ve experienced some issues.

## Second - issues

### One - scaling is great but…

Having multiple working microservices in a deployment, each doing variant amount of work, all competing for the same hardware, means it is very difficult to know how many instances of each of the different processors are required to effectively spread hardware consumption across the processors that are required to have end-to-end working.

To explain this, this have an example where JMeter is submitting transactions to the TMS API at the required rate

## Topics

Scaling:

Arango Cluster vs Arango Standalone

Redis Cluster

Indexes

HTTP-chain vs Nats

Json vs JsonSerialization

Bun
