# Creating a new rule processor

- [Creating a new rule processor](#creating-a-new-rule-processor)
  - [Introduction](#introduction)
  - [Steps for a new rule processor](#steps-for-a-new-rule-processor)
    - [Design your rule](#design-your-rule)
    - [Rule processors follow 4 main steps:](#rule-processors-follow-4-main-steps)
    - [Configuration set up](#configuration-set-up)
    - [Deploy a rule processor](#deploy-a-rule-processor)

## Introduction

The Tazama evaluation pipeline is intended to be largely configuration driven via external and centralized configuration files. Configuration information is stored in a Configuration database and served to a variety of evaluation processors as required:

![Tazama core components and config](/images/tazama-core-components-config.drawio.svg)

Creating a new processor involves the development work to define the functioning of that new processor. In addition to the rule processor, Tazama requires configurations for the rule configuration, typology configuration and network map. 

See [Configuration Management](/Product/configuration-management.md)

The suggested approach is to use rule-901 as the "template" [Rule-901 repository](https://github.com/tazama-lf/rule-901)

## Steps for a new rule processor

### Design your rule
1. Define what is the rule processor supposed to do
2. Identify the data that is required
3. Create the query you need to get the data you want (behavioural, historical analysis)
4. The query should produce exactly the thing you want to evaluate, otherwise more post-processing will be required. E.g. if you need to count the number of transactions to evaluate a specific type of behaviour, then the query should ideally only return the number of transactions.

### Rule processors follow 4 main steps:
1. Define early exit conditions: If you can detect anything from the incoming transaction that already disqualifies the rule, you can evaluate those conditions early in the processor and avoid an expensive database query.
2. Query preparation: Here you will assign all the parameters for the query to variables, and then prepare the query string as a complete string that can be sent to the database.
3. Query execution: The query is sent to the database and the results returned.
4. Query post-processing: Sometimes the results from the database cannot be interpreted immediately and must first be transformed into something the rule processor needs. For instance, if you want to arrange the results of the query into a histogram to calculate a mean and standard deviation, or if you need to execute a second query that needs the results from the first query.

### Configuration set up

[Rule Processor Configuration](https://github.com/tazama-lf/docs/blob/main/Product/configuration-management.md#21-rule-processor-configuration)

<details>
  <summary>Rule configuration example</summary>

```
{
  "id": "901@1.0.0",
  "cfg": "1.0.0",
  "desc": "Number of outgoing transactions - debtor",
  "config": {
    "parameters": {
      "maxQueryRange": 86400000
    },
    "exitConditions": [
      {
        "subRuleRef": ".x00",
        "reason": "Incoming transaction is unsuccessful"
      }
    ],
    "bands": [
      {
        "subRuleRef": ".01",
        "upperLimit": 2,
        "reason": "The debtor has performed one transaction to date"
      },
      {
        "subRuleRef": ".02",
        "lowerLimit": 2,
        "upperLimit": 4,
        "reason": "The debtor has performed two or three transactions to date"
      },
      {
        "subRuleRef": ".03",
        "lowerLimit": 4,
        "reason": "The debtor has performed 4 or more transactions to date"
      }
    ]
  }
}
```
</details>
<br>

[Typology Processor Configuration](https://github.com/tazama-lf/docs/blob/main/Product/configuration-management.md#22-typology-configuration)


 
<details>
  <summary>Typology configuration example</summary>

```
{
  "typology_name": "Rule-901-Typology-999",
  "id": "typology-processor@1.0.0",
  "cfg": "999@1.0.0",
  "workflow": {
    "alertThreshold": 200,
    "interdictionThreshold": 400
  },
  "rules": [
    {
      "id": "901@1.0.0",
      "cfg": "1.0.0",
      "termId": "v901at100at100",
      "wghts": [
        {
          "ref": ".err",
          "wght": "0"
        },
        {
          "ref": ".x00",
          "wght": "100"
        },
        {
          "ref": ".01",
          "wght": "100"
        },
        {
          "ref": ".02",
          "wght": "200"
        },
        {
          "ref": ".03",
          "wght": "400"
        }
      ]
    }
  ],
  "expression": [
    "Add",
    "v901at100at100"
  ]
}
```
</details>
<br>

[Network Map Configuration](https://github.com/tazama-lf/docs/blob/main/Product/configuration-management.md#23-the-network-map)

<details>
  <summary>Network map example</summary>

```
{
  "active": true,
  "name": "Public Network Map",
  "cfg": "1.0.0",
  "messages": [
    {
      "id": "004@1.0.0",
      "cfg": "1.0.0",
      "txTp": "pacs.002.001.12",
      "typologies": [
        {
          "id": "typology-processor@1.0.0",
          "cfg": "999@1.0.0",
          "rules": [
            {
              "id": "901@1.0.0",
              "cfg": "1.0.0"
            }
          ]
        }
      ]
    }
  ]
}
```
</details>

### Deploy a rule processor

Follow the steps in the guide to [deploy a new rule](
https://github.com/tazama-lf/docs/blob/dev/Guides/adding-a-rule-processor-to-the-full-service-full-stack-docker-tazama-for-testing.md)
 