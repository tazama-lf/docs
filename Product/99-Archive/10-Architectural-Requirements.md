# Architectural Requirements

[Design considerations](../architecture-and-design/design-considerations.md)

Here is my understanding of the architectural requirements:

1. MVP is more than just a conventional Minimum Viable Product. I need more clarity on this
    1. **Justus**: Our MVP is scoped out to contain the minimum features that would allow a Mojaloop switching hub operator to attach a transaction monitoring service to their eco-system for all transactions flowing through the hub. The MVP will ultimately have to rely on “development” effort to implement, though the long-term vision is to be able to rather deploy the solution through no/low-code configuration by a small team of average-skilled in-house resources.
    2. We may be building some foundation of that future vision now where it makes sense, and in particular where it provides us with tools that we can also use to build the system. For example, without some kind of “rules-builder” utility, we’d have to build all the rules by hand through development. We believe that there’s a convergence in effort between building a toolkit to build rules and then using it to build rules and alternatively building rules by hand that falls inside the timelines of the MVP.
    3. Speaking of the timelines, we are currently working on the first Program Increment (PI) of the MVP, which focuses on establishing the conceptual design, solution architecture, technical architecture and then implementing that architecture as the foundation for work to be conducted in the remaining PIs of the MVP. At the moment we only expect the scaffolding, with only enough functionality implemented to string the components together into a cohesive and illustrative flow. The “content” of the solution, i.e. the rules and typologies, will be only added in subsequent PIs.
    4. **Darshan**: It will be good to have / use a few Typologies/Rules real-world examples for benchmarking as well as for success criteria (functionality validation + performance test) of many stories
2. Performance Requirements: We need to be able to process 10k TPS as proved in the POC
    1. **Justus**: There are a number of performance metrics that we’re aiming for. 10k TPS is our target at peak performance, though an average of 3k TPS is probably acceptable as our short-term MVP goal, since that’s what Mojaloop is currently expected to run at. We know that it’s not a high target, so our objective is to be able to scale our solution to meet the burst rate as well.
    2. Another metric is the turn-around time for a high-speed evaluation at 35 milliseconds. While Mojaloop hasn’t provided a specific metric for this, Tazama is targeted at real-time push-payments integration and we are effectively competing with the turnaround times of credit card processing solutions.
    3. Not directly related to performance, but some of our other design principles are focused on maximizing performance in a cost-effective way. In other words, we can’t just throw infinite resources at the solution to achieve our performance goals.
    4. **Darshan**: Performance vs Cost is directly proportional. Through performance tests we will have to find that balance (least possible cost for minimum expected performance) once the infrastructure is in place and when we run a few real-world Typologies/Rules/Scoring models.
3. Leverage POC.
    1. **Justus**: Not entirely. We want to leverage the learnings from the PoC, but we’re expecting to have to build the solution from the ground up for the MVP based on those learnings. I don’t think we have a list of do's and don’ts though, but it may be worth articulating exactly what we learned from the PoC that offer value for the MVP.
    2. **Darshan**: We should definitely use the 4 Typologies built as part of the MVP.
4. Kafka was used in the POC but now Kafka is being replaced with OpenFaaS. I am not sure they are parallel technologies but more complimentary.
    1. **Justus**: Just to document for the record: We based the PoC on Kafka because our architecture at the time followed a similar pub/sub pattern to Mojaloop which is intended to be our initial “host” implementation. One of the challenges we soon discovered was a proliferation of topics/queues with highly variable life-cycles; a topic/queue for each rule, a topic/queue for each typology.
    2. At the time (and even now) we are not sure exactly how many rules we are likely to have. The selection of the typology-based approach was an attempt to mitigate the challenge by collapsing rules into the typologies to minimize the number of topics to the 270 that we already knew about and in anticipation that there’ll be far more rules to evaluate in the “Don’t Repeat Yourself” (DRY) approach of the pipeline-based rules-driven approach. Also, the pipeline-based approach required some additional complexity and overhead to coordinate the rules results back into typology results, in particular due to the high variability in the turnaround times of each of the rules.
    3. Even though the typology-based approach was easier to implement, we still feel that it was a very inefficient approach because we ended up executing many of the rules multiple times within separate typologies. That feels like a bit of a waste of resources, both in the operation and also in the development.
    4. **Darshan**: We definitely do not want in-efficient / duplicated (or triplicated / multipli-cated) execution (running the same rule for multiple Typologies for the same transaction)
5. The MQ is being removed, so we lose the following: **Justus**: by MQ, are we referring to Kafka?
    1. Guaranteed Storage
        1. **Justus**: This sounds like a big deal, but I’m not sure what we mean by “losing” this capability and what is meant by “guaranteed storage” in the context of our solution?
        2. **Darshan**: I meant Guaranteed Delivery and store it until delivered so we do not lose any transactions. Without Kafka or MQ, we need to ensure that Guaranteed Delivery happens with the combination of Redis and DB
    2. Replay abilities
        1. **Justus**: I understood replayability to have a lot more to do with version control and data provenance than the queuing solution specifically, though it is probably worth isolating the scope of replayability to a specific transaction and not all transactions within a specific time-frame, for example. We want to be able to see how a specific transaction was processed in the system by walking through the steps the system took when processing the transaction. I don’t (at the moment) have a requirement for replaying more than one transaction.
        2. **Darshan**: Replay is about the ability to reprocess a message (in our case transaction) which Kafka provides. We can do the same via DB. The point to take here is that, losing this Kafka ability is OK for our architecture
    3. One publishers to many subscribers
        1. **Justus**: Yes, I think the ease with which this is implemented in a pub/sub architecture is something that we’re going to miss, but mitigating this through a Redis cache solution looks like it could work. Moving from the pub/sub to a DB-based “queue” also helps solve the high variability in the data/queue half-life.
        2. **Darshan**: I agree, this is the biggest loss with not using Kafka or another other MQ. The other losses pale in comparison.
6. Replacing Kafka with OpenFaaS so that we can still have the below:
    1. Decoupling
    2. Language agnostic development of micro-services
    3. Queuing up of the services? (built-in or configurable or have to programmed)
    4. Parallel processing
    5. **Justus**: I’m also expecting a higher level of dynamism here. Not every transaction will require processing by every rule and typology and it may be worth releasing the resources that aren’t required and only creating processors when required. I don’t know that we’ll necessarily spin processors up and down the whole time, but we will need more directed approach in engaging the processors rather than the current shotgun approach.
    6. **Darshan**: Spinning up and down is now blackboxed with OpenFaaS / Kubernetes. I am not sure we need a more directed approach in engaging with the processors. This is where we should expect Linkerd/OpenFaaS to handle the efficient calling of topologies and rules.
7. OpenFaaS gives us these benefits that Kafka did not provide:
    1. Ability to scale up and down each micro-service independently
8. Linkerd gives us these benefits that Kafka/nginx did not provide:
    1. End to end Security that would have be custom built, especially now that we have multi-tenant as a requirement
    2. Control Plane (especially Service Profile Validator) that would have to be customized using nginx or the likes
    3. Integration with Prometheus
    4. Integration with Grafana
9. Replacing nginx with Linkerd so that we can still have the below:
    1. Load / traffic balancing
        1. **Justus**: Is this something that could be handled in the sub-strate (e.g. Kubernetes)? What alternatives to we have for this functionality if we implement Linkerd? Do we need to then implement nginx in addition to Linkerd, which then appears to provide a whole lot of redundant features that overlap with Linkerd, or do we have to look for a fit-for-purpose specialised solution for just this functionality, or do we need to build/plug something into Linkerd?
        2. **Darshan**: There will be no need to implement nginx once you have Linkerd
    2. Identity / Certificate Authority
        1. **Justus**: How does this functionality in nginx compare what appears to be offered in Linkerd under point 8.a. above? What alternatives to we have for this functionality if we implement Linkerd? As above, do we need to then implement nginx in addition to Linkerd, or do we have to look for a fit-for-purpose specialised solution for just this functionality, or do we need to build/plug something into Linkerd?
        2. **Darshan**: Lot of this is implicitly offered by Linkerd.
10. Centralized Multi-tenant management
11. Centralized Operations Management / Telemetry
12. Database as a Service (DaaS)
    1. **Justus**: I need to understand what this means in the context of our solution. We have need for data storage for a variety of configuration and operational purposes, and also of a variety of different fit-for-purpose types of storage and access methods. Simultaneously, we are trying to keep the over-all complexity of the solution to a minimum to avoid the need for a large team of specialists or a key-man dependency on a highly skilled individual. What does DaaS offer over non-Daas/traditional DB services?
    2. **Darshan**: One word answer is Scaling. We are talking about Scaling using Containerization for Transaction Processing/Montoring. We are talking about a different datastores with a lot of transactions expected to be processed. But as discussed, we can drop this from the MVP requirement.
13. Graph database
    1. **Darshan**: Based on the installation, configuration, testing, benchmarking queries, easy of use, UI etc, we have decided to go with ArangoDB

Concerns:

1. Using kubernetes increases the footprint
2. Using OpenFaaS further increases the footprint
3. Implementing on smaller infrastructures looks difficult with Kubernetes, OpenFaaS
    1. **Justus**: A multi-tenanted solution is offered as an alternative to a small, stand-alone implementation to assist in minimise cost of operation through some cost-sharing. This becomes more of a strategic discussion, since it creates an opportunity to operate a multi-tenanted FRMaaS solution as a revenue stream. We also have to balance the cost of developing and maintaining two separate architectures to cater for different scales as opposed to a single architecture for 80% of the target market. And we need to decide if we’re talking about the 80% in volume or the 80% in revenue. I’m leaning towards building for medium to large scale up (3000 to 10000 TPS) and using that same architecture to host multi-tenanted customers with less than 3000 TPS.
    2. **Darshan**: We need to be very specific in defining the requirements for small. stand-alone implementation. The smallest K8s option is to package everything into one one K8s cluster running one node.
4. Decision on the choice of Graph DB
    1. **Justus**: We may have spent too much time on this already and I think the metrics for picking a specific graph DB are vague, if defined at all. The current tests are focussed on, firstly, capability to do the work (which honestly, is not disputed in either candidate) and a subjective measure of the ease of use, which is problematic since both DBs are being evaluated by separate people, each with their own reference framework and level of skill. Unfortunately, no-one in the team has any tangible experience in this regard, which means that we may just as well have settled on a “desktop” evaluation of the candidates on paper and worked with the one we have until it proves itself unfit for whatever reason.
    2. **Darshan**: As of today, Mar 10, 2021, we have made the decision to go with ArangoDB in a docker container.
    3. Here are a couple of key selection factors for me:
        1. It must be Gremlin compatible, natively is preferred to a plug-in, both of which are better than a translator. Gremlin is the current language of choice for commercial high-scale and native cloud-based solutions such as Cosmos DB (Azure) and Neptune DB (AWS). Neo4J still prefers Cypher, but at least has a Gremlin adapter.
        2. It must be “graph-native”, in other words, it can’t be a rendered or interpreted graph sitting on top of non-graph storage. The graph must be stored *as a graph*. A interpreted graph will adversely affect performance.
    4. In addition to these requirements, there are probably some additional non-functional requirements that I am unable to articulate, such as interoperability, over-all architecture fit, scalability, etc.
5. With multi-tenant requirement, each set of typologies/rules/scoring, Data Pipeline Components, Enrichment data components, associated Datastores will have to be deployed as a separate set of containers for each tenant
    1. **Justus**: This is something we’ll need to figure out. The more shared resources there are, the lower the over-all cost. I don’t yet see why the transactions for a number of tenants can’t flow through the same “channel” of the channel itself is capable of orchestrating the engagement of the rules and typologies based on the attributes of the transaction. The same rule and the same typology may be relevant and run across multiple tenants, so why not run it DRY?
    2. **Darshan**: If the business and tenants allow for letting us share resources (example: running transactions through the same “channel”) then I am for it. Sharing resources will keep the architecture manageable and simpler with centralized tenant management (users, logs, topologies, rules etc)
6. With multi-tenant requirement, do we create a separate set of containers for Payment Adaptor?
    1. **Justus**: This will depend on whether the tenant can interface directly with the API without an adaptor or needs an adaptor because they have, for example, a legacy system with an egress methodology they can’t change. Each tenant (or perhaps, more accurately, each unique type of non-compliant API call) will probably need its own adaptor which would then probably run in its own container.
    2. **Darshan**: Makes sense.
7. With multi-tenant requirement, share UIs, Operations Management / Telemetry, Dashboards across tenants?
    1. **Justus**: For the most part, yes, but each tenant must be restricted to sight of only their own data. Furthermore, the entire FRM data eco-system must be segregated for each tenant, i.e. a tenant must not be able to benefit from the behavioural modeling of a transaction or participants across the eco-system. The modeling must be ring-fenced to only data that had been sourced from that tenant. Configuration of the system would be centralised and performed by the service operator on behalf of the tenants though. A tenant should not have direct control over the configuration or operation of the solution.
    2. **Darshan**: The tenant should just be able to configure users, topologies, rules and observe logs and performance.

Suggestions for development:

Work on 5 different tracks:

1. Business logic (Typologies, Rules, Scoring etc) without worrying about DevOps or Infrastructure
    1. **Justus**: My preference is to move this to a future PI. This work represents the “content” that will be deployed to the scaffolding once it is in place and stable.
    2. **Darshan**: Sounds good to me. Let’s keep the 4 typologies and rules from the POC for testing purposes.
2. DevOps and Infrastructure (Linkerd, OpenFaaS, DaaS, other cloud offerings etc). Adding Prometheus, Grafana and ELK here.
    1. **Justus**: This is my vote for our first priority
    2. **Darshan**: Definitely # 1
3. Multi-tenant
    1. **Justus**: I’m not sure where we should fit in this work just yet. I think there’s a strategic decision to be made first so that we can resolve the actual requirement, and then the implementation of this may have to follow 2 above and 5 below. I’m not sure how must is likely to change in the scaffolding, regardless of our decision, and I suspect the bulk of the changes will relate to the data pipeline (to enforce segregation). I need some expert advice here, and in particular how soon we need to finalise this decision before we have more technical debt we can pay back.
    2. **Darshan**: If we run the transactions for multiple tenants through the same channels, then multi-tenant is primarily around administration/operations. Earlier we make the decision around multi-tenants the better. # 3
4. Graph DB / ELK
    1. **Justus**: This needs to be resolved before number 1 above, so that we are able to build rules and typologies that require a graph database solution for efficient execution. I do not expect that the architectural impact will be debilitating and I think we’ll be able to implement a graph DB component seamlessly into the architecture even after 2 above is complete. I’d appreciate an expert opinion here as well, especially since the introduction of new tools to deal with a specific type of rule or typology in a bespoke way may happen naturally in the future as the system evolves. We may find an alternative or better way of executing a rule and we should be able to implement that enhancement without undoing the whole architecture around that point.
    2. Darshan: We have decided with ArangoDB. # 0 - Since it is done. We will move ELK, Prometheus, Grafana to item 2.
5. Data Pipeline
    1. **Justus**: This is my vote for our second priority
    2. **Darshan**: #2 it is.

What is in MVP?

**Justus**: We have an agreement with the Bill & Melinda Gates Foundation that outlines our objectives and commitments for the MVP. In essence it is the architecture and rules to evaluate fraud and money laundering in transactions originating from a Mojaloop platform across all of the transactional typologies relevant to such an operation.

What all we need to Demonstrate?

**Justus**: Transactions in, fraud out.

**Darshan**: Thanks. I also meant which tools we need to demonstrate - so that we know they belong in the implementation.

What all do we need to assume that it is supported?

**Justus**: Can you clarify the question?

**Darshan**: List of assumptions. Example: Can we assume that OpenFaaS provides some sort of queueing.

Discussion Points:

1. This MVP needs to include architectural and infrastructure components for the following reasons:
    1. Volume of Transactions
    2. Speed of Transaction Processing (example: 10k TPS)
    3. Security
    4. Language agnostic development of Typologies, Rules and Scoring
    5. Ability to dynamically commission and decommission Typologies, Rules and Scoring
    6. Ability to handle various types of Data
    7. Foundation for building components on top
    8. Scaling up and down the infrastructure
2. Time and Ability to demonstrate
3. Time and Ability to Fail
4. Time Ability to Fail fast

Thanks

Darshan
