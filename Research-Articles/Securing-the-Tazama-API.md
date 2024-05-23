<!-- SPDX-License-Identifier: Apache-2.0 -->

Proposed solution for authenticating the TMS API:

## Overview

Tazama is currently exposed as an unsecured API service. Introducing feature-filled security and management functionality 
will be crucial to ensure data integrity, data privacy and prevention of outside abuse.

Incorporating an API Gateway along with an Identity Provider will significantly enhance the robustness and
security of the API.

## Graph

<pre>
                      ┌──────────────┐
                      │              │
                      │   Keycloak   │
                      │              │
                      └──────────────┘
                             ▲
                             │
                             │
                             │  Authentication
                             │
                             │
                             ▼
                     ┌──────────────────┐                  ┌─────────────────┐
           Request   │                  │    Validated     │                 │
CLIENT    ─────────► │  APISIX GATEWAY  │   ────────────►  │  TAZAMA API     │
                     │                  │                  │                 │
                     └──────────────────┘                  └─────────────────┘
</pre>

## Why APISIX? (Gateway) - https://apisix.apache.org/

APISIX acts as a powerful API gateway, providing features like rate limiting, monitoring, and analytics, which can help manage traffic and ensure the API's performance and reliability.

### Benefits

Security Enhancements: Beyond authentication, APISIX offers additional security features such as IP whitelisting/blacklisting, encryption, and request validation to protect against common threats and vulnerabilities.

Extensibility: APISIX is designed to be extensible, supporting custom plugins and integrations. This allows for the addition of new features or enhancements tailored to the API's specific needs.

Load Balancing: APISIX provides load balancing features, helping distribute incoming API traffic across multiple backend services to improve responsiveness and availability.

High Performance: Engineered for high performance and low latency, APISIX is suitable for scenarios requiring fast response times and handling high volumes of traffic.

### Downsides

Learning Curve: Integrating and configuring APISIX, especially with advanced features and custom plugins, may require a significant investment in learning and development.

Operational Overhead: Managing an API gateway like APISIX adds another component to your infrastructure, potentially increasing the complexity and overhead of operations and maintenance.

Resource Utilization: While designed for efficiency, APISIX still consumes system resources, which could be a consideration for resource-constrained environments.

## Why Keycloak? (Identity) - https://www.keycloak.org/

Keycloak provides comprehensive support for modern authentication protocols like OpenID Connect and OAuth 2.0. It can manage user identities, federate identities from different providers, and control access to services and resources, ensuring that only authenticated and authorized users can access your API.

### Benefits

Feature set: Keycloak has nearly every authentication feature possible. From SSO to SAML to passwordless to Kerberos, Keycloak’s off the shelf offering is incredibly wide. These features are available to everyone, no payment required.

Customizable: Keycloak is highly configurable and extensible, allowing for custom realms, user federation, identity brokering, and more. It can be tailored to fit the specific security needs of your API.

Community and Support: Being an open-source project, Keycloak has a strong community and support network, making it easier to find help and resources for implementing and troubleshooting.

### Downsides

Complexity: The extensive features and capabilities of Keycloak can introduce complexity into your system, potentially increasing the effort required for setup, configuration, and maintenance.

Performance Overhead: As with any security layer, Keycloak can introduce additional latency to API calls due to the authentication and authorization processes.

Scaling concerns: While Keycloak has been proven to scale to millions of users, most companies at a large enough stage have trouble keeping up with the engineering required to customize Keycloak.

User Satisfaction: From alternatives such as Ory (Hydra + Kratos) and SuperTokens, Keycloak has the lowest user satisfaction from online surveys.
