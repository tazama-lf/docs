<!-- SPDX-License-Identifier: Apache-2.0 -->

# Development Using gRPC (Tutorial, Lesson Learned)

We’ve migrated some of our services to gRPC so far.

- gRPC Template [https://github.com/mojaloop/fraud\_risk\_management/tree/master/Templates/gRPC-Template](https://github.com/mojaloop/fraud_risk_management/tree/master/Templates/gRPC-Template)
- TMS-Service [Transaction Monitoring Service (TMS)](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/1739897)
- CRSP [Channel Routing & Setup Processor (CRSP)](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/1740020)
- Rules  
    Rule-003 ✅  
    Rule-002
- Typologies

In this document, you can understand how we develop, deploy and monitor our gRPC services.

## Why gRPC?

gRPC is a modern open-source high-performance Remote Procedure Call (RPC) framework that can run in any environment. It can efficiently connect services in and across data centres with pluggable support for load balancing, tracing, health checking and authentication. It is also applicable in the last mile of distributed computing to connect devices, mobile applications and browsers to backend services.  

![](../../images/2021-06-25_at_1.45.21-2x.png)

# Development

The easiest way to start developing a new service is to copy [the gRPC Template](https://github.com/mojaloop/fraud_risk_management/tree/master/Templates/gRPC-Template) or [tms-service](https://github.com/mojaloop/fraud_risk_management/tree/master/tms-service) from FRM Repo.

Before start work on the server and client gRPC functions, we need to understand what we need. If one of our client needs a grpc server, we need to create grpc server too.

For example, we don’t need to create TMS server, we only need TMS client because the gRPC service is NiFi.

Let’s clone the FRM repos and go into TMS-Service.

The TMS service is a NodeJs REST-API service that ingests a FRM transaction and validates if it has the correct format.

[https://github.com/mojaloop/fraud\_risk\_management/tree/master/tms-service](https://github.com/mojaloop/fraud_risk_management/tree/master/tms-service)

## Installation

```bash
yarn
```

* * *

If you are using an ARM-based chip like M1, you need to follow different installation methods.  
`error: grpc-tools@1.11.2 install: node-pre-gyp install`

[https://github.com/nvm-sh/nvm#macos-troubleshooting](https://github.com/nvm-sh/nvm#macos-troubleshooting)

You can simply execute that command  
`npm install --target_arch=x64`  
instead of `yarn`

* * *

## Build

```bash
yarn build # \*.ts Also, triggers prebuild script
```

1. Build proto files into typescript

2. Build the project

If proto files doesn't exist in the model folder you may need to run

```bash
yarn build:proto
```

## Server Start

```bash
yarn start # Start the server
```

![](../../images/2021-06-25_at_2.46.11-2x.png)

If the service is running, you can create GET request to trigger Health Check function.

```
curl --location --request GET 'localhost:3000/'
```

or you can use postman.

![](../../images/2021-06-25_at_2.47.39-2x.png)

**Local Testing while Developing**

We need to install bloomRPC to test gRPC servers.

[https://github.com/uw-labs/bloomrpc](https://github.com/uw-labs/bloomrpc)

**Installisation**

#### For MacOS and Homebrew users:

```bash
brew install --cask bloomrpc
```

The app will get installed and copied to the path `/Applications/BloomRPC.app`

#### For Windows and chocolatey users:

```bash
choco install bloomrpc
```

Search for bloomrpc in windows search.

![](../../images/editor-preview.gif)

If you have tms service in your local, you can import proto files from tms service.

**To Test NiFi gRPC**

First, install NiFi locally using Docker. Follow the doc.

[https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/1738986](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/1738986)

After that import nifi proto file (you can find it in tms service folder)

![](../../images/2021-06-25_at_2.40.48-2x.png)

# Deployment

```bash
faas up -f ./service-name.yml
```

You need to deploy using prod yaml (which includes ***frmsecretpull***)

If your openfaas functions needs to access each other, you need to mesh them using linkerd.

**Meshing**

[Meshing my Service using Linkerd](../architecture-and-design/linkerd/meshing-my-service-using-linkerd.md)

After that you need to update environment variables. Because gRPC clients needs to use **meshed URL.**

Otherwise you can not create a request.

# Unit and Integration Testing (Soon)

# Security (SSL)

gRPC is designed to work with a variety of authentication mechanisms, making it easy to safely use gRPC to talk to other systems. You can use our supported mechanisms - SSL/TLS with or without Google token-based authentication - or you can plug in your own authentication system by extending our provided code.

### Supported auth mechanisms

The following authentication mechanisms are built-in to gRPC:

- **SSL/TLS**: gRPC has SSL/TLS integration and promotes the use of SSL/TLS to authenticate the server, and to encrypt all the data exchanged between the client and the server. Optional mechanisms are available for clients to provide certificates for mutual authentication.
- **ALTS**: gRPC supports [ALTS](https://cloud.google.com/security/encryption-in-transit/application-layer-transport-security) as a transport security mechanism, if the application is running on [Google Cloud Platform (GCP)](https://cloud.google.com). For details, see one of the following language-specific pages: [ALTS in C++](https://grpc.io/docs/languages/cpp/alts/), [ALTS in Go](https://grpc.io/docs/languages/go/alts/), [ALTS in Java](https://grpc.io/docs/languages/java/alts/), [ALTS in Python](https://grpc.io/docs/languages/python/alts/).
- **Token-based authentication with Google**: gRPC provides a generic mechanism (described below) to attach metadata based credentials to requests and responses. Additional support for acquiring access tokens (typically OAuth2 tokens) while accessing Google APIs through gRPC is provided for certain auth flows: you can see how this works in our code examples below. In general this mechanism must be used *as well as* SSL/TLS on the channel - Google will not allow connections without SSL/TLS, and most gRPC language implementations will not let you send credentials on an unencrypted channel.

Also, when you create a client, make sure the client variable is in safe mode.

![](../../images/2021-06-25_at_2.53.05-2x.png)

**gRPC NodeJS and SSL**

[https://github.com/gbahamondezc/node-grpc-ssl](https://github.com/gbahamondezc/node-grpc-ssl)

[https://bbengfort.github.io/2017/03/secure-grpc/](https://bbengfort.github.io/2017/03/secure-grpc/)

## Related articles

[https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/1738986](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/1738986)

[Deep Dive into gRPC Deployment](../Deep-Dive-Into-gRPC-Deployment.md)

[Load balancing with gRPC](../architecture-and-design/linkerd/load-balancing-with-grpc.md)
