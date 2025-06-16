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
| First Read Time                 | 2025-06-11 07:59:52 PM |
| Last Write Time                 | 2025-06-11 08:00:08 PM |
| Total Duration for First & Last Timestamp | 16 seconds   |
| Throughput (TPS)                | 2,625                  |

For a comprehensive view of all required details, please refer to the detailed results files (in CSV format) available at the link below:

- **NATS to NATS Relay Service**  
  File: [Tazama-Nats-Results.xlsx](https://github.com/tazama-lf/docs/blob/Relay-Service-Enhancement-Stress-Testing/Technical/Relay-Service/Stress-Testing/NATS-Stress%20Testing-Results.xlsx)

### 3.2 RabbitMQ Results

| Title                           | Results                |
| ------------------------------- | ---------------------- |
| First Read Time                 | 2025-06-13 15:52:55 PM |
| Last Write Time                 | 2025-06-13 15:53:14 PM |
| Total Duration for First & Last Timestamp | 19 seconds   |
| Throughput (TPS)                | 2,136                  |

For a comprehensive view of all required details, please refer to the detailed results files (in CSV format) available at the link below:

- **NATS to RabbitMQ Relay Service**  
  File: [Tazama-RabbitMQ-Results.xlsx](https://github.com/tazama-lf/docs/blob/Relay-Service-Enhancement-Stress-Testing/Technical/Relay-Service/Stress-Testing/RabbitMQ-Stress%20-Testing-Results.csv)


**Note: This README will be updated with RabbitMQ and REST API results once testing is complete. Thank you!**
