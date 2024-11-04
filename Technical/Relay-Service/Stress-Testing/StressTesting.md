# **Tazama Relay Service Stress Testing**

## _Stress Testing Documentation_

**Table of Contents**

- [**Overview**](#overview)

  - [1.1 An Overview of the Document and its Purpose](#11-an-overview-of-the-document-and-its-purpose)

- [**Process**](#process)

    - [2.1 Configuration](#21-configuration)

    - [2.2 Stress Testing Approach for RabbitMQ and NATS](#22-stress-testing-approach-for-rabbitMQ-and-NATS)

    - [2.3 Stress Testing Approach for REST API](#23-stress-testing-approach-for-REST-API)

- [**Results**](#2-system-architecture)

    - [3.1 NATS Results](#31-NATS-results)

    - [3.2 RabbitMQ Results](#32-RabbitMQ-results)

    - [3.3 REST API Results](#33-REST-API-results)

## **_Overview_**

It is a TypeScript-based service that bridges communication between TMS (Tazama Monitoring Service) and client applications handling transaction processing and analysis.

### 1.1 An Overview of the Document and its Purpose

This documentation provides a complete overview of the stress testing process, including setup details, data generated, and test results.

## **_Process_**

### 2.1 Configuration

We have used JMeter to conduct this stress test. The initial setup included utilizing Tazama NATS and subscribing the Relay Service to a NATS subject.

The Relay Service was configured with 500 subscribers.

To execute the stress test, JMeter was set up to send a total of 60,000 messages within 10 seconds, achieving a rate of 6,000 messages per second.

| Title                                                    | Results               |
| -------------------------------------------------------- | --------------------- |
| Start Time Jmeter                                        | 10/30/2024 4:20:14 PM |
| End Time Jmeter                                          | 10/30/2024 4:20:25 PM |
| Total Time Jmeter took to initiate 60000 message samples | 11 seconds            |
| Throughput (TPS)                                         | 5,454                 |

### 2.2 Stress Testing Approach for RabbitMQ and NATS

For this stress test, we modified our Relay Service to generate a CSV file containing timestamps for both Read and Write events.

The throughput calculation is based on the time difference between the first read and the last write timestamps, dividing the total message count by this time difference.

**Note:** Writing timestamps to the file was handled asynchronously to avoid blocking the main thread.

### 2.3 Stress Testing Approach for REST API

To conduct this stress test, we set up a simulated destination server to ensure reliable message delivery.

To meet the required TPS, we deployed six server instances, managed through NGINX load balancing.

On the Relay Service side, we integrated the REST API using the Axios library, configured to keep HTTP/HTTPS connections open. We also set the maximum socket limit to 2000 to support high concurrency and maintain performance under load.

## **Results**

All results are detailed below. Note that the total count of sent messages is 60,000, and the TPS, as well as Read and Write times, are based on this count.

### 3.1 NATS Results

| Title                           | Results             |
| ------------------------------- | ------------------- |
| First Read Time                 | 2024-10-30 15:42:08 PM |
| Last Write Time                 | 2024-10-30 15:42:28 PM |
| Total Duration for Read & Write | 20 seconds          |
| Throughput (TPS)                | 3,000               |

### 3.2 RabbitMQ Results

| Title                           | Results             |
| ------------------------------- | ------------------- |
| First Read Time                 | 2024-10-30 15:56:08 PM |
| Last Write Time                 | 2024-10-30 15:56:26 PM |
| Total Duration for Read & Write | 18 seconds          |
| Throughput (TPS)                | 3,333            |

### 3.3 REST API Results

| Title                           | Results             |
| ------------------------------- | ------------------- |
| First Write Time from JMeter    | 2024-10-30 16:20:14 PM |
| Last Read Time on NGINX         | 2024-10-30 16:21:08 PM |
| Total Duration for Read & Write | 23 seconds          |
| Throughput (TPS)                | 2,649               |

For a comprehensive view of all required details, please refer to the detailed results files (in CSV format) available at the links below:

- **NATS to NATS Relay Service**  
  File: [@NATS to NATS Relay Service](https://paysyslabs-my.sharepoint.com/:x:/r/personal/usama_manan_paysyslabs_com/_layouts/15/Doc.aspx?sourcedoc=%7B3E45BD8A-35E2-473A-A20F-632EB1F77423%7D&file=Tazama-Nats-Result.xlsx&action=default&mobileredirect=true)

- **NATS to RabbitMQ Relay Service**  
  File: [@NATS to RabbitMQ Relay Service](https://paysyslabs-my.sharepoint.com/:x:/r/personal/usama_manan_paysyslabs_com/Documents/Tazama%20Relay%20Service%20Stress%20Testing/Tazama-Rabbit-Results.xlsx?d=w32cb29b878354672893b6a239e7c8668&csf=1&web=1&e=1a20T2)

- **NATS to REST API Relay Service**  
  File: [@NATS to REST API Relay Service](https://paysyslabs-my.sharepoint.com/:x:/r/personal/usama_manan_paysyslabs_com/Documents/Tazama%20Relay%20Service%20Stress%20Testing/Tazama-http-Results.xlsx?d=wb3bc42f4405f48d7b87a120733006e2b&csf=1&web=1&e=3qP9nD)
