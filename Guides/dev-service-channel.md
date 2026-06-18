<!-- SPDX-License-Identifier: Apache-2.0 -->
<!-- Last reviewed: 2026-06-19 -->

<a id="top"></a>

# Service Channel Developer Guide

The **service channel** is Tazama's control-plane messaging fabric: a lightweight, broadcast publish/subscribe channel that lets one service signal an operational change to the rest of the deployment without coupling them through the database or the transaction-processing path. This guide explains what the service channel is, the components that make it work, how a signal travels end to end, and how you extend it to additional services. Throughout, it uses the **network map reload** feature as a running, real-world example.

This is a developer-facing guide. It assumes you are comfortable with TypeScript, Node.js, and the basics of [Tazama's architecture](https://github.com/tazama-lf/docs/blob/main/Technical). You do not need prior knowledge of [CloudEvents](https://cloudevents.io/) or [NATS](https://nats.io/) - both are introduced here.

## Table of Contents

- [Service Channel Developer Guide](#service-channel-developer-guide)
  - [Table of Contents](#table-of-contents)
  - [1. Why a Service Channel Exists](#1-why-a-service-channel-exists)
  - [2. The Three Layers](#2-the-three-layers)
  - [3. Core Concepts](#3-core-concepts)
    - [3.1 The CloudEvents Envelope](#31-the-cloudevents-envelope)
    - [3.2 Subjects and Local Perspective](#32-subjects-and-local-perspective)
    - [3.3 Broadcast Fan-Out and Core NATS Semantics](#33-broadcast-fan-out-and-core-nats-semantics)
    - [3.4 Audience Addressing](#34-audience-addressing)
    - [3.5 Acknowledgements](#35-acknowledgements)
  - [4. Worked Example: Network Map Reload](#4-worked-example-network-map-reload)
    - [4.1 The Problem](#41-the-problem)
    - [4.2 The Activation Side-Channel Signal](#42-the-activation-side-channel-signal)
    - [4.3 The Dedicated Reload Endpoint](#43-the-dedicated-reload-endpoint)
    - [4.4 The Loud 503 Design](#44-the-loud-503-design)
  - [5. Reload Modes in Depth](#5-reload-modes-in-depth)
    - [5.1 Broadcast](#51-broadcast)
    - [5.2 Cascade](#52-cascade)
    - [5.3 None](#53-none)
  - [6. Producing an Event](#6-producing-an-event)
  - [7. Consuming an Event](#7-consuming-an-event)
  - [8. Extending the Service Channel](#8-extending-the-service-channel)
    - [8.1 Add a New Consumer](#81-add-a-new-consumer)
    - [8.2 Add a New Event Type](#82-add-a-new-event-type)
    - [8.3 Add a New Producer Endpoint](#83-add-a-new-producer-endpoint)
    - [8.4 Add a Tier to the Cascade](#84-add-a-tier-to-the-cascade)
  - [9. Configuration Reference](#9-configuration-reference)
  - [10. Testing](#10-testing)
  - [11. Design Principles](#11-design-principles)
  - [12. Further Reading](#12-further-reading)

## 1. Why a Service Channel Exists

Tazama services already share two planes:

- The **transaction plane** - the high-throughput NATS subjects that carry payments through the pipeline (Transaction Monitoring Service to event-director to typology-processor to event-adjudicator). This plane is latency-critical and load-balanced.
- The **data plane** - the configuration databases that hold network maps, rules, and typologies.

Neither plane is a good fit for *operational signaling*. When an operator activates a new network map through the admin-service, every downstream processor that caches the map needs to know it has changed, so it can re-fetch and start evaluating the new topology. Pushing that notification through the transaction plane would entangle control traffic with payment traffic, and polling the database wastes resources and adds lag.

The service channel is a dedicated third plane for exactly this kind of message: low-volume, deployment-wide, advisory operational events. Its defining characteristics are:

- **Broadcast, not load-balanced.** Every instance of every interested service receives every message.
- **Advisory, not transactional.** A missed signal degrades gracefully (the receiver re-fetches at the next opportunity); it never corrupts state. The database remains the single source of truth.
- **Decoupled.** A producer does not know or care which services are listening, and consumers do not know which service produced a signal.

> **NOTE:** The service channel carries *identifiers and verbs*, never payloads. A `network-map.activated` event says "a map for tenant X at version Y is now active" - it does not carry the map. Consumers re-fetch the authoritative copy from the data plane. This keeps messages tiny and avoids two copies of the truth.

<div style="text-align: right"><a href="#top">Top</a></div>

## 2. The Three Layers

The service channel is delivered as three cooperating layers, each owned by a different repository. Understanding which layer owns what is the key to extending the channel correctly.

| Layer | Repository | Responsibility |
|---|---|---|
| **Contract** | [`frms-coe-lib`](https://github.com/tazama-lf/frms-coe-lib) | Defines the wire format: the CloudEvents envelope, the `type` verb vocabulary, the `data` payload shapes, and the audience-addressing rule. Pure types and thin helpers - no transport. |
| **Transport** | [`frms-coe-startup-lib`](https://github.com/tazama-lf/frms-coe-startup-lib) | Owns the NATS connection and the publish/subscribe primitives. Knows nothing about CloudEvents - it moves opaque bytes on subjects. |
| **Participant** | each service (for example [`admin-service`](https://github.com/tazama-lf/admin-service)) | Uses the contract to build/read events and the transport to send/receive them, and implements the service-specific logic (what to publish, how to react). |

This separation is deliberate. The **contract** layer is the only place the semantics of an event live, so every participant constructs and validates events identically. The **transport** layer is the only place that touches NATS, so the wire mechanism can change without rippling into every service. The **participant** layer is where you add new behavior.

```text
+-----------------------------------------------------------+
|  Participant (admin-service, event-director, ...)         |
|   - publishNetworkMapActivated(), dispatchCascade()       |
|   - subscribe handlers, audience gating, re-fetch, ack    |
+----------------------------+------------------------------+
                             |  uses
+----------------------------v------------------------------+
|  Contract (frms-coe-lib)                                  |
|   - construct<T>(), validateEnvelope<T>(), deserialize<T> |
|   - ServiceChannelType, NetworkMapActivatedData           |
|   - inAudience(), SERVICE_CHANNEL_AUDIENCE                 |
+----------------------------+------------------------------+
                             |  carried by
+----------------------------v------------------------------+
|  Transport (frms-coe-startup-lib)                         |
|   - initServiceChannelProducer(), publishServiceChannel() |
|   - initServiceChannel() subscribe, consume loop          |
|   - core NATS, no JetStream, no queue group               |
+-----------------------------------------------------------+
```

<div style="text-align: right"><a href="#top">Top</a></div>

## 3. Core Concepts

### 3.1 The CloudEvents Envelope

Every service-channel message is a [CloudEvents](https://cloudevents.io/) envelope serialized as JSON. CloudEvents is an open specification (a Cloud Native Computing Foundation project) for describing event data in a common way, which gives Tazama a standard, tool-friendly format instead of a bespoke one.

The contract layer wraps the official `cloudevents` SDK so every participant builds an envelope identically:

```ts
// frms-coe-lib/src/helpers/serviceChannel.ts
export const construct = <T>(props: ServiceChannelEventProps<T>): CloudEvent<T> =>
  new CloudEvent<T>({ datacontenttype: 'application/json', ...props });

export const validateEnvelope = <T>(event: CloudEvent<T>): boolean => event.validate();

export const deserialize = <T>(bytes: Uint8Array): CloudEvent<T> =>
  new CloudEvent<T>(JSON.parse(new TextDecoder().decode(bytes)) as Record<string, unknown>);
```

The envelope attributes Tazama uses are:

| Attribute | Example | Meaning |
|---|---|---|
| `type` | `org.tazama.network-map.activated` | The verb. Reverse-DNS, past-tense, constant across all deployments. The `org.tazama` prefix names the project that *defines* the semantics. |
| `source` | `admin-service` | Who emitted the event. The deployer's own URI prefix (if any) plus the function name. |
| `subject` | `DEFAULT/2.0.0` | The thing the event is about, as `tenantId/cfg`. |
| `data` | `{ "cfg": "2.0.0", "tenantId": "DEFAULT" }` | Identifier-only payload. Consumers re-fetch the full resource. |
| `id` | a generated UUID | Unique per event. Acks carry this back as their `correlationId`. |
| `time` | ISO 8601 timestamp | When the event was constructed. |
| `datacontenttype` | `application/json` | Structured-mode profile. |
| `audience` | `event-adjudicator` (optional) | A CloudEvents *extension* attribute used for addressing (see [3.4](#34-audience-addressing)). Absent means broadcast. |

The `type` verb vocabulary is a closed enum in the contract:

```ts
export const ServiceChannelType = {
  NETWORK_MAP_ACTIVATED: 'org.tazama.network-map.activated',
} as const;
```

And the `data` payload for that verb is identifier-only by design:

```ts
// frms-coe-lib/src/interfaces/service-channel/NetworkMapActivatedData.ts
export interface NetworkMapActivatedData {
  cfg: string;
  tenantId: string;
}
```

> **IMPORTANT:** The generic `T` on `construct<T>()` and `deserialize<T>()` is a *compile-time* aid only. The SDK validates the envelope (the standard CloudEvents attributes), but it never runtime-checks that `data` matches `T`. Treat `data` defensively when you read it off the wire.

### 3.2 Subjects and Local Perspective

NATS organizes messages by **subject** (a string topic). The service channel uses two configurable subjects, named from the **local perspective of each service**:

- `SERVICE_CHANNEL_PRODUCER` - the subject *this* service publishes to.
- `SERVICE_CHANNEL_CONSUMER` - the subject *this* service subscribes to.

> **WARNING:** "Producer" and "consumer" are always from the point of view of the service reading the variable, exactly like the transaction-plane precedent. A downstream processor that *consumes* activation events sets `SERVICE_CHANNEL_CONSUMER` to the subject the admin-service *produces* on. Do not read these names globally - read them locally.

In a typical deployment the admin-service publishes activation events on one subject, downstream processors subscribe to it, and acks flow back on a separate reply subject (default `service-channel-ack`).

### 3.3 Broadcast Fan-Out and Core NATS Semantics

The transport layer subscribes with **no queue group**:

```ts
// frms-coe-startup-lib/src/services/natsService.ts (abridged)
const subscription = this.NatsConn.subscribe(target); // no { queue } - broadcast fan-out
void this.consumeServiceChannel(subscription, onMessage);
```

This is the opposite of the transaction plane, which uses queue groups to load-balance one message across a pool. On the service channel, **every instance of every subscriber receives every message**, which is what an operational broadcast needs: if you run three typology-processor replicas, all three must reload the map.

Two further properties follow from using **core NATS** (not JetStream):

- **Fire-and-forget.** There is no persistence, no replay, and no delivery guarantee. If a subscriber is down when a message is sent, it misses it. This is acceptable because the channel is advisory and the database is authoritative - a missed reload is corrected at the next signal or restart.
- **No `PubAck` / no-responders.** A publisher cannot tell from the transport whether anyone was listening. The transport degrades rather than throws: if there is no live connection, a publish becomes a logged no-op.

```ts
// frms-coe-startup-lib - publish degrades, never lies
if (!this.NatsConn) {
  this.logger?.warn(`Service-channel publish skipped (no live connection): ${body.length} bytes dropped ...`);
  return;
}
this.NatsConn.publish(target, body);
```

The connection itself is also non-fatal: a service-channel connect failure is logged and the host service keeps running its transaction-plane work.

### 3.4 Audience Addressing

Because every subscriber receives every message, the contract provides a way for a producer to *address* an event to a subset of listeners without changing the subject: the optional `audience` extension attribute, evaluated by a single shared gate.

```ts
// frms-coe-lib - the one drift-proof audience gate
export const inAudience = (audience: string | undefined, identity: ServiceChannelIdentity): boolean => {
  if (audience === undefined || audience === SERVICE_CHANNEL_AUDIENCE.ALL) {
    return true;
  }
  return audience === identity.class || audience === identity.functionName;
};
```

A consumer acts on an event if and only if the event is unaddressed (`audience` absent or `all`), addressed to the consumer's **class** (for example `event-adjudicator`), or addressed to the consumer's specific **function name**. The contract owns the closed class vocabulary; each consumer supplies its own identity:

```ts
export const SERVICE_CHANNEL_AUDIENCE = {
  EVENT_DIRECTOR: 'event-director',
  TYPOLOGY_PROCESSOR: 'typology-processor',
  RULE_PROCESSOR: 'rule-processor',
  EVENT_ADJUDICATOR: 'event-adjudicator',
  ALL: 'all',
} as const;
```

Audience addressing is what makes the ordered cascade (see [5.2](#52-cascade)) possible: the same producer subject carries every event, and `audience` decides which tier acts on each one.

### 3.5 Acknowledgements

Some control-plane flows need to know that a consumer actually adopted a change, not merely that a message was sent. The service channel supports an **acknowledgement** convention: a consumer that finishes acting on an event publishes a small ack event back on the reply subject (`SERVICE_CHANNEL_CONSUMER` from the *producer's* perspective, default `service-channel-ack`).

An ack reuses the triggering event's `id` as its `correlationId` and reports an `outcome`:

```ts
interface ServiceChannelAckData {
  correlationId?: string;        // the activation event's id
  outcome?: 'success' | 'error';
  error?: string;
}
```

The admin-service runs a standing **fire-and-log ack sink** that logs one advisory line per ack. A `success` ack logs at info; an `error` ack escalates to `error` so a failed downstream fulfillment is surfaced. The sink is advisory: it never blocks an activation, performs no tally, and swallows a malformed ack at `warn` so one bad message cannot tear down the subscription.

```ts
// admin-service/src/services/serviceChannel.ts (abridged)
export const handleServiceChannelAck = async (data: Uint8Array): Promise<void> => {
  try {
    const ack = deserialize<ServiceChannelAckData>(data);
    const { correlationId, outcome, error } = ack.data ?? {};
    if (outcome === 'error') {
      loggerService.error(/* ... */);
    } else {
      loggerService.log(/* ... */);
      if (typeof correlationId === 'string') {
        recordCascadeAck(correlationId, ack.source); // feeds a waiting cascade, if any
      }
    }
  } catch (err) {
    loggerService.warn(`Discarding malformed service-channel ack: ${util.inspect(err)}`);
  }
};
```

Acks are advisory for a plain broadcast, but they become *load-bearing* for a cascade, where each tier's quorum of acks gates the next tier.

<div style="text-align: right"><a href="#top">Top</a></div>

## 4. Worked Example: Network Map Reload

The rest of this guide uses the network map reload feature as a concrete illustration of every concept above.

### 4.1 The Problem

A network map describes the topology of rules and typologies a tenant evaluates. Downstream processors cache the active map in memory for speed. When an operator promotes a new map through the admin-service, those caches are stale until each processor re-fetches. The service channel carries the `network-map.activated` signal that tells them to.

There are two ways this signal is emitted:

1. **As a side effect of activation** - the existing `activate` endpoint optionally signals after it commits.
2. **On demand, from the dedicated reload endpoint** - re-signal the *currently active* map without changing any state.

### 4.2 The Activation Side-Channel Signal

When you `POST /v1/admin/configuration/network_map/{cfg}/activate`, the admin-service performs the atomic active-map swap in the database and then, depending on the request's `reloadMode`, dispatches a `network-map.activated` event. Here, signaling is a **side effect**: the database commit is the real outcome, so a failed dispatch degrades to an advisory `reloadDispatched: { status: false }` field on an otherwise-successful `200`. The activation still happened.

### 4.3 The Dedicated Reload Endpoint

Sometimes you need to re-drive a reload *without* a new activation - a processor started late and missed the original broadcast, or you want to run a fresh cascade. That is what the dedicated reload endpoint is for:

```http
POST /v1/admin/configuration/network_map/reload HTTP/1.1
```

It writes nothing. It looks up the tenant's single active map, derives the `cfg` and `tenantId` from *that map* (never from the request), and re-dispatches the signal. Its handler is the clearest end-to-end illustration of the producer side of the channel:

```ts
// admin-service/src/utils/service-channel-routes.ts (abridged)
async (req, reply) => {
  const { tenantId } = req as ITenantRequest;

  // 1. Validate reloadMode - required here, must be broadcast or cascade.
  const { reloadMode } = (req.body ?? {}) as Record<string, unknown>;
  if (reloadMode === 'none') {
    return await reply.code(400).send({ message: NONE_NOT_APPLICABLE });
  }
  if (reloadMode !== 'broadcast' && reloadMode !== 'cascade') {
    return await reply.code(400).send({ message: VALID_MODES });
  }

  // 2. Fetch the tenant's single active map (highlander). No map => nothing to reload => 404.
  const active = await getActiveFn(tenantId);
  if (!active) return await reply.code(404).send({ message: 'No active network map' });

  // 3. cfg/tenant come from the fetched map - the source of truth for what is active.
  const map = active as unknown as NetworkMap;
  const resolvedTenant = typeof map.tenantId === 'string' ? map.tenantId : tenantId;

  // 4. Dispatch via the contract + transport.
  const dispatched =
    reloadMode === 'cascade'
      ? dispatchCascade(map, map.cfg, resolvedTenant)
      : await publishNetworkMapActivated(map.cfg, resolvedTenant);

  // 5. Publishing IS the whole operation, so a failed dispatch is a loud 503.
  if (!dispatched.status) {
    loggerService.warn(`Network-map reload dispatch failed: ${dispatched.outcome}`);
    return await reply.code(503).send({ error: dispatched.outcome, event: RELOAD_EVENT, dispatched: false });
  }

  return { event: RELOAD_EVENT, dispatched: true, outcome: dispatched.outcome };
}
```

The endpoint is served by a **dedicated plugin**, `buildServiceChannelPlugin`, kept separate from the CRUD plugin precisely because it performs no persistence - it is a control-plane action, not a data-plane one. The plugin is only registered for a repository that exposes the single-active read `getActive`:

```ts
// admin-service/src/router.ts
buildServiceChannelPlugin({ prefix: '/v1/admin/configuration/network_map', repo: NetworkMapRepo });
```

The required privilege is derived from the prefix, so it stays in lockstep with the route: `POST_V1_ADMIN_CONFIGURATION_NETWORK_MAP_RELOAD`.

### 4.4 The Loud 503 Design

This is the most important design decision in the worked example, and it follows directly from [3.3](#33-broadcast-fan-out-and-core-nats-semantics).

On the `activate` endpoint, dispatch is a side effect, so it degrades quietly. On the **reload** endpoint, **dispatch is the entire operation** - there is no database write to fall back on. So when the service channel is unavailable, the endpoint fails **loudly** with a retryable `503` rather than returning a misleading `2xx`:

| Endpoint | Channel down behavior | Rationale |
|---|---|---|
| `activate` | `200` with `reloadDispatched: { status: false }` | The activation (the real work) succeeded; the signal is advisory. |
| `reload` | `503` with `{ error, event, dispatched: false }` | The signal *was* the work; a silent success would be a lie. |

> **IMPORTANT:** Match the failure loudness to where the source of truth is. If your endpoint's only effect is to publish, a publish failure must be loud and retryable. If publishing is a side effect of a committed state change, it should degrade quietly so it never masks the change that did happen.

<div style="text-align: right"><a href="#top">Top</a></div>

## 5. Reload Modes in Depth

The `reloadMode` request field selects how the signal fans out. The reload endpoint accepts `broadcast` and `cascade`; the `activate` endpoint additionally accepts `none`.

### 5.1 Broadcast

`broadcast` publishes a single, unaddressed `network-map.activated` event. Every subscriber receives it, gates it through `inAudience` (which passes, because there is no audience), re-fetches the active map, and adopts it. This is the simple, fast path: one publish, no coordination, no waiting.

```ts
// admin-service/src/services/serviceChannel.ts (abridged)
export const publishNetworkMapActivated = async (cfg: string, tenantId: string): Promise<ReloadDispatchStatus> => {
  if (!isServiceChannelConnected()) {
    return { status: false, outcome: 'service channel unavailable' };
  }
  const event = construct<NetworkMapActivatedData>({
    type: ServiceChannelType.NETWORK_MAP_ACTIVATED,
    source: `${configuration.SERVICE_CHANNEL_SOURCE_URI_PREFIX ?? ''}${configuration.functionName}`,
    subject: `${tenantId}/${cfg}`,
    data: { cfg, tenantId },
    datacontenttype: 'application/json',
  });
  validateEnvelope<NetworkMapActivatedData>(event);
  const eventBytes = new TextEncoder().encode(JSON.stringify(event));
  await serviceChannelProducer.publishServiceChannel(eventBytes, configuration.SERVICE_CHANNEL_PRODUCER ?? 'service-channel');
  return { status: true, outcome: 'published' };
};
```

A successful broadcast reports `outcome: 'published'`.

### 5.2 Cascade

`cascade` runs an **ordered, audience-addressed, ack-gated** reload wavefront instead of a single fan-out. It exists for deployments where the *order* of adoption matters: a downstream tier should adopt the new map only after the tier below it is already subscribed and ready, so no in-flight transaction is evaluated against a half-reloaded topology.

The wavefront addresses tiers **most-downstream first**:

```ts
// admin-service/src/services/cascade.ts
export const CASCADE_TIER_ORDER = ['event-adjudicator', 'typology-processor', 'event-director'] as const;
export const CASCADE_TIER_TIMEOUT_MS = 30_000;
```

For each tier, the orchestrator publishes one `network-map.activated` event stamped with that tier's `audience`, then waits for the tier to reach **quorum** before addressing the next tier:

- **First-ack tiers** (event-adjudicator, event-director): a single ack settles the tier - one live route proves the tier is subscribed.
- **The typology-processor tier**: quorum requires one ack from *every distinct typology* in the activated map, de-duplicated on `typology.id` alone. A map with no typologies skips this tier.

```ts
// admin-service/src/services/cascade.ts (abridged)
export const runCascade = async (activated: NetworkMap, cfg: string, tenantId: string): Promise<CascadeResult> => {
  for (const tier of CASCADE_TIER_ORDER) {
    const required = tier === 'typology-processor' ? distinctTypologyIds(activated) : [];
    if (tier === 'typology-processor' && required.length === 0) continue; // nothing to gate on

    const correlationId = await publishTier(cfg, tenantId, tier);
    if (correlationId === undefined) {
      loggerService.error(`Cascade stalled at tier ${tier}: unable to publish ...`);
      return { converged: false, stalledTier: tier };
    }
    const reached = await waitForTierQuorum(correlationId, required);
    if (!reached) {
      loggerService.error(`Cascade stalled at tier ${tier}: quorum not reached within ${CASCADE_TIER_TIMEOUT_MS}ms`);
      return { converged: false, stalledTier: tier };
    }
  }
  return { converged: true };
};
```

Two properties make the cascade safe to run from a request handler:

- **Fire-and-return.** `dispatchCascade` starts the orchestrator detached and returns immediately with `outcome: 'cascade initiated'`, so the endpoint's response latency is identical to broadcast. The wavefront then runs in the background.
- **It never throws into the request.** A tier that does not reach quorum within `CASCADE_TIER_TIMEOUT_MS` is logged at `error` as a stall and the cascade aborts. The orchestrator resolves rather than rejects, so a stall can never crash the activation path.

```ts
export const dispatchCascade = (activated: NetworkMap, cfg: string, tenantId: string): ReloadDispatchStatus => {
  if (!isServiceChannelConnected()) {
    return { status: false, outcome: 'service channel unavailable' };
  }
  void runCascade(activated, cfg, tenantId).catch((err) => {
    loggerService.error(`Cascade orchestrator crashed: ${util.inspect(err)}`);
  });
  return { status: true, outcome: 'cascade initiated' };
};
```

Acks reach the waiting orchestrator through the ack sink described in [3.5](#35-acknowledgements): on each *successful* ack, `recordCascadeAck(correlationId, source)` advances the tier waiting on that `correlationId`. An `error` ack still logs at `error` but does not count toward quorum - delivery is not adoption.

> **NOTE:** Cascade ack-correlation assumes the deploy convention `typology.id == FUNCTION_NAME`: a typology-processor's ack `source` is its function name, and the typology-processor quorum is computed from the distinct `typology.id` values in the map. The two must match for an ack to count.

### 5.3 None

`none` suppresses the side-channel signal entirely. It is legitimate on `activate` (commit the activation without notifying anyone, for example during a controlled rollout). It is **rejected with a `400`** on the dedicated reload endpoint, because a reload whose whole job is to dispatch would dispatch *nothing* - accepting it as a silent success would be a footgun for an operator who fat-fingered the value. The endpoint returns a tailored message that distinguishes `none` (a near-miss) from outright garbage:

```ts
const NONE_NOT_APPLICABLE =
  "reloadMode 'none' does not apply to the reload endpoint - it would dispatch nothing; use 'broadcast' or 'cascade'";
```

<div style="text-align: right"><a href="#top">Top</a></div>

## 6. Producing an Event

To publish a service-channel event from any service, you combine the contract and the transport. The full recipe, distilled from `publishNetworkMapActivated`:

1. **Confirm the channel is live.** Use the connection guard (`isServiceChannelConnected()`); if it is down, return a degraded status rather than throwing.
2. **`construct<T>()` the envelope** with the contract's `type`, your `source`, a `subject` of `tenantId/cfg`, and an identifier-only `data`.
3. **`validateEnvelope<T>()`** to re-check the envelope.
4. **Serialize and publish** via the transport's `publishServiceChannel(bytes, subject)`.
5. **Return a status** so the caller can decide how loud a failure should be.

```ts
const event = construct<MyData>({
  type: ServiceChannelType.MY_VERB,
  source: `${prefix}${functionName}`,
  subject: `${tenantId}/${cfg}`,
  data: { /* identifiers only */ },
  datacontenttype: 'application/json',
  // audience: 'typology-processor', // optional - omit for broadcast
});
validateEnvelope(event);
await producer.publishServiceChannel(new TextEncoder().encode(JSON.stringify(event)), SERVICE_CHANNEL_PRODUCER);
```

<div style="text-align: right"><a href="#top">Top</a></div>

## 7. Consuming an Event

A downstream service subscribes once at startup and handles each message. The lifecycle mirrors the producer in reverse:

1. **Subscribe** to your `SERVICE_CHANNEL_CONSUMER` subject via the transport's `initServiceChannel(onMessage, subject)`. The subscription has no queue group, so this instance receives every message.
2. **`deserialize<T>()`** the raw bytes back into a CloudEvent.
3. **Gate on audience** with `inAudience(event.audience, identity)`. If it returns `false`, ignore the event - it was addressed to another tier.
4. **React** - for `network-map.activated`, re-fetch the active map from the data plane and swap your cache.
5. **Acknowledge** (if the flow requires it) by publishing an ack on the reply subject, carrying the triggering event's `id` as `correlationId` and an `outcome`.

```ts
const identity = { class: SERVICE_CHANNEL_AUDIENCE.TYPOLOGY_PROCESSOR, functionName: configuration.functionName };

await transport.initServiceChannel(async (bytes) => {
  const event = deserialize<NetworkMapActivatedData>(bytes);
  if (!inAudience(event.audience as string | undefined, identity)) return; // not for us

  const { cfg, tenantId } = event.data ?? {};
  await reloadActiveMap(tenantId, cfg); // re-fetch from the source of truth

  // ack back so a cascade orchestrator can advance
  const ack = construct({
    type: event.type,
    source: configuration.functionName,
    data: { correlationId: event.id, outcome: 'success' },
  });
  await transport.publishServiceChannel(new TextEncoder().encode(JSON.stringify(ack)), SERVICE_CHANNEL_PRODUCER);
}, configuration.SERVICE_CHANNEL_CONSUMER);
```

> **TIP:** Always wrap your handler body so it cannot reject out of the consume loop. The transport already guards the loop, but a defensive handler keeps your own diagnostics clean and prevents one malformed event from masking later ones.

<div style="text-align: right"><a href="#top">Top</a></div>

## 8. Extending the Service Channel

There are four common ways to extend the channel. Each maps onto one of the three layers, so the first question to ask is always "which layer owns this change?"

### 8.1 Add a New Consumer

This is the most common extension and touches **only the participant layer** - no contract or transport change is needed.

1. Add the service-channel environment variables to your service (`SERVICE_CHANNEL_CONSUMER`, and `SERVICE_CHANNEL_PRODUCER` if you ack).
2. On startup, initialize the consumer connection and call `initServiceChannel(onMessage, SERVICE_CHANNEL_CONSUMER)`.
3. Implement `onMessage` following [Section 7](#7-consuming-an-event): deserialize, gate on `inAudience` with your identity, react, and ack if needed.
4. Make your reaction **idempotent**. Because the channel is fire-and-forget broadcast, you may receive a signal you have already applied; re-fetching and re-adopting the same active map must be harmless.

> **TIP:** A new consumer that only needs broadcasts can ignore `audience` entirely (the gate passes for unaddressed events). You only need an identity if you want to participate in addressed flows such as a cascade.

### 8.2 Add a New Event Type

A genuinely new operational verb (for example a future `network-map.deactivated` kill switch) is a **contract-layer** change in `frms-coe-lib`, because the semantics must be shared identically by every participant.

1. Add the verb to the `ServiceChannelType` enum (reverse-DNS, past-tense, `org.tazama` prefix).
2. Add its `kind` mapping (`event` or `command`).
3. Define an identifier-only `data` interface for it under `interfaces/service-channel`.
4. Export the new type from the library index.
5. Release a new `frms-coe-lib` version, then bump producers and consumers to it.

> **WARNING:** Adding a verb is additive and deployment-wide. Coordinate the rollout: publish only after every intended consumer understands the new type, or gate the producer behind configuration until consumers are upgraded.

### 8.3 Add a New Producer Endpoint

To expose a new control-plane action that publishes (the reload endpoint is the template), you add a **participant-layer** endpoint. The reusable `buildServiceChannelPlugin` pattern shows the shape: a dedicated, no-persistence plugin that validates input, reads the source of truth, dispatches through the contract and transport, and matches failure loudness to where the truth lives (see [4.4](#44-the-loud-503-design)).

Reuse the decisions the reload endpoint already made: derive the privilege from the route prefix, keep the publish-only plugin separate from any CRUD plugin, and return a loud `503` when a publish-only action cannot reach the broker.

### 8.4 Add a Tier to the Cascade

To insert a service into the ordered reload wavefront, extend the **orchestrator in the producing service** (admin-service):

1. Add the tier to `CASCADE_TIER_ORDER` in the correct topological position (most-downstream first).
2. Decide the tier's quorum rule: a first-ack tier (any single ack) for a singleton, or a map-derived set (like the typology-processor's distinct-id rule) for a fan-out tier.
3. On the consumer side, ensure the new tier gates on its `audience` class token and acks with a `source` that matches what the quorum rule expects.

> **NOTE:** Keep the orchestrator fire-and-return and stall-tolerant. A new tier must not be able to throw back into the request path or hold the process open - follow the existing `unref`'d timeout and detached-promise pattern.

<div style="text-align: right"><a href="#top">Top</a></div>

## 9. Configuration Reference

These environment variables configure the service channel for a participant. Names are read from the **local perspective** of the service (see [3.2](#32-subjects-and-local-perspective)).

| Variable | Used by | Meaning |
|---|---|---|
| `SERVICE_CHANNEL_PRODUCER` | producers and ackers | Subject this service publishes to. Defaults to `service-channel` when omitted. |
| `SERVICE_CHANNEL_CONSUMER` | consumers | Subject this service subscribes to. The ack sink subscribes here too (default ack subject `service-channel-ack`). |
| `SERVICE_CHANNEL_SOURCE_URI_PREFIX` | producers | Optional deployer URI prefix prepended to `functionName` to form the CloudEvents `source`. |
| `FUNCTION_NAME` | all | The service's own identity, used as `source` and as the consumer's `functionName` for `inAudience`. |
| `AUTHENTICATED` | admin-service | When `true`, the reload endpoint enforces the derived privilege via the token handler. |

> **NOTE:** A service-channel connection failure is non-fatal by design. A participant that cannot reach the channel still runs its primary work; it simply logs the degraded state and (for producers) reports a failed dispatch.

<div style="text-align: right"><a href="#top">Top</a></div>

## 10. Testing

The service channel is built to be unit-testable without a live broker. Test at the seams:

- **Producer logic** - mock the transport's `publishServiceChannel` and the connection guard. Assert the constructed CloudEvents envelope (the `type`, `source`, `subject`, identifier-only `data`, and `audience`), and assert the degraded path returns the unavailable status when the guard reports no connection.
- **Endpoint behavior** - exercise the contract boundaries: the validation responses (the reload endpoint's `400` for missing, `none`, and unknown modes), the `404` when there is no active map, the `200` success shape, and the loud `503` when the channel is down for both modes.
- **Cascade** - drive `recordCascadeAck` directly to simulate acks and assert tier ordering, quorum settling, the zero-typology skip, and the stall-on-timeout path.
- **Consumer logic** - feed crafted bytes to your handler and assert the `inAudience` gate ignores out-of-audience events, the re-fetch fires for in-audience events, and a malformed event is swallowed.

The network map reload feature ships with unit tests that cover exactly these seams and are a useful reference when you add your own.

<div style="text-align: right"><a href="#top">Top</a></div>

## 11. Design Principles

The patterns in this guide come from a small set of principles. Keep them in mind when you extend the channel:

- **The database is the source of truth; the channel is advisory.** Events carry identifiers, not payloads. Consumers re-fetch. A missed event is recoverable.
- **Match failure loudness to the source of truth.** A publish that *is* the operation fails loudly (`503`); a publish that is a side effect of a committed change degrades quietly.
- **Decouple producers from consumers.** Producers do not enumerate listeners; addressing is by `audience`, evaluated by a single shared gate so the rule cannot drift.
- **Degrade, never crash.** A down channel is non-fatal. Detached work (the cascade) resolves rather than throws and never holds the process open.
- **Keep semantics in one layer.** The verb vocabulary and payload shapes live only in the contract, so every participant speaks identically.
- **Make reactions idempotent.** Broadcast fan-out means you will sometimes get a signal you have already applied.

<div style="text-align: right"><a href="#top">Top</a></div>

## 12. Further Reading

- [CloudEvents specification](https://cloudevents.io/) - the open standard the envelope follows.
- [NATS core concepts](https://docs.nats.io/nats-concepts/overview) - the messaging system the transport uses.
- [`frms-coe-lib`](https://github.com/tazama-lf/frms-coe-lib) - the contract layer source.
- [`frms-coe-startup-lib`](https://github.com/tazama-lf/frms-coe-startup-lib) - the transport layer source.
- [`admin-service` README](https://github.com/tazama-lf/admin-service/blob/main/README.md) - the producing service, including the activate and reload endpoints.
- [Tazama Documentation Style Guide](https://github.com/tazama-lf/docs/blob/main/Guides/docs-style-guide.md) - conventions this guide follows.

Need assistance? [Open a Discussion](https://github.com/tazama-lf/tazama-project/discussions) or [raise an Issue](https://github.com/tazama-lf/tazama-project/issues).

<div style="text-align: right"><a href="#top">Top</a></div>
