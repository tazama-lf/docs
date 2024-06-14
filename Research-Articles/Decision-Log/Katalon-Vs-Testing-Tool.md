<!-- SPDX-License-Identifier: Apache-2.0 -->

# Katalon vs Testing tool

Add your comments directly to the page. Include links to any relevant research, data, or feedback.

|     |     |
| --- | --- |
| Status | NOT STARTED |
| Impact | MEDIUM |
| Driver | Jonty Esterhuizen |
| Approver |     |
| Contributors |     |
| Informed |     |
| Due date |     |
| Outcome |     |

## Background

We need to decide between using Katalon and using the testing tool

Katalon was used but we needed a tool that would be able to use grpc requests and katalon does not support that

That is where the creation of this testing tool started

## Relevant data

- [https://docs.katalon.com/katalon-studio/docs/online-offline-licenses.html](https://docs.katalon.com/katalon-studio/docs/online-offline-licenses.html)
- [https://docs.katalon.com/katalon-analytics/docs/testops\_subscriptions\_overview.html](https://docs.katalon.com/katalon-analytics/docs/testops_subscriptions_overview.html)

## Options considered

|     | Option 1: Katalon | Option 2: Testing tool |
| --- | --- | --- |
| Description | Combination of Katalon studio and katalon test ops | Custom written Nest js app similar to the mojaloop testing toolkit |
| Pros and cons | ![plus](../../images/plus_32.png) **Dashboard** - Has a nice dashboard<br><br>![plus](../../images/plus_32.png)**Integration** - Jenkins integration<br><br>![plus](../../images/plus_32.png)**Testing Methode** - Uses asert to do tests<br><br>![(minus)](../../images/minus_32.png)Cant receive json<br><br>![(minus)](../../images/minus_32.png)Need to reconfigure all tests if results change<br><br>![(minus)](../../images/minus_32.png)Not open source<br><br>![(minus)](../../images/minus_32.png)**Execution Time -** Takes long to complete the tests(10minutes)<br><br>![(minus)](../../images/minus_32.png)Cant use grpc calls | ![plus](../../images/plus_32.png)**Dasboard** - Uses jenkins blue ocean as dash board<br><br>![plus](../../images/plus_32.png)**Configuration -** Easy to configure<br><br>![plus](../../images/plus_32.png)**Configuration -** Accepts dynamic json data  <br>![plus](../../images/plus_32.png)**Execution TIme -** Runs faster (1-2minutes)<br><br>![plus](../../images/plus_32.png)Can also do grpc calls<br><br>![(minus)](../../images/minus_32.png)If any changes needed code needs to be written |
| Estimated cost | $100+ | free |

## Action items

## Outcome
