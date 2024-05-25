<!-- SPDX-License-Identifier: Apache-2.0 -->

# How to address Docker Pull Rate Limit

Add your comments directly to the page. Include links to any relevant research, data, or feedback.

|     |     |
| --- | --- |
| Status | IN PROGRESS |
| Impact | HIGH / MEDIUM / LOW |
| Driver | Johann Nel |
| Approver |     |
| Contributors | Greg McCormick,  Johan Foley, Jason Darmanovich, Rob Reeve, Justus Ortlepp  |
| Informed |     |
| Due date | 19 Feb 2021 |
| Outcome |     |

## Background

When using docker images on a regular basis, one would come across Docker Pull rate errors sooner or later. This pertains to the number of times that images are pulled from docker. Currently, the limitations are as follows:

- 100 image pulls every 6 hours for an anonymous user

- 200 image pulls every 6 hours for a user using the free tier

- Paying customers have an unlimited amount

When looking at the above one would assume that it is more than enough but there is a slight disconnect between the pull limit and actual requests being sent to docker.

The pull limit actually refers to the number of times that the pull request hits the registry manifest and not necessarily downloading the image from the net. Simply put if you pull the same image twice, the first would download the image and the second will hit the registry and respond immediately, unfortunately, this contributes to your pull limit.

Thus these pull limits are quite easily reached when deploying a large stack like Mojaloop or even when your pull policy on your images is set to **Always**.

An investigation was done to find a solution to the problem we were facing deploying Mojaloop to both local and server environments and below is a table with information needed to make a clear decision.

## Relevant data

## Options considered

|     | Option 1: | Option 2: | Option 3: |
| --- | --- | --- | --- |
| Description | Docker Hub | Local Registry - Harbor | Container - Registry |
| Environment location | ![plus](../../images/plus_32.png) No environment setup, cloud based | ![plus](../../images/plus_32.png)<br><br>![(minus)](../../images/minus_32.png) |     |
| Developer Overhead |     |     |     |
| Authentication |     |     |     |
| Vulnerability Scanning |     |     |     |
| Users |     |     |     |
| Access Control |     |     |     |
| Repositories |     |     |     |
| Collaboration |     |     |     |
| Domain |     |     |     |
| Storage |     |     |     |
| CI/CD |     |     |     |
| Registry Governance |     |     |     |
| UI  |     |     |     |
| Data Protection |     |     |     |
| Data Durability |     |     |     |
| 3rd party images |     |     |     |
| Misc. |     |     |     |
|     |     |     |     |
|     |     |     |     |
| Estimated cost | LARGE | MEDIUM |     |

## Action items

## Outcome
