<!-- SPDX-License-Identifier: Apache-2.0 -->

<a id="top"></a>

# Contributor recommended skills and knowledge <!-- omit from toc -->

## Table of Contents <!-- omit from toc -->

- [Introduction](#introduction)
- [Development and developer tools](#development-and-developer-tools)
- [Third party Open Source Software components](#third-party-open-source-software-components)
- [DevOps](#devops)
- [Documentation](#documentation)
- [Further reading](#further-reading)

## Introduction

Experience in the following technologies are recommended to make contributing to Tazama a little easier.

## Development and developer tools

 - [GitHub](https://github.com/): Our code is hosted in our own GitHub repository and understanding the basics of GitHub and git processes will help you access, update and submit code to the Project. We also use GitHub issues to document and track user stories.
 - [GitHub Actions](https://github.com/features/actions) to automate some Continuous Integration (CI) processes in support of developer tasks
 - [Typescript](https://www.typescriptlang.org/): Our code is mostly written in TypeScript, a strictly typed implementation of JavaScript, which transpiles into JavaScript code for execution via [Node.js](https://nodejs.org/en).
 - [Jest.js](https://jestjs.io/): Unit tests for our TypeScript code is written in Jest as part of the development process. We aim for test-driven development and complete test coverage.
 - [Postman](https://www.postman.com/): Integration, end-to-end and some unit testing is currently performed via Postman which uses extensive [JavaScript](https://www.javascript.com/) scripts to automate the tests.
 - [Docker](https://www.docker.com/): Our software runs in Docker containers and containerization of the product and its components is an integral part of the development, testing and deployment processes.
 - [Prettier](https://prettier.io/) and [ESLint](https://eslint.org/): Promote and enforce consistent coding practices for the delivery of quality code.
 - [Visual Studio Code](https://code.visualstudio.com/): Though there are many tools available, most of us use VS Code to write our code.

<div style="text-align: right"><a href="#top">Top</a></div>

## Third party Open Source Software components 

The Product is composed out of a wide variety of other Open Source Software components, ranging from industry veterans to young-and-upcoming contenders. Experience in any of the components we use would be very helpful in standing a bit more firmly on the shoulders of giants:

 - [ArangoDB](https://www.arangodb.com) for multi-modal key-value and graph data storage
 - [Elastic](https://www.elastic.co/elastic-stack) (specifically Elastic, Logstash and Kibana (ELK)) for system logging, observability and reporting
 - [Jupyter Notebooks](https://jupyter.org/) to support data analytics, business intelligence and data science tasks
 - [NATS](https://nats.io/) for pub/sub inter-services communication
 - [OpenAPI](https://www.openapis.org/) - a.k.a. Swagger - to describe our HTTP APIs
 - [Protocol Buffers](https://protobuf.dev/) for inter-services data serialization
 - [Redis](https://redis.io/) for high-speed in-memory data caching

<div style="text-align: right"><a href="#top">Top</a></div>

## DevOps 

From a DevOps perspective, we make use of the following tools:

 - [Helm](https://helm.sh/) to define the build and deployment of our system
 - [Jenkins](https://www.jenkins.io/) to automate our build, test and deployment processes
 - [Kubernetes](https://kubernetes.io/) for the automated deployment of containers and to scale and manage our containerized system components
 - [Newman](https://learning.postman.com/docs/collections/using-newman-cli/command-line-integration-with-newman/) to automatically execute Postman tests as part of the automated build, test and deployment process
 - [YAML](https://yaml.org/) to provide scripting to guide automated deployment processes
<div style="text-align: right"><a href="#top">Top</a></div>

## Documentation

 - [Markdown](https://www.markdownguide.org/) for documentation hosted in GitHub
 - [Mermaid.js](http://mermaid.js.org/#/) for markdown-embedded diagrams in GitHub
 - [Drawio](https://www.drawio.com/) for embedded diagrams in GitHub. See [guide for draw.io](https://github.com/tazama-lf/docs/blob/main/Guides/drawio-guide.md).

<div style="text-align: right"><a href="#top">Top</a></div>

## Further reading

- Read the [CONTRIBUTING guide](https://github.com/tazama-lf/.github/blob/main/CONTRIBUTING.md) for more details on the contribution process.