# **Tazama Relay Service Stress Testing**

## _Stress Testing Documentation_

**Table of Contents**

- [**Overview**](#overview)

  - [1.1 An Overview of the Document and its Purpose](#11-an-overview-of-the-document-and-its-purpose)

- [**Process**](#process)

  - [2.1 Configuration](#21-configuration)



- [**Results**](#2-system-architecture)

  - [3.1 NATS Results](#31-NATS-results)
  - [3.2 RabbitMQ Results](#32-RabbitMQ-results)
  - [3.3 Kafka Results](#33-RabbitMQ-results)
  - [3.4 REST API Results](#34-RabbitMQ-results)

## **_Overview_**

It is a TypeScript-based service that bridges communication between TMS (Tazama Monitoring Service) and client applications handling transaction processing and analysis.

### 1.1 An Overview of the Document and its Purpose

This documentation provides a complete overview of the stress testing process, including setup details, data generated, and test results.

## **_Process_**

### 2.1 Configuration

We have used JMeter to conduct this stress test. The initial setup included utilizing Tazama NATS and subscribing the Relay Service to a NATS subject.

The Relay Service was configured with 01 subscriber.

To execute the stress test, JMeter was set up to send a total of 42,000 messages within 16 seconds, achieving a rate of 2625 messages per second.


### 2.2 Stress Testing Approach for NATS

For this stress test, we modified our Relay Service to generate a CSV file containing first and last timestamps.

The throughput calculation is based on the time difference between the first and last timestamps, dividing the total message count by this time difference.

**Note:** Writing timestamps to the file was handled asynchronously to avoid blocking the main thread.

## **Results**

All results are detailed below. Note that the total count of sent messages is 42,000, and the TPS, as well as first and last timestamp, are based on this count.

### 3.1 NATS Results

| Title                           | Results                |
| ------------------------------- | ---------------------- |
| First Read Time                 | 2025-06-11 07:59:52 |
| Last Write Time                 | 2025-06-11 08:00:08 |
| Total Duration for First & Last Timestamp | 16 seconds   |
| Throughput (TPS)                | 2,625                  |

### 3.2 RabbitMQ Results

| Title                           | Results                |
| ------------------------------- | ---------------------- |
| First Read Time                 | 2025-06-13 15:52:55 |
| Last Write Time                 | 2025-06-13 15:53:14 |
| Total Duration for First & Last Timestamp | 19 seconds   |
| Throughput (TPS)                | 2,136                  |

### 3.3 Kakfa Results

| Title                           | Results                |
| ------------------------------- | ---------------------- |
| First Read Time                 | 2025-06-17 15:58:12 |
| Last Write Time                 | 2025-06-17 15:58:22 |
| Total Duration for First & Last Timestamp | 10 seconds   |
| Throughput (TPS)                | 1,500                  |

### 3.4 REST API Results

| Title                           | Results                |
| ------------------------------- | ---------------------- |
| First Read Time                 | 2025-06-17 20:26:36 |
| Last Write Time                 | 2025-06-17 20:26:43 |
| Total Duration for First & Last Timestamp | 07 seconds   |
| Throughput (TPS)                | 1,485                  |
