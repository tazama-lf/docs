# Serialisation with fast-json-stringify

Rodney Kanjala

When serialising `JSON` objects, one would typically go for Node’s `JSON.stringify()` . This gets the job done but when aiming for more speed, it might be useful to consider using [fast-json-stringify.](https://github.com/fastify/fast-json-stringify)  
  
In their `About` section, they state that it’s about twice as fast when compared to `JSON.stringify()`.

## Naive Benchmarks

## Dataset

We have an ISO20022 `Pain013` message, which is one of the largest objects the platform is transmitting, we’ll be using that for a short test.

## Environment

I’ll be running this on a standard consumer computer.

|     |     |
| --- | --- |
| Operating System | Arch Linux (WSL) |
| Host | Windows 10 10.0.19045 Build 19045 |
| Kernel Version | 5.15.90.1 |
| RAM | 8Gb (7789Mb usable) |
| Node | 20.4.0 |
| `fast-json-stringify` | 5.8.0 |
| CPU | 12th Gen Intel i7-1255U (12) @ 2.611GHz |

We initialise our `stringify` function with:  
`const stringify = fastJson(schema)`

Where `schema` is our [JSON Schema Draft 7](https://json-schema.org/specification-links.html#draft-7)

From here, a simple function that uses `fast-json-stringify` to serialise a `Pain013` object

```typescript
const fastJsonImplementation = (pain013) => {
  stringify(pain013)
}
```

Before we run our test, we do `100000` iterations of serialisation initially to try to get JIT in play:

```typescript
for (let i = 0; i < 100000; i++) {
  fastJsonImplementation(pain013);
}
```

When that runs, we start a `console.time` to record the actual serialisation of our object:

```typescript
console.time("fastJson");
fastJsonImplementation(pain013);
console.timeEnd("fastJson");

```

We do the same for `JSON.stringify()`

The results, on my environment:

![](../../images/at.png)

On the left, `JSON.stringify()` took `1.950s` after warm up iterations. On the right we have our `fast-json-stringify` implementation which took `747.91ms` after our warm up iterations.