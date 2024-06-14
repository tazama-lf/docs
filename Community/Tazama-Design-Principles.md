<!-- SPDX-License-Identifier: Apache-2.0 -->

# Design Principles

In order to ensure that the system is built on good foundations, we follow a number of design principles for Tazama.

- [Design Principles](#design-principles)
  - [Open-source](#open-source)
  - [Cloud-native / Cloud agnostic](#cloud-native--cloud-agnostic)
    - [Containerized](#containerized)
    - [Dynamically orchestrated](#dynamically-orchestrated)
    - [Microservices oriented](#microservices-oriented)
  - [Reduce Total Cost of Ownership](#reduce-total-cost-of-ownership)
    - [Time to Production](#time-to-production)
    - [Infrastructure costs](#infrastructure-costs)
    - [Operational / Maintenance (excluding Infrastructure) costs](#operational--maintenance-excluding-infrastructure-costs)
  - [Keep a constant eye on technical debt](#keep-a-constant-eye-on-technical-debt)
  - [Design for Large scale as well as Low budget infrastructure](#design-for-large-scale-as-well-as-low-budget-infrastructure)
  - [Security-first / defence in depth](#security-first--defence-in-depth)
  - [Smart state management](#smart-state-management)
  - [Design for automation](#design-for-automation)
  - [Preserve Ambiguity](#preserve-ambiguity)
  - [Always be architecting / Never stop architecting](#always-be-architecting--never-stop-architecting)

## Open-source

Tazama system is an open-source system where anyone can deploy and run it in their infrastructure without responsibility to pay for any tool upfront or via subscription. If one has an existing infrastructure then they pay $0 to run the Tazama system.

## Cloud-native / Cloud agnostic

Cloud-native / Cloud agnostic design implies the open source computing stack to be:

1. Containerized
2. Dynamically orchestrated
3. Microservices oriented

### Containerized

Each component of the Tazama system is containerized. Whether it is OpenFaaS services or ArangoDB or Druid. This facilities reproducibility, scalability, transparency, and resource isolation. It also solves a lot of the deployment concerns by including all the dependencies in the container.

### Dynamically orchestrated

All the containers are orchestrated using Kubernetes. Containers are actively scheduled and managed to optimize resource utilization. This helps automate the following:

1. Monitoring of the system (including all components)
2. bringing the components (containers) up and down
3. ensure all configurations are properly setup and dependencies are included
4. load balancing
5. sharing authentication secrets between containers

### Microservices oriented

The system is segmented into Microservices. Rule, Typology and Channel implementations are as a microservice. Each microservice performs a specific function. Each microservice is atomic. This design increases the overall agility and maintainability of the system. At the same time, this design makes it easy to develop the overall system by division of labour amongst the members of the development team who work on different microservices reducing multiple developers working on the same code base minimising code conflicts.

## Reduce Total Cost of Ownership

Total Cost of ownership (TCO) is all cost incurred at the asset level from its conception through to disposal at the end of its useful life. Reducing TCO is a no-brainer but at the same time very easy to lose sight of while going through the development process.

These elements factors into the TCO:

1. Time to Production
2. Infrastructure costs
3. Operational / Maintenance (excluding Infrastructure) costs

### Time to Production

We save time from concept to production by doing the following:

1. We do not re-invent any wheels.
2. We use popular open-source products.
3. We POC them to ensure they fulfil the business requirements of the Tazama system.
4. We do minimal customization. Most of the effort is spent in designing and writing the business logic.
5. We re-use as much code as possible.

> :warning: 1. We do not re-invent any wheels. *We used Kubernetes*
> 2. We use popular open-source products. *Example: OpenFaaS, ArangoDB, Druid etc*
> 3. We POC them to ensure they fulfil the business requirements of the Tazama system. *Example: ArangoDB, Linkerd etc*
> 4. We do minimal customization. Most of the effort is spent in designing and writing the business logic. *Example: Linkerd comes packaged with Prometheus and Grafana. We did not customize Prometheus or Grafana. We did not customize Linkerd. We used OpenFaaS as recommended and wrote Rules and Typologies (business logic)*
> 5. We re-use as much code as possible. *Example: All the Rules follow a standard coding template. The Rules only differ in the business logic. The same applies to Typologies.*

### Infrastructure costs

We understand that some of the users of the open source Tazama system will not have budget or access to extensive infrastructure. We therefore designed Tazama to support smaller budgets, without compromising on functionality.

At the same time, there will be some users who will want to use Tazama system to scale to higher volumes, and have the appropriate resources to deliver. Tazama system supports these users too.

Example: In the POC phase, we observed (and measured) that Kafka scaling required an expensive infrastructure as well as maintenance. In the MVP phase, we looked at Kafka alternatives; the alternatives were not just another set of MQ products but rather that the design alternatives to reduce the infrastructure costs.

### Operational / Maintenance (excluding Infrastructure) costs

Once in Production, if not checked, the Operations / Maintenance costs of running the Tazama system can become significant. Here is what we have done to help keep these costs to a minimum:

1. Containerized - these are mostly compact OS containers that have the own dependencies and configurations. So it is easier to trobleshoot, modify or customize.
2. Kubernetes Orchestrated - scaling up or down the number of containers can be a laborious and expensive task if not automated. Kubernetes solves that challenge.
3. Standard products / tools - we have used industry popular products and tools (example: Linkerd, OpenFaaS) etc, so there is reliable information available publicly to support the overall Tazama system.
4. Separation of configuration and code - we have designed and coded the Tazama system to keep configuration and code separate to enable efficient and effective maintenance.
5. Separation of computing and business logic code - we have designed and coded the Tazama system to keep the technical / computing pieces of code and the business logic code as separate as possible. This makes it easy to update / build-new the business logic in less time and cost.

## Keep a constant eye on technical debt

Technical debt is unavoidable in Software / system development. What we can do is keep it to a minimum. Here are the following actions we have taken (and will continue to do so):

1. Use standard products / tools
2. Modularized code
3. Code re-use
4. Products / tools POC to ensure that satisfy the requirements
5. Separation of code and config
6. Separation of computing code and business logic
7. Review every story at Hairwash and Grooming with tech debt in mind
8. Clearing define and document story definition, steps and acceptance criteria to ensure we do not build anymore than what is required and that we do not re-invent the wheel
9. Identify relationships between stories (dependencies - block / blocked-by) to ensure we re-use code

## Design for Large scale as well as Low budget infrastructure

This is an important design requirement for the Tazama system. We expect some users to have an extensive implementation whereas some others to have a minimal infrastructure. Here is how Tazama system is designed:

1. Identify and POC tools and products with minimal footprint
2. Identify and POC tools and products with minimal computation requirement
3. Modularize system into many components / microservices that are atomic, to pick and choose for implementation. Microservices also enables implementation on a minimal infrastructure and at the same time use Containers / Kubernetes to scale up significantly for extensive infrastructure implementations
4. Use caching in design to reduce consumption of computing resources
5. Reduce inter-service communication (avoid any unnecessary communication between services) and use compressed messages for communication to increase overall efficiency as well as reduce network traffic within the Kubernetes cluster
6. Highly configurable Rules, Typologies and Channels to support very small as well as very big implementations

## Security-first / defence in depth

This design principle goes without saying, considering what Tazama system is supposed to do. Security has been thought-about before we adopted any tools/products as well as began writing code. Here is how we did it:

1. Chose Ambassador as the Cloud-native API Gateway
2. Chose Keycloak for authentication and authorization as well as multi-tenant profile management
3. Chose Linkerd that provides mTLS between all the containers in the Tazama system. Linkerd provides security without much compromise on performance of the services
4. Design the system to have only one Ingress Point, which is the TMS API. Exceptions are Payment Platform Adapter Or Custom Data Transformation but if they are implemented then they replace TMS API as the Ingress point. Either ways, there will be only one Ingress Point.

## Smart state management

State management for Tazama is critical, as it is primarily Transaction Monitoring system. The transaction flows through many components / services (channels, typologies, rules, channel scoring processor etc) and the smart state management of the transaction through these services is critical to ensure transaction integrity:

1. that we process only those rules and typologies associated with at transaction
2. we do not duplicate the processing of any of the rules or typologies associated with that transaction
3. that we can query the state of transaction at any point in time (example: what channels is processing that transactions and how many Rules have completed execution etc)

## Design for automation

More automation means less Operational costs and less probability of errors. The Tazama system is designed for automation at the following levels:

1. Automated scaling (up or down)
2. Automated deployment (Kubernetes cluster deployment)
3. Automated Linkerd injection (Inter-service mTLS / Security / Real-time observability)
4. Automated Telemetry data points collection
5. Automated Inter-service communication
6. Automated Transaction Aggregation & Decisioning Processor
7. Automated Transaction-Channel decision-making
8. Automated Transaction-Rule/Typology association determination
9. Automated Transaction interdiction

## Preserve Ambiguity

This translates to make decisions later, or make only those decisions that need to be made. Not every choice needs to be made before the implementation begins. Tazama system development has adopted this design principle. Example: We are assuming that we will need ArangoDB as well as Druid. They both have different query languages but in theory ArangoDB can do what Druid does. But we have left both ArangoDB and Druid in the architecture and in the next PI we will decide via some measurement stories if we need to have both or can we just live happily with ArangoDB.

Some say that if it is easy to be made later then it is not an architecturally significant decision.

## Always be architecting / Never stop architecting

With agile methodology thoroughly adopted, we cannot stop architecting or designing any product or system. The same applies to the Tazama system.

1. Adopted products / tools get updated frequently (newer versions ing newer features, some of which we will adopt)
2. New architecture / design philosophies come up frequently and Tazama system will consider that
3. Tazama system will continually strive to improve performance and reduce costs (achieving both at the same time is not easy but with proper architecting and adopting good design patterns it can be done)
4. With increased adoption of the Tazama system, new Business requirements and NFRs will come up and they need to be architected, designed and implemented
