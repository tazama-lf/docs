# Distributed Tracing Implementation

- [Distributed Tracing Implementation](#distributed-tracing-implementation)
  - [Installation](#installation)
  - [ELK Distributed tracing with NATS](#elk-distributed-tracing-with-nats)
  - [Misc](#misc)

We use the ELK stack for monitoring and observing our distributed systems. This article will cover the NodeJS agent.

## Installation

The elastic agent supports automatic instrumentation of supported technologies. These are listed in their [documentation](https://www.elastic.co/guide/en/apm/agent/nodejs/current/supported-technologies.html). The gist is that we do not have to create spans for technologies like Redis, HTTP transactions, SQL calls and such; we get those for free in Kibana.

To get this to work properly, we need to initialise the `elastic-apm-agent` as the first step in our application; everything else should come after it.

We need to get elastic up before any other modules we are using in our application for automatic instrumentation to take place.

On the subject of supported technologies, we are covered for most of the technologies we use, except for the main one, [NATS](http://nats.io); which we are using to transmit messages across the platform. NATS, is unfortunately not included in the list of supported technologies (as of version `3.49.1`). Here is an [issue](https://github.com/elastic/apm-agent-nodejs/issues/1686) which will hopefully be closed when there is an implementation (or if they decide they will not implement it).  
  
To get distributed tracing to work, there is a bit of manual setup needed on our platform.

## ELK Distributed tracing with NATS

In terms of implementation, what was required was to pass a context along each micro-service (“who started me”). We have a `metaData` field attached to our messages. It is generic, so you can store pretty much anything on it as long as it is valid code.

> We considered using our own ids as a parent but there were a couple of drawbacks there. First and foremost, Elastic does not expose a public interface for creating custom contexts (Ids). Elastic follows the [W3C trace-context](https://www.w3.org/TR/trace-context/) which is also utilised by similar tools such as open-telemetry. We didn't want to then reinvent the wheel and potentially have more work to integrate other tools in the future by deviating away from W3C Standard.

Alright, back to the `metaData` field, we use that to transmit our tracing context through the platform in a variable `traceparent`.

```
{
 transaction: {},
 metaData: {
  traceparent: "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
 }
}
```

`traceparent` represents the Trace Context of the parent of the current micro-service. To put it bluntly, it identifies who started this transaction.

The really important bit is that the micro-service that receives this transaction will then start its own `span` or (apm) `transaction` and then replace `metaData.traceparent` to that `span`/`transaction`'s `id` so that the `traceparent` that the next micro-service receives is the `id` of the `span` created by the micro-service that called it.

If that was confusing, here’s some pseudocode of how it all comes together:  

Service A

```
// Service A
const transaction = apm.startTransaction("doing work");
 - Auto span is created here since we're making an http call -/
axios.post("http://my.api.here");

 - sending a string 'foo bar' to service B
 - no auto spans because nats is unsupported :(
 - We have to send traceparent manually
 -
nats.publish('ServiceB', {
  value: "foo bar",
  metaData: {
    traceparent: apm.currentTraceparent // send trace parent manually
  }
});
transaction?.end()
```

Service B  

```
const natsMessage = nats.subscribe("ServiceB");
const span = apm.startSpan("from Service A", childOf: natsMessage.metaData.traceparent)
// Above, we started a span and we specified the Id of the span this is started by.
nats.publish("ServiceC", {
  value: "alice bob",
  metaData: {
    traceparent: apm.currentTraceparent // update the traceparent to be of the current span
  }
})
span?.end()
```

## Misc

Our implementation has a [wrapper class](https://github.com/frmscoe/frms-coe-lib/blob/ae41e132bd3cb6779df2379f71ca9f604286ea16/src/services/apm.ts#L3) around it. After profiling a micro-service, we discovered that `apm` modules were still being loaded even when the configuration has it disabled ([#238](https://github.com/frmscoe/General-Issues/issues/238)). This class returns `null` for `apm` methods if it’s disabled, and will likewise load the modules should the option be enabled. The public API is maintained for the most part, except we use methods for accessors. Namely, upstream `apm.currentTraceparent` is `apm.getCurrentTraceparent()` in the class.
