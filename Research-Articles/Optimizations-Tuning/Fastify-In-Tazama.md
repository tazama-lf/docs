# Fastify in Tazama

Fastify in Tazama

Fastify is used as a rest module within the transaction monitoring system (TMS) as one of the best modules out there at this time, and we aim to always stay with the best technologies when It comes to performance for Tazama. Fastify has fast-json-stringify to Learn about the library and how we integrated to the Tazama system Follow: [Serialisation with fast-json-stringify](Serialisation-With-Fast-Json-Stringify.md)

With Fastify we stand to have unlocked 39086 req/sec which is mostly above other rest modules like koa, express, etc

Benchmarks

|     |     |
| --- | --- |
| Fastify | 39086 req/sec |
| Koa | 30083 req/sec |
| Express | 8308 req/sec |
| Restify | 27014 req/sec |
| Hapi | 25633 req/sec |

Source: [Fastify](https://fastify.dev/benchmarks)

The Startup of Fastify includes adding schema and setting up of swagger. Schemas are used for validation and serialization this makes our data payload have restrictions when outlying the messages that are sent into the system and that are sent out by each processor using libraries like Ajv v8 and fast-json-stringify, Fastify compiles the schema into a highly performant function. The route validation internally relies upon Ajv v8 which is a high-performance JSON Schema validator.
