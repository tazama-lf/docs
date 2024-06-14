<!-- SPDX-License-Identifier: Apache-2.0 -->

# Backend Framework Decission

|     |     |
| --- | --- |
| Status | IN PROGRESS |
| Impact | HIGH |
| Driver | Aarón Reynoza |
| Approver | Dev Team |
| Contributors |     |
| Informed |     |
| Due date | 26/03/2021 |
| Outcome |     |

## Background

As of now, we have developed all of our services as Kafka clients. The architecture is changing, and as we move towards gRPC, we need to specify a back-end framework to use in our APIs layer. This decision will mean an specific architecture for our code in services, meaning development time, application performance and overall interoperability.

## Relevant data

As of now, we have considered 4 options: Express, HapiJs, NextJS and Koa.

# Express

Express is a simplistic framework with a robust set of features.

Here’s what a hello world app looks like:

```typescript
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(\`Example app listening at http://localhost:${port}\`)
})
```

Express uses the minimum required to work, while also allowing us to add middlewares easily, as shown in the following example, where the CORS middleware is added.

```typescript
var express = require('express')
var cors = require('cors')
var app = express()

app.use(cors())
```

Advantages:

- Express is overall becoming the standard web framework to use in Node.js
- It is simple, allows to scale quickly and is flexible in its approach meaning it does not put constraints on the developer compared to frameworks like Hapi
- It allows easy integration of third party libraries and middle-wares
- It is well maintained and has a large community contributing to it, meaning less bugs and frequent updates

Disadvantages:

- Code organization must be carefully done otherwise management can get tricky when scaling an application
- As the codebase becomes bigger, refactoring can become a challenge and we can end up easily with a lot of repetitive, less modular code.

# HapiJS

HapiJS is probably the most opposite of express. it’s built to scale applications and it comes with a lot of features out of the box.

Here’s an example hello world:

```typescript
'use strict';

const Hapi = require('@hapi/hapi');

const init = async () => {

    const server = Hapi.server({
        port: 3000,
        host: 'localhost'
    });

    await server.start();
    console.log('Server running on %s', server.info.uri);
};

process.on('unhandledRejection', (err) => {

    console.log(err);
    process.exit(1);
});

init();
```

###### Side note: you need Node 12+ to run hapi.

The advantage of using Hapi is that it comes bundled with different features like cookies and CORS, at the cost of speed and abstractions. This is the main reason of why Hapi was not considered that much in this comparison, since some of these issues are addresses in the next framework.

# NestJS

Nest is a pretty different framework. It’s a bundle of features, with their own architecture, that allows us to create scalable applications. it uses a base framework, which we can choose (like express).

This framework is developed in Typescript and uses design patterns similar to those of Angular.

An example of this, could be the extensive use of Decorators across the code:

```typescript
import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }
}
```

Where they have a segmented architecture:

```typescript
src
  app.controller.spec.ts
  app.controller.ts
  app.module.ts
  app.service.ts
  main.ts
```

Also, NestJS wants you to develop alongside testing, so it’s a combination of good practices. However, this is just part of the standard we have already decided, so it can be considered a boilerplate for our requirements. However, Nest DOES binds us to a paradigm, and it’s the fact that, by using decorators, we’ll have a good amount of classes across the application:

app.service.ts:

```typescript
import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello World!';
  }
}

```

app.module.ts:

```typescript
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: \[\],
  controllers: \[AppController\],
  providers: \[AppService\],
})
export class AppModule {}

```

Having so many classes doesn’t really allows us to do much functional programming around it, which is not that great since we want to keep [functional modularity as much as we can.](../../architecture-and-design/functional-programming-vs-oop-benchmark.md)

# Koa

Koa is a new web framework designed by the team behind Express, which aims to be a smaller, more expressive, and more robust foundation for web applications and APIs. By leveraging async functions, Koa allows you to ditch callbacks and greatly increase error-handling. Koa does not bundle any middleware within its core, and it provides an elegant suite of methods that make writing servers fast and enjoyable.

Hello world app:

```typescript
var koa = require('koa');
var app = new koa();

app.use(function\* (){
   this.body = 'Hello world!';
});

app.listen(3000, function(){
   console.log('Server running on https://localhost:3000')
});
```

As you can see, the code is pretty similar to that of express. However, the functionality diverges in many things, like error handling.

By default outputs all errors to stderr unless app.silent is true. The default error handler also won't output errors when err.status is 404 or err.expose is true. To perform custom error-handling logic such as centralized logging you can add an "error" event listener:

```typescript
app.on('error', err => {log.error('server error', err)});
```

If an error is in the req/res cycle and it is not possible to respond to the client, the Context instance is also passed:

```typescript
app.on('error', (err, ctx) => {log.error('server error', err, ctx)});
```

When an error occurs and it is still possible to respond to the client, aka no data has been written to the socket, Koa will respond appropriately with a 500 "Internal Server Error". In either case an app-level "error" is emitted for logging purposes.

Koa does not provide any out of the box features or packages upon installing it meaning it doesn’t come with any routing, templating or rendering. These features would need to be installed separately. The framework was developed along with specific libraries and add-ons to remedy to these needs and can easily be implemented.

Thus, It results in a highly customizable environment, providing a better user experience especially for senior developers as it again allows for more control but also better performance due to how lightweight the actual framework is with less than a thousand lines of code.

Advantages:

- Contains numerous helpful methods and functions while still being lightweight as it does not bundle any middleware which allows you to customise it as you please and only include needed features
- Uses the latests JS6 features including generators and async/await which makes it better at handling asynchronous flow and prevents call back hell.
- Overall provides cleaner, more readable async code
- Koa improves robustness, makes writing middleware much more enjoyable and better the overall user experience
- Has better error handling through try and catch

Disadvantages:

- Small open-source community contributing to the framework, meaning more possible bugs and fewer updates as it is harder for the developers team to listen to the community’s feedback.
- Koa uses generators which are not compatible with any other type of Node.js framework middle-wares, which in a rich and versatile environment that is node, is a huge drawback;

# Benchmarking

Note: the data shown below is an average of 5 runs for each technology using [Bombardier](https://pkg.go.dev/github.com/codesenberg/bombardier) to run 100,000 requests with 125 open connections.

|     | Express | Hapi | Nest | Koa |
| --- | --- | --- | --- | --- |
| Reqs/sec<br><br>Average | 8953.13 | 9931.93 | 7820.41 | 32646.17 |
| Reqs/sec<br><br>Stdev | 1182.98 | 837.73 | 1083.71 | 3472.41 |
| Reqs/sec<br><br>Max | 11047.17 | 11622.18 | 10670.29 | 39142.42 |
| Latency Average | 13.95ms | 12.58ms | 15.98ms | 3.83ms |
| Latency Stdev | 1.44ms | 0.89ms | 1.64ms | 539.27us |
| Latency Max | 33.81ms | 25.30ms | 40.41ms | 15.10ms |
| Time to run | 11s | 10s | 13s | 3s  |
| Footprint | 2.57MB/s | 3.07MB/s | 2.24MB/s | 7.40MB/s |

## Conclusion:

Frameworks like Hapi and Nest allows us to develop with the features already included, at the cost of performance, while Express doesn’t give us either of those. However, Koa has shown to be faster while also being able to add modularity and middlewares to the application, making it more configurable from our side as we need to add what we need and only that.

## References

[https://medium.com/@theomalaper.cognez/express-vs-koa-and-hapi-a2c65f949b78](https://medium.com/@theomalaper.cognez/express-vs-koa-and-hapi-a2c65f949b78)  
[https://github.com/koajs/koa/blob/master/docs/koa-vs-express.md](https://github.com/koajs/koa/blob/master/docs/koa-vs-express.md)  
[https://savvycomsoftware.com/express-koa-or-hapi-better-performance-with-the-right-nodejs-framework/](https://savvycomsoftware.com/express-koa-or-hapi-better-performance-with-the-right-nodejs-framework/)  
[https://www.tutorialspoint.com/koajs/koajs\_hello\_world.htm](https://www.tutorialspoint.com/koajs/koajs_hello_world.htm)  
[https://koajs.com/](https://koajs.com/)  
[https://dev.to/tejaskaneriya/when-to-use-these-nodejs-frameworks-express-koa-nest-socket-io-meteor-js-3p63](https://dev.to/tejaskaneriya/when-to-use-these-nodejs-frameworks-express-koa-nest-socket-io-meteor-js-3p63)  
[Functional Programming vs OOP Benchmark](../../architecture-and-design/functional-programming-vs-oop-benchmark.md)

## Outcome

Due to ease of use + performance advantages, we decided to use Koa.
