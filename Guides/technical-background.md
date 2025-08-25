<!-- SPDX-License-Identifier: Apache-2.0 -->

<a id="top"></a>

# Technical stack background <!-- omit in toc -->

#### Table of Contents <!-- omit in toc -->

- [1.  Background](#1--background)
- [2. Message Ingestion](#2-message-ingestion)
- [3. Message Egress](#3-message-egress)
  - [3.1. Event-flow rule processor output](#31-event-flow-rule-processor-output)
  - [3.2. Typology processor output](#32-typology-processor-output)
  - [3.3	Transaction Aggregation and Decisioning processor (TADProc) output](#33transaction-aggregation-and-decisioning-processor-tadproc-output)

Tazama is an Open Source Software product that is itself composed out of a number of different Open Source Software products to fulfill the needs of the system without having to reinvent all the really great wheels that are already widely in use today. The various components that we use in Tazama can be summarized in this diagram

![tazama role](/images/tazama-role.png)


## Software

| Component        | Purpose                                                                                                                                                                                                                                                                                                                                                      |
|------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **TypeScript**    | Tazama is written in TypeScript, a strictly typed derivative of JavaScript that is ultimately transpiled (a fancy way of saying “translated”) into JavaScript when deployed. JavaScript itself is an interpreted language in that the code that is deployed is readable by both humans and computers.                                                        |
| **Node.js**       | Because JavaScript is an interpreted language, and not a compiled language, it requires an interpreter for the code to be executed. We use Node.js to execute our TypeScript code once it has been transpiled to JavaScript.                                                                                                                              |
| **Fastify**       | We use Fastify in the TMS API to ensure that incoming transactions can be processed with the fastest technology available, and this includes all the validation required to make sure that the submitted transaction is correct and valid.                                                                            |
| **Protocol Buffers** | Tazama is a distributed system with many related components, and these components constantly communicate with each other. The problem is that communication between components is different from communication inside a single component, and each component first needs to package a message in a specific format before it can send that message to another component, and then that recipient needs to unpack that message back into a way that can be interpreted. This process is called serialization and deserialization. In a system such as Tazama where the speed of processing is extremely important, we use Protocol Buffers (commonly called “ProtoBuf”) to perform this task as efficiently as possible. |









## Services


| Component   | Purpose                                                                                                                                                                                                                                                                                                                                                                                                                     |
|-------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **ArangoDB** | Tazama stores transaction history, processor configurations and evaluation results in ArangoDB databases and collections. ArangoDB offers the capability to store JSON documents without transformation, as well as relational and graph databases, in a single database system.                                                                                                                                            |
| **KeyCloak** | Tazama uses KeyCloak for the administration of user and system permissions so that only authorized users and client systems are able to access Tazama data and services.                                                                                                                                                                                                                                                  |
| **NATS**     | Tazama processors communicate with each other using a publish/subscribe architecture which is facilitated with NATS. Each processor publishes its output on a specific NATS subject when its work is completed, and when the next processor needs work, it fetches the work from that subject that it subscribed to.                                                                                                      |
| **Redis**    | Tazama performs many millions of operations per second and to facilitate so much traffic at the speeds required, we use various in-memory caching strategies in our processors through the use of Redis. Redis has unfortunately recently changed its open source license terms and we are in the process of evaluating alternative options.                                         |
| **ValKey**   | ValKey is a fork of an earlier version of Redis when Redis was still considered a fully open source software application. We use ValKey for in-memory cache support in one of our newer components as a trial for replacing Redis across Tazama.                                                                                                                                                                        |

<div style="text-align: right"><a href="#top">Top</a></div>

## Platform

| Component             | Purpose                                                                                                                                                                                                                                                                                                                                                                   |
|------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Docker**             | Tazama is a modular system with a large number of different and distributed components that interact with each other. These components are “containerized” to make their management and maintenance easier. We use Docker for this purpose for testing and exploration.                                                                                                   |
| **Kubernetes**         | The containerized components of Tazama are deployed and orchestrated in production systems via Kubernetes. Kubernetes handles the infrastructure side of Tazama’s operation and allows us to deploy onto various cloud platforms, and even onto an operator’s on-premises hardware, much easier.                                                                         |
| **Amazon Web Services**| We have automated deployment scripts available for the deployment of Tazama onto Amazon Web Services cloud platforms.                                                                                                                                                                                                                                                   |
| **Microsoft Azure**    | We also have automated deployment scripts available for the deployment of Tazama onto Microsoft Azure cloud platforms.                                                                                                                                                                                                                                                  |


<div style="text-align: right"><a href="#top">Top</a></div>

