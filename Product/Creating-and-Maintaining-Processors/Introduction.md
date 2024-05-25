# Creating and Maintaining Processors

- [Creating and Maintaining Processors](#creating-and-maintaining-processors)
  - [Introduction](#introduction)
  - [Channel Routing and Setup Processor](#channel-routing-and-setup-processor)
  - [Rules Processors](#rules-processors)
  - [Typology Processor](#typology-processor)
  - [Channel Aggregation and Decisioning Processor](#channel-aggregation-and-decisioning-processor)
  - [Transaction Aggregation and Decisioning Processor](#transaction-aggregation-and-decisioning-processor)
  - [The Network Map](#the-network-map)
  - [General](#general)
  - [Transactions](#transactions)
  - [Channels](#channels)
  - [Typologies](#typologies)
  - [Rules](#rules)

## Introduction

The Tazama evaluation pipeline is intended to be largely configuration driven via external and centralised configuration files, as described in the diagram below:

![](../../Images/image-20220902-102945.png)

Configuration information is stored in a Configuration database and served to a variety of evaluation processors as required:

## Channel Routing and Setup Processor

- Routing via a network map that is dynamically composed based on transaction attributes

## Rules Processors

- Channel and typology routing information via a network map
- Rule parameters

## Typology Processor

- Channel and rule routing information via a network map
- Typology expression
- Typology scoring

## Channel Aggregation and Decisioning Processor

- Typology routing information via a network map
- Typology trigger information

## Transaction Aggregation and Decisioning Processor

- Channel routing information via a network map
- Transaction scoring

Components in the pipeline can be created, updated or removed by an authorised user. For the MVP, the CRUD activities for these components is a development process, supported by a CI/CD process, but eventually we would govern the over-all process through a user interface and supporting workflow.

The sections here provides a process for the creation and maintenance of the various processors.

The user stories for the creation and maintenance of the processors can be summarised in the following table:

| **User Story** | **Actor/User** |
| --- | --- |
| I want to create a new rule processor | For the MVP, these activities will be performed by a developer.<br><br>One day when we’re grown up, these activities will be performed by a user via a user interface |
| I want to create a new typology |
| I want to create a new channel |
| I want to create a new transaction |
| I want to update an existing rule processor |
| I want to update an existing typology |
| I want to update an existing channel |
| I want to update an existing transaction |
| I want to re-calibrate an existing rule processor |
| I want to re-calibrate an existing typology |
| I want to re-calibrate an existing channel |
| I want to change a transaction’s evaluation routing |

**Spoiler**: Only the rule processors are actually discrete processors where there are many different rule processors. The Channel Router and Setup Processor, Typology Processor, Channel Aggregation and Desicioning Processor and the Transaction Aggregation and Decisioning processors are all universal in singular components (Highlanders)

The user stories for the creation of the evaluation pipeline processors will all follow the same basic process flow:

![](../../Images/Tazama_TMS_Processor_CRUD.png)

Even though there is only one Typology Processor (for example), a new version of the processor can still be created to replace the existing Typology Processor. (Heck, we can even add a new Typology Processor that does something completely different and runs in parallel to the existing processor. We probably wouldn’t want to run a parallel CRSP though, but we may create a replacement for it. Also, Data Preparation is not currently designed to invoke multiple CRSPs and we would need to add some additional routing logic to Data Preparation to run parallel CRSPs… Actually, forget about parallel Highlanders, just like we should all forget about the movie sequels...)

Creating a new processor involves the development work to define the functioning of that new processor. Creating a processor configuration creates the configuration in the Config DB that will govern the operation of the processor. Creation of the processor and its configuration, and even deployment of the processor and its configuration, will not enable the processor to be invoked: the processor, and its configuration, must be connected into the evaluation pipeline flow by updating the Network Map.

The sections below will provide a detailed overview of each of the user stories for the creation and maintenance of the evaluation processors.

The overall process and dependencies for the creation of a new processor can be managed through the following steps. Assume, for the moment, that nothing (except the CRSP, Typology Processor, CADProc and TADProc) currently exists and the Network Map is empty. We’re implementing our first typology:

- Step 1: Create the transaction object in the Network Map
- Step 2: Create the channel object under the transaction in the Network Map
- Step 3: Develop the Rule Processor(s)
- Step 3.a. Create the rule processor configurations
- Step 4: Create the Typology Configuration
- Step 5: Update the Network Map
- Step 5.a. Add the typology under the channel in the Network Map
- Step 5.b. Add the rule(s) under the typology in the Network Map

**Note**: For now, and until we decide otherwise based on the transactions, rules and typologies we choose to deploy, ALL typologies will be deployed into a single channel for pain.001.001.11 transactions.

## The Network Map

Control of the routing of a transaction for evaluation is centralised in the Network Map. The Network Map is a JSON object with nested control information for the transactions, channels, typologies and rules. The current version of the network map is articulated here:[https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6520927/Channel+Router+and+Setup+Processor+CRSP#3.1.-Read-Network-Map](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6520927/Channel+Router+and+Setup+Processor+CRSP#3.1.-Read-Network-Map)

The network map will be revised as sampled below to meet the requirements of the processes outlined in this section, and in particular in a way that will keep the Network Map “light”, to minimise the overhead in its transmission as part of the payload between processors.

```json
[
    {
        "transactions": [
            {
                "id": "001@1.0.0",
                "host": "http://openfaas:8080",
                "cfg": "1.0.0",
                "messageId": "pain.001.001.11",
                "channels": [
                    {
                        "id": "001@1.0.0",
                        "host": "http://openfaas:8080",
                        "cfg": "1.0.0",
                        "typologies": [
                            {
                                "id": "001@1.0.0",
                                "host": "http://openfaas:8080",
                                "cfg": "028@1.0.0",
                                "rules": [
                                    {
                                        "id": "003@1.0.0",
                                        "host": "http://openfaas:8080",
                                        "cfg": "1.0.0"
                                    }
                                ]
                            },
                            {
                                "id": "001@1.0.0",
                                "host": "http://openfaas:8080",
                                "cfg": "029@1.0.0",
                                "rules": [
                                    {
                                        "id": "003@1.0.0",
                                        "host": "http://openfaas:8080",
                                        "cfg": "1.1.0"
                                    }
                                ]
                            },
                            {
                                "id": "002@1.0.0",
                                "host": "http://openfaas2:8080",
                                "cfg": "030@1.0.0",
                                "rules": [
                                    {
                                        "id": "003@2.0.0",
                                        "host": "http://openfaas2:8080",
                                        "cfg": "1.0.0"
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    }
]
```

## General

1. In general, an object in the network map is a collection of objects and attributes that provide the following information:
    1. Which processor is going to do the work (id and version)
    2. Where will the processor be hosted (processors may be deployed to different servers or locations for operational reasons)
    3. Which configuration will be used to “drive” the processor (id and version, or just version)
    4. (Optional) additional routing attributes (e.g. the ISO messageId in the transaction object)
    5. An array of the nested objects within the overhead object
2. Naming is intended to be as compact as possible to minimise the size of the payload for transmission between processors.

## Transactions

1. At the root of the Network Map is a “transactions” array of transaction objects (“transactions”)
2. The transaction object contains the information that will allow the Channel Router and Setup Processor to route a transaction for evaluation and also to ultimately aggregate the evaluation results at the transaction level (by the Transaction Aggregation and Decisioning Processor)
    1. **[transaction].id**: The Transaction Aggregation and Decisioning Processor name (e.g. “001”) and version (e.g. “1.0.0”) separated by an “@”, i.e. “001@1.0.0”
        1. For the MVP, we will only deploy a single TADProc, named “001”. The MVP release version of the TADProc is expected to be “1.0.0”, but may have incremental versions of the processor leading up to 1.0.0 during the MVP development process.
        2. Each of our current transaction types will map to a different major version number:
            1. pain.001: 1.0.0
            2. pain.013: 2.0.0
            3. pacs.008: 3.0.0
            4. pacs.002: 4.0.0
        3. The MVP will only focus on pacs.002 evaluations.
        4. The design is intended to be flexible to allow for multiple concurrent variants and versions of the TADProc to be deployed in Actio.
    2. **[transaction].host**: the HTTP destination address of the Transaction Aggregation and Decisioning Processor that will conclude the evaluation for the transaction.
    3. **[transaction].cfg**: the version of the configuration that would drive the behaviour of the Transaction Aggregation and Decisioning Processor for the transaction.
        1. The config is intended to provide a final checkpoint for typology and channel results and is generally optional. For the MVP, the TADProc will evaluation typologies against set thresholds (as defined in the transaction config) to trigger investigations through the Case Management Solution).
    4. **[transaction].messageId**: the ISO 20022 message definition ID for the message that will be evaluated in the channels and using the typologies and rules defined in the Network Map under that transaction object.

## Channels

1. Nested within each transaction object is an array of channel objects (“channels”)
2. The channel object contains the information that will allow the Channel Router and Setup Processor to route a transaction and also to ultimately aggregate the evaluation results at the channel level (by the Channel Aggregation and Decisioning Processor)
    1. **[channel].id**: The Channel Aggregation and Decisioning Processor name (e.g. “001”) and version (e.g. “1.0.0”) separated by an “@”, i.e. “001@1.0.0”
        1. For the MVP, we will only deploy a single CADProc, named “001”. The MVP release version of the CADProc is expected to be “1.0.0”, but may have incremental versions of the processor leading up to 1.0.0 during the MVP development process.
        2. The design is intended to be flexible to allow for multiple concurrent variants and versions of the CADProc to be deployed in Actio.
    2. **[channel].host**: the HTTP destination address of the Channel Aggregation and Decisioning Processor that will conclude the evaluation of the transaction for the channel.
    3. **[channel].cfg**: the version of the configuration that would drive the behaviour of the Channel Aggregation and Decisioning Processor for the transaction.
        1. The primary function of the channel config is to define the groups of typologies that would trigger a “proceed” message to the client system. This is not in scope for the MVP and the channel config version could be left blank (i.e. “cfg”: ““)

## Typologies

1. Nested within each channel object is an array of typology objects (“typologies”)
2. The transaction object contains the information that will allow the CRSP to route a transaction and also to ultimately aggregate the evaluation results at the typology level (by the Typology Processor)
    1. **[typology].id**: The Typology Processor name (e.g. “001”) and version (e.g. “1.0.0”) separated by an “@”, i.e. “001@1.0.0”
        1. For the MVP, we will only deploy a single Typology Processor, named “001”. The MVP release version of the Typology Processor is expected to be “1.0.0”, but may have incremental versions of the processor leading up to 1.0.0 during the MVP development process.
        2. The design is intended to be flexible to allow for multiple concurrent variants and versions of the Typology Processor to be deployed in Actio.
    2. **[typology].host**: the HTTP destination address of the Typology Processor that will conclude the evaluation of the transaction for the channel.
    3. **[typology].cfg**: the version of the configuration that would drive the behaviour of the Typology Processor for the transaction.
        1. In our MVP design, the Typology Processor is a universal processing engine and a typology configuration could be considered the actual unique typology.

## Rules

1. Nested within each typology is an array of rule objects (“rules”)
2. The transaction object contains the information that will allow the CRSP to route a transaction
    1. **[rule].id**: The Rule Processor name (e.g. “001”) and version (e.g. “1.0.0”) separated by an “@”, i.e. “001@1.0.0”
        1. The MVP release version of a Rule Processor is expected to be “1.0.0”, but may have incremental versions of the processor leading up to 1.0.0 during the MVP development process.
        2. The design is intended to be flexible to allow for multiple concurrent variants and versions of a Rule Processor to be deployed in Actio.
    2. **[rule].host**: the HTTP destination address of the Rule Processor that will conclude the evaluation of the transaction for the channel.
    3. **[rule].cfg**: the version of the configuration that would drive the behaviour of the Rule Processor for the transaction.
        1. The primary function of the channel config is to define the groups of typologies that would trigger a “proceed” message to the client system. This is not in scope for the MVP and the channel config version could be left blank (i.e. “cfg”: ““)
        2. We are not providing for two separate Rule Processors (different name@version ID’s) using the same configuration. Every rule configuration will be linked to a single rule processor ID. In other words, when a rule processor is updated with a new version, the rule configuration will be updated as well.
        3. Conversely, a rule config can be updated to a new version without issuing a new rule processor or version.
