<!-- SPDX-License-Identifier: Apache-2.0 -->

# Orchestration layer for both infrastructure and services needs

Add your comments directly to the page. Include links to any relevant research, data, or feedback.

Explore and recommend the management of Kubernetes as a optimal orchestration layer for both infrastructure and service(s) needs. (used to orchestrate the processes - create channels, add queues, rules, instantiating pods, dropping pods in real time as needed) by controlling a dynamic Deployment workload to manage stateless applications. Is it enough to have YAML - or something else.

|     |     |
| --- | --- |
| Status | IN PROGRESS |
| Impact | HIGH |
| Driver | Aarón Reynoza |
| Approver |     |
| Contributors | Jaco Bornman jason darmanovich Henk Kodde Darshan Gadkari |
| Informed |     |
| Due date |     |
| Outcome |     |

## Background

In order to deploy the FRM platform, we need to decide which technology we’re going to use to deploy the application into Kubernetes and to manage configuration.

While the application right now may be deployed using kubernetes yaml files, this may eventually grown in complexity, and we’ll also lack many features that other technologies provide.

During the PoC and ongoing MVP PI, some members have already familiarized with Mojaloop’s deployment strategy: [Helm.](https://helm.sh/) This technology allows us to package an application and expose only the configuration. This approach has some drawbacks, but some of them have been fixed in a newer version of Helm. There’s more tools that are able to improve helm functionality, like [Helmfile](https://github.com/roboll/helmfile) which adds additional functionality to Helm by wrapping it in a declarative spec that allows us to compose several charts together to create a comprehensive deployment artifact for anything from a single application to an entire infrastructure stack. In addition to the Templating and Packaging Helm provides for Kubernetes manifests, Helmfile provides a way to apply GitOps style CI/CD methodologies over your Helm charts, which is one of the biggest problems when dealing with Helm.

## Relevant data

As helm is a template, packaging manager, it its very verbose and proves to be hard to work on large applications, these issues are related to configuration, debugging and security. A proof of concept to deploy Mojaloop using Kustomize is [available on github](https://github.com/partiallyordered/mojaloop-kustomize). This deployment is simpler, and way smaller than the equivalent helm approach. However, it lacks the packaging features, plus there’s not such a huge support from the community as there is in helm.

## Options considered

|     | Raw k8s | Kustomize | Helm | Helmfile |
| --- | --- | --- | --- | --- |
| Description | Default Kubernetes API | Kustomize introduces a template-free way to customize application configuration | Helm Charts helps define, install, and upgrade applications | A declarative spec for deploying helm charts |
| Pros and cons | ![plus](../../images/plus_32.png) Simple<br><br>![plus](../../images/plus_32.png) Small apps<br><br>![plus](../../images/plus_32.png) Easy to onboard<br><br>![plus](../../images/plus_32.png) Easy to debug<br><br>![plus](../../images/plus_32.png) Declarative YAML<br><br>![plus](../../images/plus_32.png) Easy Debugging<br><br>![(minus)](../../images/minus_32.png) YAML files can grow too much<br><br>![(minus)](../../images/minus_32.png) Not a packaging offer<br><br>![(minus)](../../images/minus_32.png) Manual YAML insertion of dependencies | ![plus](../../images/plus_32.png) Integrated with Kubernetes<br><br>![plus](../../images/plus_32.png) Easy to control multiple environments<br><br>![plus](../../images/plus_32.png) Declarative YAML<br><br>![plus](../../images/plus_32.png) Easy Debugging<br><br>![(minus)](../../images/minus_32.png) YAML files can grow too much<br><br>![(minus)](../../images/minus_32.png) Not a packaging offer<br><br>![(minus)](../../images/minus_32.png) Manual YAML insertion of dependencies | ![(minus)](../../images/minus_32.png) Needs Tiller in versions < 3<br><br>![plus](../../images/plus_32.png) Client side only in version 3<br><br>![(minus)](../../images/minus_32.png) Difficult debugging<br><br>![(minus)](../../images/minus_32.png) Hard to learn<br><br>![(minus)](../../images/minus_32.png) Breaks GitOps standards<br><br>![plus](../../images/plus_32.png) Templating YAML<br><br>![plus](../../images/plus_32.png) Packaging<br><br>![plus](../../images/plus_32.png) Multiple pluggings available in the cloud<br><br>![plus](../../images/plus_32.png) Community adoption | ![(minus)](../../images/minus_32.png) Difficult debugging<br><br>![(minus)](../../images/minus_32.png) Hard to learn<br><br>![plus](../../images/plus_32.png) Templating YAML<br><br>![plus](../../images/plus_32.png) Packaging<br><br>![plus](../../images/plus_32.png) Multiple pluggings available in the cloud<br><br>![plus](../../images/plus_32.png) Community adoption<br><br>![plus](../../images/plus_32.png) GitOps standards with CI/CD for version control<br><br>![plus](../../images/plus_32.png) Very Modular<br><br>![plus](../../images/plus_32.png) Can install both helm charts and kustomizes<br><br>![plus](../../images/plus_32.png) Remote State<br><br>![plus](../../images/plus_32.png) Sync Deployments<br><br>![plus](../../images/plus_32.png) Call store remote state |
| Estimated cost | SMALL | MEDIUM | HIGH | HIGH |

## Helpful Links:

Kustomize: [https://kustomize.io/](https://kustomize.io/)

Helm: [https://helm.sh/](https://helm.sh/)

Helmfile: [https://github.com/roboll/helmfile](https://github.com/roboll/helmfile)

## Action items

- Review all options
- Offer another suggestion if you have
- Agree on an approach (in the meeting)

## Outcome

Team will use Helmfile due to the capability to use Kusmotize files + Helm charts with the extra features added. While we don’t necessarily like Helm, we’ll use it as the dependencies are packaged in helm charts and it’s easier to work with them using Helm itself.
