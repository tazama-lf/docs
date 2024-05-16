# Technology Selection

- [Technology Selection](#technology-selection)
  - [Heading 1 - Functional Requirement](#heading-1---functional-requirement)
    - [Overview of Requirement](#overview-of-requirement)
    - [Need for the Product/Tool](#need-for-the-producttool)
    - [Product/Tool Alternatives](#producttool-alternatives)
    - [Which Tool and Why](#which-tool-and-why)
  - [Containerization](#containerization)
    - [Tazama Business Need](#tazama-business-need)
    - [Why Container?](#why-container)
    - [Containerization Alternatives](#containerization-alternatives)
    - [Kubernetes and Why](#kubernetes-and-why)
  - [API Gateway](#api-gateway)
    - [Tazama Business Need](#tazama-business-need-1)
    - [Why API Gateway?](#why-api-gateway)
    - [Ambassador Alternatives](#ambassador-alternatives)
    - [Ambassador and Why](#ambassador-and-why)
  - [IAM](#iam)
    - [Tazama Business Need](#tazama-business-need-2)
    - [Why IAM?](#why-iam)
    - [KeyCloak Alternatives](#keycloak-alternatives)
    - [KeyCloak and Why](#keycloak-and-why)
  - [Service Mesh](#service-mesh)
    - [Tazama Business Need](#tazama-business-need-3)
    - [Why Service Mesh?](#why-service-mesh)
    - [Service Mesh Alternatives](#service-mesh-alternatives)
    - [Linkerd and Why](#linkerd-and-why)
  - [Function as a Service](#function-as-a-service)
    - [Tazama Business Need](#tazama-business-need-4)
    - [Why Function as a Service?](#why-function-as-a-service)
    - [FaaS alternatives](#faas-alternatives)
    - [OpenFaaS and Why](#openfaas-and-why)
  - [Event Monitoring](#event-monitoring)
    - [Tazama Business Need](#tazama-business-need-5)
    - [Why Event monitoring?](#why-event-monitoring)
    - [Event Monitoring Alternatives](#event-monitoring-alternatives)
    - [Prometheus and Why](#prometheus-and-why)
  - [Real-time Observability](#real-time-observability)
    - [Tazama Business Need](#tazama-business-need-6)
    - [Why real-time observability?](#why-real-time-observability)
    - [Real-time observability Alternatives](#real-time-observability-alternatives)
    - [Grafana and Why](#grafana-and-why)
  - [Data Flow / Data Processor](#data-flow--data-processor)
    - [Tazama Business Need](#tazama-business-need-7)
    - [Why Data Flow / Data Processor?](#why-data-flow--data-processor)
    - [Data Flow Alternatives](#data-flow-alternatives)
    - [NIFI and Why](#nifi-and-why)
  - [Multi-modal Database](#multi-modal-database)
    - [Tazama Business Need](#tazama-business-need-8)
    - [Why Multi-modal database?](#why-multi-modal-database)
    - [Multi-modal database Alternatives](#multi-modal-database-alternatives)
    - [ArangoDB and Why](#arangodb-and-why)
  - [Historic Observability](#historic-observability)
    - [Tazama Business Need](#tazama-business-need-9)
    - [Why Historic Observability?](#why-historic-observability)
    - [Historic Observability Alternatives](#historic-observability-alternatives)
    - [Elastic and Why](#elastic-and-why)
  - [In-Memory Cache](#in-memory-cache)
    - [Tazama Business Need](#tazama-business-need-10)
    - [Why In-Memory Cache?](#why-in-memory-cache)
    - [Redis Alternatives](#redis-alternatives)
    - [Why Redis?](#why-redis)
  - [OLAP](#olap)
    - [Tazama Business Need](#tazama-business-need-11)
    - [Why OLAP?](#why-olap)
    - [OLAP Alternatives](#olap-alternatives)
    - [Druid and Why](#druid-and-why)
  - [Inter-service communication](#inter-service-communication)
    - [Tazama Business Need](#tazama-business-need-12)
    - [Why Inter-service communication?](#why-inter-service-communication)
    - [Inter-service communication Alternatives](#inter-service-communication-alternatives)
    - [Why gRPC?](#why-grpc)
  - [Data Serialization and Queuing](#data-serialization-and-queuing)
    - [Tazama Business Need](#tazama-business-need-13)
    - [Why Data Serialization and Queuing?](#why-data-serialization-and-queuing)
    - [Data Serialization and Queuing alternatives](#data-serialization-and-queuing-alternatives)
    - [ProtoBuf and Why](#protobuf-and-why)
  - [YAML](#yaml)
  - [JSON](#json)

The Tazama Financial Crime Risk Management system architecture covers the technology components used in the system.

## Heading 1 - Functional Requirement

### Overview of Requirement

### Need for the Product/Tool

### Product/Tool Alternatives

### Which Tool and Why

![](../../images/Untitled_Diagram.drawio.png)

The architecture above shows the following list of components:

|     |     |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Kubernetes | Ambassador | KeyCloak | Linkerd | OpenFaaS | Prometheus | Grafana | NIFI |
| ArangoDB | Elastic | Redis | Druid | gRPC | ProtoBuf | YAML | JSON |

## Containerization

### Tazama Business Need

We want the system to support 100s of Typologies, 1000s of Rules, many channels. There are Routing, filtering, transactional requirements. The system needs to support multiple downstream systems. After we made the choice to go with Containers, the orchestration becomes a Non-functional requirement. If it was just a one or two containers, we could have done with docker compose. But docker compose needs a lot of manual work for scaling and it is more of a configuration than an orchestration system.

### Why Container?

We want the system to be modular, configurable, scalable, performant, reliable. We want the code to be re-usable. We want to reduce risk. Containerized implementation provides these and many other design aspects.

### Containerization Alternatives

We had Docker Swarm, Openshift and other Cloud offerings. Because Tazama system is open-source, we wanted to go with open source options. That left us with Kubernetes, Docker Swarm and Openshift.

### Kubernetes and Why

It is an open-source container orchestration system. We went with Kubernetes because it is the mostly widely used container orchestration and the development team had experience and were more comfortable with it.

## API Gateway

### Tazama Business Need

With a lot of containers in the system, there is a need for a reliable API Gateway to route the traffic / Ingress into the Tazama system running on Kubernetes. We want easy introspection, reliability, scalability, availability and performance. Ambassador provides sophisticated traffic management capabilities including load balancing, automatic retries etc.

### Why API Gateway?

We need a single entry / Ingress point into the Tazama system. Can we use nginx? Yes. But then why Ambassador - because it is built for Kubernetes and implementating the same with nginx will require a little more custom work than to go with Ambassador.

### Ambassador Alternatives

We have Envoy, Consul, OpenAPI, Istio, Kong, Amazon API Gateway and other products. Sticking with Open source options, the popular options are Ambassador, Envoy, OpenAPI, Kong.

### Ambassador and Why

Ambassador is Envoy built for Kubernetes. Ambassador is cloud native / Kubernetes native. Hence the defacto API Gateway choice for the Tazama system.

## IAM

### Tazama Business Need

We need to make Tazama system secure with little to no code. Tazama system is designed to support multi-tenants. We also anticipate the need for Single Sign On (SSO) in the future.

### Why IAM?

Security, authentication, authorization, multi-tenant (profile) management is critical to a system like Tazama. There will be a regulatory compliance requirement because Tazama is a Financial Crime Risk Management system. With many containers, as part of the Tazama system, it is ideal to use an IAM solution and more importantly an IAM solution designed to work with containers (Kubernetes)

### KeyCloak Alternatives

Okta, Auth0, OpenIAM, Entrust, Azure Active Directory, Google Cloud Identity, AWS IAM and many others offer competing IAM solution. Staying with open source, it comes downs to Ory, Gluu, IdentityServer.

### KeyCloak and Why

KeyCloak is open source IAM (Identity and Access Management solution). KeyCloak provides a good authorization solution. It supports OpenID, SAML, LDAP and OAuth 2.0. With a containerized system like Tazama, and Ambassador as an API gateway, we need to have an IAM solution that is proven to work well with Ambassador, Linkerd and is Kubernetes native.

## Service Mesh

### Tazama Business Need

Tazama is a financial transactions monitoring system. End to end security is a regulatory requirement. We also needed runtime debugging, observability (real-time), reliability and security between different containers / business logic.

### Why Service Mesh?

We could have used multiple products and/or wrote custom code but a good Service Mesh fulfills all the above business requirements. Plus it provides sending telemetry data to, and receiving control signals from the control plane.

### Service Mesh Alternatives

Consul, Istio, Google Anthos, AWS Service Mesh, HAProxy, Hystrix and more. Specifically open source alternatives are Apache ServiceCombo-mesh, OpenShift Service mesh, Maesh etc. Linkerd is built using rust for high performance and minimal footprint - hence our choice.

### Linkerd and Why

It is a complete service mesh solution and it is open source. Here are the features that are important for the Tazama system:

1. Automatic TLS
2. Automatic Proxy Injection
3. Minimal footprint
4. Low-latency performance impact
5. Ultralight
6. Transperency
7. High Availability Proxy
8. Zero code for implementation
9. Load Balancing for a pod of containers
10. Work well with gRPC
11. Work well with Ambassador
12. Work well with KeyCloak
13. Work well with OpenFaaS
14. Telemetry and Monitoring
15. Pre-configured dashboards (and Grafana)

## Function as a Service

### Tazama Business Need

Requirements include:

- Modularity and extensibility are key design principle​s
- Host business logic as discrete functions (Rules and Typologies, especially) working together in an ecosystem​
- Each function should be atomic​
- Code focussed on business logic rather than the plumbing around it​
- These functions are exposed as services, whether internally or externally​
- Accommodate over 200 Typologies and many more Rules​
- Dynamic Typology selection at implementation or runtime

### Why Function as a Service?

Tazama system is modular. We want to be able to commission and decommission Typologies, Rules, Channels with ease. So these components are associated with each other but function independently. Hence they are implemented as functions. Functions need to be invoked by providing inputs and they will create output that needs to be consumed. Hence these functions are implemented as a Service.

### FaaS alternatives

Kubeless, OpenWhisk, IronFunctions, Fission, Fn. OpenWhisk and OpenFaaS are the most popular.

### OpenFaaS and Why

Welcome OpenFaaS! Serverless. OpenFaaS makes it easy for developers to deploy event-driven functions and microservices in a Kubernetes environment with minimal coding (most of the code is and should be business logic code). It supports the ability to write the code in almost every popular programming language. It is open source. It has the ability to queue REST requests.

OpenFaaS is architecturally simpler and works well with Linkerd. OpenFaaS uses compact/alpine docker images for low-budget implementations. Good community support.​

## Event Monitoring

### Tazama Business Need

There is a need for event monitoring and alerting application for real-time metrics recording in a highly dimensional time-series data model.

### Why Event monitoring?

We need to collect real-time event monitoring metrics across all containers in the Tazama system for real-time observability. ** This does not cover historic observability.

### Event Monitoring Alternatives

Since Prometheus comes packaged along with Linkerd, Prometheus alternatives were not considered. After trying out installations, deployed and other related stories, Prometheus works as per expectations.

### Prometheus and Why

It comes packaged along with Linkerd.

## Real-time Observability

### Tazama Business Need

Tazama system needs open source analytics and visualization for real-time observability.

### Why real-time observability?

With a multi-container system like Tazama, we need to observe performance and operational issues built for Kubernetes-native implementation.

### Real-time observability Alternatives

Since Grafana comes packaged along with Linkerd, Grafana alternatives were not considered.

### Grafana and Why

Grafana is a multi-system analytics and interactive visualization tool. After trying out installations, deployed and other related stories, Grafana works as per expectations.

## Data Flow / Data Processor

### Tazama Business Need

Tazama is a data system. Tazama works with various datasets that help with identifying the transaction characteristics to determine fraud/crime. To collect/receive the data from various external and internal sources, to validate components of the transaction, for provide various dimensions of data aggregation, there is a need for automation of data flow.

### Why Data Flow / Data Processor?

Data Flow automates the flow of data between systems. Tazama system does transaction monitoring with associated services.

### Data Flow Alternatives

IBM Infosphere, AWS Glue, Azure Data Factory, Streamsets, Apache Spark, Airflow, Prefect. Staying open source, Airflow, Prefect are good alternatives. The reason NIFI is a better option because NIFI was built around data and it great when one uses its built-in processors. NIFI is found to be better for real-time data flow and Airflow/Prefect for batch. We made the decision to go with NIFI and our MVP using NIFI has proven that NIFI was a good choice.

### NIFI and Why

Welcome NIFI!NIFI is an end-to-end system that can collect/receive and act of data real-time. Real-time data validation, collection of data from external sources, real-time aggregation, pre-aggregation are data requirements of the Tazama system. NIFI as a tool fulfills those requirements.

## Multi-modal Database

### Tazama Business Need

Tazama system is expected to serve 3k to 10k+ TPS. It is expected to find criminal/fraudulent intent through transaction analysis, pre-aggregation, data enrichment, real-time aggregation, 1000s of Rules and 100s of Typologies in various channels.

### Why Multi-modal database?

There are multiple use cases for graph databases, JSON based datasets as well as structured data. Multi-modal database provides database for graph, semantic search and JSON stores.

### Multi-modal database Alternatives

Its alternatives range from MySQL to Janusgraph and everything option in between.

### ArangoDB and Why

With a few stories, installation and deployment, we did POC with JanusGraph and ArangoDB. We were able to process 4 million+ transactions and validate that ArangoDB will serve the DB needs for Tazama. ArangoDB is multi-modal and we were able to prove it for Tazama use cases.

ArangoDB is expected to serve all DB use cases except for Datalake requirements (historical data). It will also be considered for Datalake requirements, if proven for Tazama Datalake requirements.

## Historic Observability

### Tazama Business Need

Tazama system needs historic observability.

### Why Historic Observability?

Historic observability is needed to solve chronic system issues. It helps make architectural / design decisions for the future either for business, non-functional or performance requirements fulfillment.

### Historic Observability Alternatives

Apache Solr, Google Cloud Search to name a few. To stay open source and cloud provider agnostic, we decided on Elastic. We had hoped to get historic observability using Prometheus and Grafana but they only provide real-time observability.

### Elastic and Why

Elastic (ELK stack: ElasticSearch, LogStash, Kibana) is the most popular open source logging and observability system. Tazama system development stories have proven that Elastic does satisfy our requirements.

## In-Memory Cache

### Tazama Business Need

Caching to improve performance is a key non-functional requirement. Caching is also a critical component in the solution design (There are Tazama system requirements to cache Rules results for a Typology, Typology results for a Channel and Channel results for a Transaction to name a few)

### Why In-Memory Cache?

Multiple enrichment datasets that are expected to be read-only and caching will improve performance. The aggregated transaction data can be cached for performance too.

Caching is also required to collect results from Rules, Typologies and Channels while keeping the Processors and Aggregators stateless.

### Redis Alternatives

Open source alternatives include Memcached. We went with Redis because of the development team’s experience and its popularity.

### Why Redis?

Redis is the most popular in-memory data structure store / cache. Tazama system development stories have proven that Redis is the right cache solution for Tazama system.

## OLAP

### Tazama Business Need

Real-time analytics database (OLAP) suitable for queries on large datasets, example: historic transaction data and enrichment data. Druid will address the user stories around reporting.

### Why OLAP?

In theory one could use any database for querying but OLAP is designed for large datasets that support complex reporting-related queries.

### OLAP Alternatives

Apache HBase, Snowflake, Cassandra are some of the alternatives. We went with Druid because of the comfort level of our development team.

### Druid and Why

Druid stores in column format. It is cloud-native. It can be deployed on scalable distributed processing system for parallel processing. Druid also provides automatic summarization (pre-aggregation) at ingestion.

## Inter-service communication

### Tazama Business Need

Inter-service communication is not a business requirement but rather a non-functional need.

### Why Inter-service communication?

Tazama system contains many components/processors for Rules, Typologies, Channels, Transaction, Data Preparation, Data Transformation etc. Inter-service communication is an understated requirement. Inter-service communication is a non-functional need. Performance and low latency is critical need, especially considering that Tazama system will support millions of transactions.

### Inter-service communication Alternatives

Messaging Queues, Other RPC solutions and REST/JSON are alternatives. Kafka was already used in the POC and required significant infrastructure to support the expected transaction load. Other sophisticated MQ solutions will perform similar to Kafka. Open source alternatives worth considering are ZeroMQ and Nanomsg.

### Why gRPC?

Open source Remote Procedure Call built by Google. gRPC means calling a method hosted on a remote server that you can call as if hosted locally. gRPC supports async as well as sync modes. There are multiple options of communication, unary (single request), server streaming, client streaming as well as bidirectional streaming. Because there are a lot of processors in the Tazama system, all modes/options of communication are considered.

gRPC is designed for both high-performance and high-productivity design of the Tazama system. It supports 10 popular languages. It operates using the following Design Principles:

1. Free and Open - Needed for Tazama system to be completely
2. Services not Objects, Messages not References
3. Interoperability and Reach
4. General Purpose and Performant - key design principle that let’s us use gRPC without sacrificing performance
5. Layered
6. Payload Agnostic
7. Blocking and Non-Blocking (Sync and Async) - provides flexibility to the Tazama system components communication
8. Lameducking - it is helpful with turning off any Rules or Typologies but letting the existing in-flight invocations complete while not accepting new invocations
9. Flow Control - buffer management between Client and Servers which could have unbalanced computing power and network capacity
10. Standardized Status Codes - this helps with developing communication between Tazama system components

## Data Serialization and Queuing

### Tazama Business Need

Data serialization and queuing is not a business requirement but rather a non-functional need.

### Why Data Serialization and Queuing?

OpenFaaS provides queuing for REST requests but with gRPC for Inter-service communication, we will need to serialize and de-serialize for sending it using gRPC. Queuing will need to be addressed considering that Tazama system will support millions of transactions.

### Data Serialization and Queuing alternatives

Apache Thrift and Fast Buffers. Since gRPC and ProtoBuf work natively together, ProtoBuf is the choice for Tazama system.

### ProtoBuf and Why

Method to serialize structured data. Works well and needed for gRPC implementation

## YAML

YAML is widely used format for infrastructure and operational configuration files. We will use YAML format for the same reasons.

## JSON

JSON is widely used format for communication with various Services / micro-services. We will use JSON for the same reasons. The current design includes communication between various Services (Rules, Typologies, Channels etc) via JSON. ** In the next PI, we will explore gRPC and it is very possible that most of the inter-service communication will be replaced JSON with gRPC messages.
