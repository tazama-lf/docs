# High Level Design

This page contains the high-level Design of the Tazama system

## High Level Design Diagram

![](../../../images/Untitled_Diagram.drawio.png)

## Legend

- Red Arrows = HTTPS/Rest/JSON communication
- Green Arrows = gRPC communication
- Blue Arrows = DB protocol (Druid)
- Blue/Green Arrows = DB protocol (ArangoDB)
- Brown Arrows = Telemetry protocol (Elastic / ELK)
- Violet Arrows = Cache protocol (Redis)
- Gray Arrows = Dependent on the Data Source / DB (of the external party)

- [High Level Design](#high-level-design)
  - [High Level Design Diagram](#high-level-design-diagram)
  - [Legend](#legend)
  - [High level Design Components](#high-level-design-components)
    - [Client (DFSP / Controller / Switch)](#client-dfsp--controller--switch)
    - [Payment Platform Adapter (PPA)](#payment-platform-adapter-ppa)
  - [Messages / Communication between Components](#messages--communication-between-components)
    - [1: DFSP → API Gateway](#1-dfsp--api-gateway)
    - [2: DFSP → Customized Tazama Payment Platform Adapter hosted inside DFSP infrastructure](#2-dfsp--customized-tazama-payment-platform-adapter-hosted-inside-dfsp-infrastructure)
    - [3: Customized Tazama Payment Platform Adapter (PPA) hosted inside DFSP infrastructure → API Gateway](#3-customized-tazama-payment-platform-adapter-ppa-hosted-inside-dfsp-infrastructure--api-gateway)
    - [4: Switch / Controller / Mojaloop (Switch) → API Gateway](#4-switch--controller--mojaloop-switch--api-gateway)
    - [5: Switch / Controller / Mojaloop (Switch) → Customized Tazama Payment Platform Adapter hosted inside Switch infrastructure](#5-switch--controller--mojaloop-switch--customized-tazama-payment-platform-adapter-hosted-inside-switch-infrastructure)
    - [6: Customized Tazama Payment Platform Adapter (PPA) hosted inside Switch / Controller / Mojaloop (Switch) infrastructure → API Gateway](#6-customized-tazama-payment-platform-adapter-ppa-hosted-inside-switch--controller--mojaloop-switch-infrastructure--api-gateway)
    - [7: API Gateway ↔︎ Identity and Access Management](#7-api-gateway-︎-identity-and-access-management)
    - [8: API Gateway ↔︎ Transaction Monitoring Service / TMS API](#8-api-gateway-︎-transaction-monitoring-service--tms-api)
    - [9: Transaction Monitoring Service / TMS API ← Config Datastore](#9-transaction-monitoring-service--tms-api--config-datastore)
    - [10: Transaction Monitoring Service / TMS API → Data Preparation / DP](#10-transaction-monitoring-service--tms-api--data-preparation--dp)
    - [11: Transaction Monitoring Service / TMS API → Telemetry](#11-transaction-monitoring-service--tms-api--telemetry)
    - [12: Transaction Aggregation \& Decisioning Processor / TADP → Transaction History Datastore](#12-transaction-aggregation--decisioning-processor--tadp--transaction-history-datastore)
    - [13: Data Preparation / DP ← Config Datastore](#13-data-preparation--dp--config-datastore)
    - [14: Data Preparation / DP → Channel Router \& Setup Processor / CRSP](#14-data-preparation--dp--channel-router--setup-processor--crsp)
    - [15: Data Preparation / DP → Telemetry](#15-data-preparation--dp--telemetry)
    - [16: Channel Router \& Setup Processor / CRSP ← Config Datastore](#16-channel-router--setup-processor--crsp--config-datastore)
    - [17: Channel Router \& Setup Processor / CRSP → Rules Processor(s) / RP(s)](#17-channel-router--setup-processor--crsp--rules-processors--rps)
    - [18: Channel Router \& Setup Processor / CRSP → Telemetry](#18-channel-router--setup-processor--crsp--telemetry)
    - [19: Rules Processor(s) / RP(s) ← Config Datastore](#19-rules-processors--rps--config-datastore)
    - [20: Rules Processor(s) / RP(s) → Typology Processor / TP](#20-rules-processors--rps--typology-processor--tp)
    - [21: Rules Processor(s) / RP(s) → Telemetry](#21-rules-processors--rps--telemetry)
    - [22: Typology Processor / TP ← Config Datastore](#22-typology-processor--tp--config-datastore)
    - [23: Typology Processor / TP \<-\> Cache](#23-typology-processor--tp---cache)
    - [24: Typology Processor / TP → Channel Aggregation \& Decisioning Processor / CADP](#24-typology-processor--tp--channel-aggregation--decisioning-processor--cadp)
    - [25: Typology Processor / TP → Telemetry](#25-typology-processor--tp--telemetry)
    - [26: Channel Aggregation \& Decisioning Processor / CADP ← Config Datastore](#26-channel-aggregation--decisioning-processor--cadp--config-datastore)
    - [27: Channel Aggregation \& Decisioning Processor / CADP \<-\> Cache](#27-channel-aggregation--decisioning-processor--cadp---cache)
    - [28: Channel Aggregation \& Decisioning Processor / CADP → Transaction Aggregation \& Decisioning Processor / TADP](#28-channel-aggregation--decisioning-processor--cadp--transaction-aggregation--decisioning-processor--tadp)
    - [29: Channel Aggregation \& Decisioning Processor / CADP → Telemetry](#29-channel-aggregation--decisioning-processor--cadp--telemetry)
    - [30: Channel Aggregation \& Decisioning Processor / CADP → Interdiction Logic](#30-channel-aggregation--decisioning-processor--cadp--interdiction-logic)
    - [31: Transaction Aggregation \& Decisioning Processor / TADP ← Config Datastore](#31-transaction-aggregation--decisioning-processor--tadp--config-datastore)
    - [32: Transaction Aggregation \& Decisioning Processor / TADP \<-\> Cache](#32-transaction-aggregation--decisioning-processor--tadp---cache)
    - [33: Transaction Aggregation \& Decisioning Processor / TADP → Workflow](#33-transaction-aggregation--decisioning-processor--tadp--workflow)
    - [34: Transaction Aggregation \& Decisioning Processor / TADP → Telemetry](#34-transaction-aggregation--decisioning-processor--tadp--telemetry)
    - [35: Workflow ← Transaction History Datastore](#35-workflow--transaction-history-datastore)
    - [36: Workflow-\> OLAP](#36-workflow--olap)
    - [37: Case Management \<-\> OLAP](#37-case-management---olap)
    - [38: API for Enrichment Data Source \<- Enrichment Data Source](#38-api-for-enrichment-data-source---enrichment-data-source)
    - [39: API for Enrichment Data Source -\> Enrichment Data API](#39-api-for-enrichment-data-source---enrichment-data-api)
    - [40: Enrichment Data Pull ← API for Enrichment Data Source](#40-enrichment-data-pull--api-for-enrichment-data-source)
    - [41: Enrichment Data Pull ← Enrichment Data Source](#41-enrichment-data-pull--enrichment-data-source)
    - [42: Enrichment Data API → Enrichment Data Pipeline](#42-enrichment-data-api--enrichment-data-pipeline)
    - [43: Enrichment Data Pull → Enrichment Data Pipeline](#43-enrichment-data-pull--enrichment-data-pipeline)
    - [44: Enrichment Data Pipeline → OLAP](#44-enrichment-data-pipeline--olap)
    - [45: DFSP → Data Services API](#45-dfsp--data-services-api)
    - [46: Controller / Switch / Mojaloop → Data Services API](#46-controller--switch--mojaloop--data-services-api)
    - [47: Data Services API ← OLAP](#47-data-services-api--olap)
    - [48: Analytics ← OLAP](#48-analytics--olap)
    - [49: Analytics -\> OLAP](#49-analytics---olap)
    - [50: DFSP → Controller / Switch / Mojaloop](#50-dfsp--controller--switch--mojaloop)
    - [51: Data Preparation / DP -\> Graph Database / GraphDB](#51-data-preparation--dp---graph-database--graphdb)
    - [52: Rules Processor(s) / RP(s) -\> Graph Database / GraphDB](#52-rules-processors--rps---graph-database--graphdb)

## High level Design Components

### Client (DFSP / Controller / Switch)

The client can be either DFSP or Controller / Switch. Mojaloop is considered a Switch. IF the client has the ability to send ISO20022 compliant messages / transactions then it will not need a Payment Platform Adapter ELSE the Payment Platform Adapter acts as an interface / transformer to transform the client system specific format to ISO20022 compliant format.

### Payment Platform Adapter (PPA)

Payment Platform Adapter (PPA) is operationally owned by the client. In most cases, the PPA is customized by the client to fit into its infrastructure and comply with the client’s IT and Security policies.

## Messages / Communication between Components

### 1: DFSP → API Gateway

API Gateway is implemented using Ambassador

DFSP can send a message to Tazama API Gateway provided:

1. the communication is secure (HTTPS)
2. the message has the correct and unexpired auth token(s)
3. the message is in one of the allowed transaction types
4. the message is in the ISO 20022 compliant format

### 2: DFSP → Customized Tazama Payment Platform Adapter hosted inside DFSP infrastructure

DFSP can send a message to a customized Tazama Payment Platform Adapter (PPA) provided:

1. the PPA is customized as per the DFSP’s requirements
2. the PPA is install in the DFSP infrastructure, commissioned and active/operational
3. the communication is secure (HTTPS)
4. the message is in one of the allowed transaction types
5. the message can
    1. either be in the ISO 20022 compliant format
    2. or DFSP format provided provided the DFSP format is customized in the PPA

### 3: Customized Tazama Payment Platform Adapter (PPA) hosted inside DFSP infrastructure → API Gateway

API Gateway is implemented using Ambassador

PPA hosted inside DFSP infrastructure can send a message to Tazana API Gateway provided:

1. the communication is secure (HTTPS)
2. the message has the correct and unexpired auth token(s)
3. the message is in one of the allowed transaction types
4. the message is in the ISO 20022 compliant format

### 4: Switch / Controller / Mojaloop (Switch) → API Gateway

API Gateway is implemented using Ambassador

Switch can send a message to Tazama API Gateway provided:

1. the communication is secure (HTTPS)
2. the message has the correct and unexpired auth token(s)
3. the message is in one of the allowed transaction types
4. the message is in the ISO 20022 compliant format

### 5: Switch / Controller / Mojaloop (Switch) → Customized Tazama Payment Platform Adapter hosted inside Switch infrastructure

Switch can send a message to

a customized Tazama Payment Platform Adapter (PPA) provided:

1. the PPA is customized as per the Switch’s requirements
2. the PPA is install in the Switch’s infrastructure, commissioned and active/operational
3. the communication is secure (HTTPS)
4. the message is in one of the allowed transaction types
5. the message can
    1. either be in the ISO 20022 compliant format
    2. or Switch format provided provided the Switch’s format is customized in the PPA

### 6: Customized Tazama Payment Platform Adapter (PPA) hosted inside Switch / Controller / Mojaloop (Switch) infrastructure → API Gateway

API Gateway is implemented using Ambassador

PPA hosted inside Switch infrastructure can send a message to Tazama API Gateway provided:

1. the communication is secure (HTTPS)
2. the message has the correct and unexpired auth token(s)
3. the message is in one of the allowed transaction types
4. the message is in the ISO 20022 compliant format

### 7: API Gateway ↔︎ Identity and Access Management

API Gateway is implemented using Ambassador

Identity and Access Management is implemented using KeyCloak

API Gateway authenticates the external HTTPS message using KeyCloak where KeyCloak validates the auth token(s)

### 8: API Gateway ↔︎ Transaction Monitoring Service / TMS API

API Gateway is implemented using Ambassador

Transaction Monitoring Service / TMS API is implemented using OpenFaaS

API Gateway can send a message to TMS API provided:

1. the communication is secure (HTTPS)
2. the message has the correct and unexpired auth token(s) (provided by KeyCloak)
3. the message is in one of the allowed transaction types
4. the message is in the ISO 20022 compliant format

### 9: Transaction Monitoring Service / TMS API ← Config Datastore

Transaction Monitoring Service / TMS API is implemented using OpenFaaS

Config Datastore is implemented using Druid (Database - JSON / Document store)

TMS API reads config from Config Datastore on loading time:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the configuration is read as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON)
3. specific version of the configuration is read
4. TMS API scales based on traffic; every new pod created because of scaling, will read the same configuration from Druid
5. TMS API keeps the config in memory until the pod is brought down

### 10: Transaction Monitoring Service / TMS API → Data Preparation / DP

Transaction Monitoring Service / TMS API is implemented using OpenFaaS

Data Preparation / DP is implemented using NIFI

TMS API can send a message to DP provided:

1. the communication is using gRPC
2. the message format is based on the proto file
3. TMS API and DP are both meshed using Linkerd
4. the message is in one of the allowed transaction types
5. the message is in the ISO 20022 compliant format

### 11: Transaction Monitoring Service / TMS API → Telemetry

Transaction Monitoring Service / TMS API is implemented using OpenFaaS

Telemetry is implemented using ELK (Elastic, Logstash, Kibana) platform

TMS API can send a message to Telemetry provided:

1. the communication is using ELK accepted protocol / library (APM)

### 12: Transaction Aggregation & Decisioning Processor / TADP → Transaction History Datastore

Transaction Aggregation & Decisioning Processor / TADP is implemented using OpenFaaS

Transaction History Datastore is implemented using Druid

TADP can send a message to Transaction History Datastore provided:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the transaction is written as JSON to the transaction history collection (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON)
3. transaction is indexed on transaction_id
4. TADP scales based on traffic; every new pod created because of scaling, will write to the same Druid collection

### 13: Data Preparation / DP ← Config Datastore

Data Preparation / DP is implemented using NIFI

Config Datastore is implemented using Druid (Database - JSON / Document store)

DP reads config from Config Datastore on loading time:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the configuration is read as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON)
3. specific version of the configuration is read
4. DP scales based on traffic; every new pod created because of scaling, will read the same configuration from Druid
5. DP keeps the config in memory until the pod is brought down

### 14: Data Preparation / DP → Channel Router & Setup Processor / CRSP

Data Preparation / DP is implemented using NIFI

Channel Router & Setup Processor / CRSP is implemented using OpenFaaS

DP can send a message to CRSP provided:

1. the communication is using gRPC
2. the message format is based on the proto file
3. DP and CRSP are both meshed using Linkerd
4. the message is in one of the allowed transaction types
5. the message is in the ISO 20022 compliant format

### 15: Data Preparation / DP → Telemetry

Data Preparation / DP is implemented using NIFI

Telemetry is implemented using ELK (Elastic, Logstash, Kibana) platform

TMS API can send a message to Telemetry provided:

1. the communication is using ELK accepted protocol / library (APM)

### 16: Channel Router & Setup Processor / CRSP ← Config Datastore

Channel Router & Setup Processor / CRSP is implemented using OpenFaaS

Config Datastore is implemented using Druid (Database - JSON / Document store)

DP reads config from Config Datastore on loading time:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the configuration for CRSP is available in Druid / Datastore
3. the network map is available in Druid / Datastore
4. the configuration is read as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON)
5. specific version of the configuration is read
6. CRSP scales based on traffic; every new pod created because of scaling, will read the same configuration from Druid
7. CRSP keeps the config in memory until the pod is brought down

### 17: Channel Router & Setup Processor / CRSP → Rules Processor(s) / RP(s)

Channel Router & Setup Processor / CRSP is implemented using OpenFaaS

Rules Processor(s) / RP(s) is implemented using OpenFaaS

Tazama will have a Rules Processor per Rule so there will be multiple Rules Processors. Each Rules Processor will have its own code base and its own configuration

CRSP can send a message to RP provided:

1. the communication is using gRPC
2. the message format is based on the proto file
3. the message contains the transaction appended to the transaction
4. the message contains the network map appended to the transaction
5. CRSP and RP are both meshed using Linkerd
6. the message is in one of the allowed transaction types
7. the message is in the ISO 20022 compliant format

### 18: Channel Router & Setup Processor / CRSP → Telemetry

Channel Router & Setup Processor / CRSP is implemented using OpenFaaS

Telemetry is implemented using ELK (Elastic, Logstash, Kibana) platform

CRSP can send a message to Telemetry provided:

1. the communication is using ELK accepted protocol / library (APM)

### 19: Rules Processor(s) / RP(s) ← Config Datastore

Rules Processor is implemented using OpenFaaS

Config Datastore is implemented using Druid (Database - JSON / Document store)

RP reads config from Config Datastore on loading time:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the configuration for RP is available in Druid / Datastore; each RP will have its own separate configuration
3. the configuration is read as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON)
4. specific version of the configuration is read
5. RP scales based on traffic; every new pod created because of scaling, will read the same configuration from Druid
6. RP keeps the config in memory until the pod is brought down

### 20: Rules Processor(s) / RP(s) → Typology Processor / TP

Rules Processor(s) / RP(s) is implemented using OpenFaaS

Typology Processor / RP is implemented using OpenFaaS

Tazama will have a RP per Rule so there will be multiple Rules Processors. Each Rules Processor will have its own code base and its own configuration

Tazama will have only one TP irrespective of the number of Typologies. However each Typology will have its own configuration

RP can send a message to TP provided:

1. the communication is using gRPC
2. the message format is based on the proto file
3. the message contains the transaction appended to the transaction
4. the message contains the Rules result appended to the transaction in the message
5. the message contains the network map appended to the transaction in the message
6. RP and TP are both meshed using Linkerd
7. the message is in one of the allowed transaction types
8. the message is in the ISO 20022 compliant format

### 21: Rules Processor(s) / RP(s) → Telemetry

Rules Processor / RP is implemented using OpenFaaS

Telemetry is implemented using ELK (Elastic, Logstash, Kibana) platform

RP can send a message to Telemetry provided:

1. the communication is using ELK accepted protocol / library (APM)

### 22: Typology Processor / TP ← Config Datastore

Typology Processor / TP is implemented using OpenFaaS

Config Datastore is implemented using Druid (Database - JSON / Document store)

TP reads config for all Typologies from Config Datastore on loading time:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the configuration for TP is available in Druid / Datastore; there is only one TP but each Typology will have its own separate configuration

3. the configuration is read as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON)
4. specific version of the configuration is read
5. TP scales based on traffic; every new pod created because of scaling, will read the same configuration (configurations for all Typologies) from Druid
6. TP keeps the configurations in memory until the pod is brought down

### 23: Typology Processor / TP <-> Cache

Typology Processor / TP is implemented using OpenFaaS

Cache is implemented using Redis

TP reads from and writes to the Cache every time it receives Rules result from any of the Rules Processors:

1. the communication is Cache protocol specific (in case of Redis, it will be Redis chosen protocol)
2. the cache will contain the Rules result for each transaction for each channel for each Rule execution; the cache entries are cleared by a clean-up process that run at a regular frequency; the cache entries also have a TTL (Time-To-Live)
3. the cache entry is read and written as JSON (how the JSON is stored depends on Redis / Cache setup, example: it could be stored as binary form of JSON)
4. TP scales based on traffic; every new pod created because of scaling, will read the same Redis installation and hence the same cache entry for that particular transaction for that particular channel for that particular Rule execution from Redis
5. TP keeps the cache results in memory only for the duration of the Typology execution

### 24: Typology Processor / TP → Channel Aggregation & Decisioning Processor / CADP

Typology Processor / RP is implemented using OpenFaaS

Channel Aggregation & Decisioning Processor / CADP is implemented using OpenFaaS

Tazama will have only one TP irrespective of the number of Rules. However each Typology will have its own configuration

Tazama will have only one CADP irrespective of the number of Channels. However each Channel will have its own configuration

TP can send a message to CADP provided:

1. the communication is using gRPC
2. the message format is based on the proto file
3. the message contains the transaction appended to the transaction
4. the message contains the Typology result appended to the transaction in the message
5. the message contains the network map appended to the transaction in the message
6. TP and CADP are both meshed using Linkerd
7. the message is in one of the allowed transaction types
8. the message is in the ISO 20022 compliant format

### 25: Typology Processor / TP → Telemetry

Typology Processor / RP is implemented using OpenFaaS

Telemetry is implemented using ELK (Elastic, Logstash, Kibana) platform

TP can send a message to Telemetry provided:

1. the communication is using ELK accepted protocol / library (APM)

### 26: Channel Aggregation & Decisioning Processor / CADP ← Config Datastore

Channel Aggregation & Decisioning Processor / CADP is implemented using OpenFaaS

Config Datastore is implemented using Druid (Database - JSON / Document store)

CADP reads config for all Channels from Config Datastore on loading time:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the configuration for CADP is available in Druid / Datastore; there is only one CADP but each Channel will have its own separate configuration
3. the configuration is read as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON)
4. specific version of the configuration is read
5. CADP scales based on traffic; every new pod created because of scaling, will read the same configuration (configurations for all Channels) from Druid
6. CADP keeps the configurations in memory until the pod is brought down

### 27: Channel Aggregation & Decisioning Processor / CADP <-> Cache

Channel Aggregation & Decisioning Processor / CADP is implemented using OpenFaaS

Cache is implemented using Redis

CADP reads from and writes to the Cache every time it receives Typology result from the Typology Processor:

1. the communication is Cache protocol specific (in case of Redis, it will be Redis chosen protocol)
2. the cache will contain the Typology result for each transaction for each channel for each Typology execution; the cache entries are cleared by a clean-up process that run at a regular frequency; the cache entries also have a TTL (Time-To-Live)
3. the cache entry is read and written as JSON (how the JSON is stored depends on Redis / Cache setup, example: it could be stored as binary form of JSON)
4. CADP scales based on traffic; every new pod created because of scaling, will read the same Redis installation and hence the same cache entry for that particular transaction for that particular channel for that particular Typology execution from Redis
5. CADP keeps the cache results in memory only for the duration of the Channel execution

### 28: Channel Aggregation & Decisioning Processor / CADP → Transaction Aggregation & Decisioning Processor / TADP

Channel Aggregation & Decisioning Processor / CADP is implemented using OpenFaaS

Transaction Aggregation & Decisioning Processor / TADP is implemented using OpenFaaS

Tazama will have only one CADP irrespective of the number of Channels. However each Channel will have its own configuration

Tazama will have only one TADP irrespective of the number of Transaction types. However each Transaction type will have its own configuration

CADP can send a message to TADP provided:

1. the communication is using gRPC
2. the message format is based on the proto file
3. the message contains the transaction appended to the transaction
4. the message contains the Channel result appended to the transaction in the message
5. the message contains the network map appended to the transaction in the message
6. CADP and TADP are both meshed using Linkerd
7. the message is in one of the allowed transaction types
8. the message is in the ISO 20022 compliant format

### 29: Channel Aggregation & Decisioning Processor / CADP → Telemetry

Channel Aggregation & Decisioning Processor / CADP is implemented using OpenFaaS

Telemetry is implemented using ELK (Elastic, Logstash, Kibana) platform

CADP can send a message to Telemetry provided:

1. the communication is using ELK accepted protocol / library (APM)

### 30: Channel Aggregation & Decisioning Processor / CADP → Interdiction Logic

Channel Aggregation & Decisioning Processor / CADP is implemented using OpenFaaS

Interdiction Logic / IL is implemented using OpenFaaS

Tazama will have only one CADP irrespective of the number of Channels. However each Channel will have its own configuration

Tazama will have only one IL irrespective of the number of Transaction types or number of Clients. However each Transaction type for each client will have its own configuration

CADP can send a message to IL provided:

1. the communication is using gRPC
2. the message format is based on the proto file
3. the message contains the transaction appended to the transaction
4. the message contains the Transaction Alert appended to the transaction in the message
5. CADP and IL are both meshed using Linkerd
6. the message is in one of the allowed transaction types
7. the message is in the ISO 20022 compliant format

### 31: Transaction Aggregation & Decisioning Processor / TADP ← Config Datastore

Transaction Aggregation & Decisioning Processor / TADP is implemented using OpenFaaS

Config Datastore is implemented using Druid (Database - JSON / Document store)

TADP reads config for all Transaction types from Config Datastore on loading time:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the configuration for TADP is available in Druid / Datastore; there is only one TADP but each Transaction Type will have its own separate configuration
3. the configuration is read as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON)
4. specific version of the configuration is read
5. TADP scales based on traffic; every new pod created because of scaling, will read the same configuration (configurations for all Channels) from Druid
6. TADP keeps the configurations in memory until the pod is brought down

### 32: Transaction Aggregation & Decisioning Processor / TADP <-> Cache

Transaction Aggregation & Decisioning Processor / TADP is implemented using OpenFaaS

Cache is implemented using Redis

TADP reads from and writes to the Cache every time it receives Channel result from the Channel Aggregation & Decisioning Processor:

1. the communication is Cache protocol specific (in case of Redis, it will be Redis chosen protocol)
2. the cache will contain the Channel result for each transaction for each Channel execution; the cache entries are cleared by a clean-up process that run at a regular frequency; the cache entries also have a TTL (Time-To-Live)
3. the cache entry is read and written as JSON (how the JSON is stored depends on Redis / Cache setup, example: it could be stored as binary form of JSON)
4. TADP scales based on traffic; every new pod created because of scaling, will read the same Redis installation and hence the same cache entry for that particular transaction for that particular Channel execution from Redis
5. TADP keeps the cache results in memory only for the duration of the Channel execution

### 33: Transaction Aggregation & Decisioning Processor / TADP → Workflow

Transaction Aggregation & Decisioning Processor / TADP is implemented using OpenFaaS

Workflow is implemented using OpenFaaS

Tazama will have only one TADP irrespective of the number of Transaction types. However each Transaction type will have its own configuration

Tazama will have only one Workflow irrespective of the number of Transaction types or the number of Clients. However each Transaction type and each Client will have its own configuration

TADP can send a message to Workflow provided:

1. the communication is using gRPC
2. the message format is based on the proto file
3. the message contains the transaction appended to the transaction
4. the message contains the Transaction result appended to the transaction in the message
5. TADP and Workflow are both meshed using Linkerd
6. the message is in one of the allowed transaction types
7. the message is in the ISO 20022 compliant format

### 34: Transaction Aggregation & Decisioning Processor / TADP → Telemetry

Transaction Aggregation & Decisioning Processor / TADP is implemented using OpenFaaS

Telemetry is implemented using ELK (Elastic, Logstash, Kibana) platform

CADP can send a message to Telemetry provided:

1. the communication is using ELK accepted protocol / library (APM)

### 35: Workflow ← Transaction History Datastore

Workflow is implemented using OpenFaaS

Transaction History Datastore is implemented using Druid (Database - JSON / Document store)

Workflow reads all entries for the transaction from Transaction History Datastore when processing results for a particular transaction:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the history for transaction is available in Druid / Datastore; there will be multiple entries for each transaction
3. the history is read as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON)
4. Workflow scales based on traffic; every new pod created because of scaling, will read the same history for any particular transaction from Druid

### 36: Workflow-> OLAP

Workflow is implemented using OpenFaaS

OLAP is implemented using Druid

Workflow processes the transaction history and the transaction results to produce case management records and writes them to OLAP for a particular transaction:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the history is written as JSON (how the JSON is stored depends on ArangoDB / Datastore setup, example: it could be stored as binary form of JSON)

### 37: Case Management <-> OLAP

Case Management is implemented using OpenFaaS

OLAP is implemented using Druid

Case Management reads from and writes to OLAP every time it works on a particular transaction or a set of transactions:

1. the communication is OLAP protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the OLAP entry is read and written as JSON (how the JSON is stored depends on Druid / Cache setup, example: it could be stored as binary form of JSON)
3. Case Management scales based on traffic; every new pod created because of scaling, will read the same OLAP installation
4. data includes raw transaction data, aggregated data, enriched data and analyzed data

### 38: API for Enrichment Data Source <- Enrichment Data Source

- Many clients or public data stores that host Enrichment data will be exposed via an API
  - This API is not part of the Tazama system
- Enrichment Data Source can be of any type
- Enrichment Data Source will not be part of the Tazama system

### 39: API for Enrichment Data Source -> Enrichment Data API

Enrichment Data API is implemented using OpenFaaS

- Many clients or public data stores that host Enrichment data will be exposed via an API
  - This API is not part of the Tazama system
- Enrichment Data API is part of the Tazama system
- Enrichment Data API will expose endpoints to receive data from external sources (examples: API for Enrichment Data). Access to those endpoints will be secure behind the API Gateway with authentication and authorization provided by KeyCloak
- Enrichment Data API will accept data in multiple formats (including JSON, CSV, XLS, XLSX, XML)
- Enrichment Data API is meshed using Linkerd

### 40: Enrichment Data Pull ← API for Enrichment Data Source

Enrichment Data Pull is implemented using OpenFaaS

- Many clients or public data stores that host Enrichment data will be exposed via an API
  - This API is not part of the Tazama system
- Enrichment Data Pull is part of the Tazama system
- Enrichment Data Pull will NOT expose endpoints
- Enrichment Data Pull will call API for Enrichment Data Source (external) using the relevant authentication and authorization token
- Enrichment Data Pull will accept data in multiple formats (including JSON, CSV, XLS, XLSX, XML)
- Enrichment Data Pull is meshed using Linkerd

### 41: Enrichment Data Pull ← Enrichment Data Source

Enrichment Data Pull is implemented using OpenFaaS

- Many public data stores (possibly a few clients) host Enrichment data source without an API in front of it
  - This Enrichment Data Source is not part of the Tazama system
- Enrichment Data Pull is part of the Tazama system
- Enrichment Data Pull will NOT expose endpoints
- Enrichment Data Pull will read data from Enrichment Data Source (external) using the relevant authentication and authorization token, if applicable
- Enrichment Data Pull will read data in multiple formats (including JSON, CSV, XLS, XLSX, XML, specific DB queries)
- Enrichment Data Pull is meshed using Linkerd

### 42: Enrichment Data API → Enrichment Data Pipeline

Enrichment Data API is implemented using OpenFaaS

Enrichment Data Pipeline is implemented using OpenFaaS

More than one components together are represented as Enrichment Data Pipeline

Enrichment Data API can send a message to Enrichment Data Pipeline provided:

1. the communication is using REST
2. the message contains the enrichment data in JSON format
3. Enrichment Data API and Enrichment Data Pipeline are both meshed using Linkerd

### 43: Enrichment Data Pull → Enrichment Data Pipeline

Enrichment Data Pull is implemented using OpenFaaS

Enrichment Data Pipeline is implemented using OpenFaaS

More than one components together are represented as Enrichment Data Pipeline

Enrichment Data Pull can send a message to Enrichment Data Pipeline provided:

1. the communication is using REST
2. the message contains the enrichment data in JSON format
3. Enrichment Data Pull and Enrichment Data Pipeline are both meshed using Linkerd

### 44: Enrichment Data Pipeline → OLAP

Enrichment Data Pipeline is implemented using OpenFaaS

OLAP is implemented using Druid (Database - JSON / Document store)

Workflow can write data to Enrichment Datastore provided:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the enrichment data is cleansed
3. the enrichment data is structured
4. individual components of the Enrichment Pipeline scale based on traffic; every new pod created because of scaling

### 45: DFSP → Data Services API

Data Services API is implemented using OpenFaaS

DFSP can send a data request to Data Services API provided:

1. the communication is secure (HTTPS)
2. the message has the correct and unexpired auth token(s)
3. the message is in one of the allowed data request formats (based on Swagger definition)

### 46: Controller / Switch / Mojaloop → Data Services API

Data Services API is implemented using OpenFaaS

Data Services API scales based on traffic

Controller / Switch / Mojaloop can send a data request to Data Services API provided:

1. the communication is secure (HTTPS)
2. the message has the correct and unexpired auth token(s)
3. the message is in one of the allowed data request formats (based on Swagger definition)

### 47: Data Services API ← OLAP

Data Services API is implemented using OpenFaaS

OLAP is implemented using Druid (Database - JSON / Document store)

Data Services API reads data for one or more transactions from OLAP on demand:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the data is read as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON)
3. Data Services API scales based on traffic
4. CADP keeps the configurations in memory until the pod is brought down

### 48: Analytics ← OLAP

Analytics is implemented using Spark

OLAP is implemented using Druid (Database - JSON / Document store)

Analytics reads data for multiple transactions from OLAP on demand:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the data is read as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON) or SQL
3. Analytics is setup for parallel/distributed computation

### 49: Analytics -> OLAP

Analytics is implemented using Spark

OLAP is implemented using Druid (Database - JSON / Document store)

Analytics writes analyzed data for multiple transactions to OLAP:

1. the communication is database protocol specific (in case of Druid, it will be Druid chosen protocol)
2. the data is written as JSON (how the JSON is stored depends on Druid / Datastore setup, example: it could be stored as binary form of JSON) or CSV or XLS/XLSX or Druid format
3. Analytics is setup for parallel/distributed computation

### 50: DFSP → Controller / Switch / Mojaloop

DFSP can send a message to Controller / Switch / Mojaloop provided:

1. the message is in one of the Controller / Switch / Mojaloop allowed transaction types
2. the message is in the Controller / Switch / Mojaloop compliant format

### 51: Data Preparation / DP -> Graph Database / GraphDB

Data Preparation / DP is implemented using NIFI

Graph Database / GraphDB is implemented using ArangoDB (Graph Database)

DP writes pseudonymized transaction data to GraphDB:

1. the communication is database protocol specific (in case of ArangoDB, it will be ArangoDB chosen protocol)
2. the data is written as JSON (how the JSON is stored depends on ArangoDB / Datastore setup, example: it could be stored as binary form of JSON) or CSV or XLS/XLSX or Druid format
3. DP scales based on traffic

### 52: Rules Processor(s) / RP(s) -> Graph Database / GraphDB

Rules Processor(s) / RP(s) is implemented using OpenFaaS

Graph Database / GraphDB is implemented using ArangoDB (Graph Database)

RP reads pseudonymized transaction data from GraphDB:

1. the communication is database protocol specific (in case of ArangoDB, it will be ArangoDB chosen protocol)
2. the data is written as JSON (how the JSON is stored depends on ArangoDB / Datastore setup, example: it could be stored as binary form of JSON) or CSV or XLS/XLSX or Druid format
3. RP scales based on traffic
