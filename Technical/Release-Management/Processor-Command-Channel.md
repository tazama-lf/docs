# Processor Command Channel – Dynamic Configuration Updates in Tazama

## 1. Background

Tazama evaluates financial transactions for fraud by running them through a set of configurable components:

* **Network map configuration** – describes events to follow for evaluation of the transaction received.
* **Rule configuration** – defines which fraud rules are bands, their thresholds, and other parameters.
* **Typology configuration** – defines typologies (fraud patterns) and how rules and events are combined.

A number of long-running processors rely on this configuration at runtime, including:

* `event-director`
* `typology-processor`
* `tadproc` (transaction analysis/decision processor)

These processors subscribe to NATS/JetStream subjects based on the current configuration, and often cache parts of it in-memory for performance (e.g. rule sets, typology configuration, network map).

### 1.1 The Problem (Before)

Historically, Tazama **could not dynamically update configuration** across the processing estate. Changing configuration had several limitations:

* **Static configuration at startup**

  * Processors read configuration on startup (from the database or environment) and then assumed it was stable.
  * Any change to network map, rules, or typologies required a **restart or redeploy** of the relevant processors.

* **No coordinated propagation**

  * There was no central mechanism to **broadcast** a configuration change to all affected processors.
  * Individual teams sometimes resorted to manual restarts, ad-hoc scripts, or environment tweaks to force reloads.

* **Runtime inconsistency**

  * During rollout of configuration changes, different processors could be on **different versions** of configuration.
  * This could lead to:

    * Inconsistent rule evaluation results between services
    * Hard-to-debug behaviour in production
    * Risk when making urgent fraud-rule adjustments

Because of this, Tazama lacked a robust way to **safely, consistently, and quickly roll out configuration changes** across all processors.

---

## 2. Solution Overview: Processor Command Channel

To address these gaps, we introduced the **Processor Command Channel**.

The Processor Command Channel is a JetStream-based messaging mechanism that:

1. Allows **Admin Service** to accept configuration update requests.
2. Persists the **new configuration** to Postgres (the system of record).
3. Broadcasts a **command message** via JetStream to **all relevant processors**.
4. Each processor:

   * Fetches the latest configuration from the database, and
   * Performs its own **runtime reconfiguration** (re-subscribing to NATS, clearing caches, etc.), without redeploy or restart.

At a high level:

> **Admin Service → Postgres → JetStream Command Channel → Processor(s)**

---

**Explanation:**

1. **User → Admin-Service: Publish latest config**\
   The user sends a new configuration to the Admin Microservice.
2. **Admin-Service → DB: Save latest configuration**\
   Admin-Service validates and stores the new configuration in the Configuration DB as the latest version.

   2.1. **Admin-Service → NATS (JetStream): Publish config update event**\
   After saving, Admin-Service publishes a `config.updated` event to NATS (JetStream), including headers like `config-type: network-map`.
3. **NATS(JetStream): Act as the command/config bus**\
   NATS receives the event and makes it available on the relevant COMMAND topic that microservices are subscribed to.

   3.1. **NATS → ServiceA / ServiceB: Trigger config update event**\
   Tazama Microservice A and B receive the config update event from NATS(JetStream) as subscribers.
4. **Service: Apply and reload config**\
   Services clears any related cache, and pulls new config from database, hot-reloads to start using the new configuration.

### Sequence diagram

```mermaid
sequenceDiagram
    participant User as User
    participant AdminService as Config Microservice
    participant DB as Configuration DB
    participant NATS as JetStream Bus
    participant ServiceA as Tazama Microservice A
    participant ServiceB as Tazama Microservice B

    User ->>AdminService: Publish latest config
    AdminService->>DB: Save latest configuration
    AdminService-->>NATS: Publish config update event (e.g. config.updated)<br>header<br>"config-type": network-map<br>"process-target": "Rule Processor"
    Note over NATS: Microservices subscribe to this COMMAND topic
    NATS-->>ServiceA: Push config update event
    NATS-->>ServiceB: Push config update event
    ServiceA->>ServiceA: Apply latest config if applicable<br>Clear applicable config cache<br>Hot-reload
    ServiceB->>ServiceB: Apply latest config if applicable<br>Clear applicable config cache<br>Hot-reload
```

### Flow Diagram

```mermaid
flowchart TD
    U[User] -->|Publish latest config| CS[Admin Service]

    CS -->|Save latest configuration| DB[(Configuration DB)]

    CS -->|Publish config update event<br/><code>config.updated</code><br/>config-type: <code>network-map</code><br/>process-target: <code>Rule Processor</code>| NATS[JetStream Bus]

    subgraph Subscribers
        SA[Tazama Microservice A]
        SB[Tazama Microservice B]
    end

    NATS -->|Push config update event| SA
    NATS -->|Push config update event| SB

    SA -->|Apply latest config if applicable<br/>Clear applicable config cache<br/>Hot-reload| SA_DONE[[Config applied on Service A]]

    SB -->|Apply latest config if applicable<br/>Clear applicable config cache<br/>Hot-reload| SB_DONE[[Config applied on Service B]]
```


## 3. Configuration Domains

The Processor Command Channel supports dynamic updates for the main configuration domains in Tazama:

* **Network Map Configuration**

  * Changes to entity relationships, routing, or any network-based metadata used by processors.

* **Rule Configuration**

  * Threshold adjustments (e.g. amount limits, velocity thresholds).
  * Rule parameters, such as timeframes or comparison strategies.

* **Typology Configuration**

  * Adding/removing typologies.
  * Changing which rules feed into a typology.
  * Modifying typology-level decision logic.

Each processor reacts only to the configuration domains it cares about (e.g. `typology-processor` focuses on typology-related updates, `tadproc` on rule and network-related updates, etc.).

---

## 4. End-to-End Flow

### 4.1 Step-by-step Sequence

1. **Admin Service receives request**

   * An administrator (via UI/API) submits a configuration update:

     * e.g. “Update rule thresholds”, “Enable new typology”, “Change network map for a tenant”.

2. **Admin Service persists new configuration**

   * Admin Service writes the updated configuration into **Postgres**, typically into:

     * `network_map` table (JSON configuration)
     * Rule configuration tables
     * Typology configuration tables
   * The database becomes the **authoritative source** for the new configuration version.

3. **Admin Service publishes a command**

   * After a successful DB update, Admin Service publishes a **command message** to the **Processor Command Channel** via JetStream.
   * The command contains metadata such as:

     * Configuration domain(s) affected (network / rules / typologies)
     * Tenant(s) or scope (if multi-tenant)
     * Version identifiers or timestamps
     * Optional hints (e.g. “only typology processors need to reload”)

4. **Processors receive the command**

   * Each processor (e.g. `event-director`, `typology-processor`, `tadproc`) has a **JetStream consumer** subscribed to the Processor Command Channel.
   * On receiving a command, it:

     1. **Gets** the message header configuration type.
     2. Fetches the relevant **latest configuration from Postgres**.
     3. Applies internal update logic:

        * **Re-subscribing to NATS**

          * Unsubscribes from old subjects where necessary.
          * Subscribes to new subjects defined by the new configuration (e.g. new event or typology subjects).
        * **Clearing in-memory caches**

          * Node-level caches of configuration, rule sets, typologies, or network maps are flushed.
          * New configuration is loaded into memory.


5. **Processors resume evaluation with new configuration**

   * After updating themselves, processors continue processing new transactions/events using the **updated configuration**, without downtime or redeploys.

---

## 5. Design Goals and Benefits

### 5.1 Design Goals

* **Dynamic configuration without redeploys**

  * Operators can push configuration changes at runtime.

* **Consistent configuration across processors**

  * All participating processors are notified and reconfigure themselves in a controlled, coordinated manner.

* **Decoupled responsibilities**

  * **Admin Service**: owns configuration lifecycle and persistence.
  * **Processors**: own their runtime behaviour and configuration application.
  * **JetStream**: provides reliable broadcast and delivery semantics.

* **Horizontal scaling friendly**

  * Multiple instances of each processor can listen on the Processor Command Channel (using queue groups or JetStream consumers) and all reach a consistent configuration state.

### 5.2 Benefits

* **Faster reaction time to fraud**
  Adjust rules and typologies within minutes instead of waiting for deployments.

* **Reduced operational risk**

  * Less manual restarts / redeploys → fewer opportunities for misconfiguration and human error.

* **Clear auditability**

  * Changes are persisted in Postgres first.
  * Commands can be traced via JetStream, allowing auditing of who changed what and when.

---

## 6. Responsibilities per Component

### 6.1 Admin Service

* Receive and validate configuration update requests.
* Persist changes to Postgres.
* Publish Processor Command Channel messages after successful persistence.

### 6.2 Processors (event-director / typology-processor / tadproc)

* Subscribe to Processor Command Channel via JetStream.
* On command:

  * Fetch updated configuration from Postgres.
  * Rebuild subscriptions to NATS subjects as needed.
  * Clear Node.js caches and rebuild runtime configuration state.
* Continue processing transactions using updated configuration.

### 6.3 JetStream / NATS

* Host the **Processor Command Channel** stream.
* Ensure reliable delivery of configuration commands to consumers.
* Support horizontal scaling via consumer groups and multiple instances per processor type.

---

## 7. Summary

The **Processor Command Channel** transforms Tazama from a mostly statically configured fraud evaluation engine into a **dynamically configurable** platform.

By centralizing configuration changes in **Admin Service + Postgres** and then broadcasting those changes via **JetStream** to all processors, Tazama achieves:

* Runtime-safe configuration changes
* Consistent behaviour across all processors
* A cleaner boundary between configuration management and transaction processing
