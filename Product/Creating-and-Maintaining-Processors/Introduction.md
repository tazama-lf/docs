# Creating and Maintaining Processors

- [Creating and Maintaining Processors](#creating-and-maintaining-processors)
  - [Introduction](#introduction)
  - [Event Director](#event-director)
  - [Rules Processors](#rules-processors)
  - [Typology Processor](#typology-processor)
  - [Transaction Aggregation and Decisioning Processor](#transaction-aggregation-and-decisioning-processor)
  - [The Network Map](#the-network-map)
  - [General](#general)
  - [Messages](#messages)
  - [Typologies](#typologies)
  - [Rules](#rules)

## Introduction

The Tazama evaluation pipeline is intended to be largely configuration driven via external and centralized configuration files. Configuration information is stored in a Configuration database and served to a variety of evaluation processors as required:

![Tazama core components and config](/images/tazama-core-components-config.drawio.svg)

See [Configuration Management](/Product/configuration-management.md)

## Event Director

- Routing via a network map is dynamically composed based on transaction attributes

## Rules Processors

- Typology routing information via a network map
- Rule parameters

## Typology Processor

- Rule routing information via a network map
- Typology expression
- Typology scoring

## Transaction Aggregation and Decisioning Processor

- Typology routing information via a network map
- Typology trigger information
- Transaction scoring

Components in the pipeline can be created, updated or removed by an authorized user. For the MVP, the CRUD activities for these components is a development process, supported by a CI/CD process, but eventually we would govern the over-all process through a user interface and supporting workflow.

Creating a new processor involves the development work to define the functioning of that new processor. Creating a processor configuration creates the configuration in the Config DB that will govern the operation of the processor. Creation of the processor and its configuration, and even deployment of the processor and its configuration, will not enable the processor to be invoked: the processor, and its configuration, must be connected into the evaluation pipeline flow by updating the Network Map.

The sections below will provide a detailed overview for the creation and maintenance of the evaluation processors.

The overall process and dependencies for the creation of a new processor can be managed through the following steps. Assume, for the moment, that nothing (except the Event Director, Typology Processor, TADProc) currently exist and the Network Map is empty. We're implementing our first typology:

- Step 1: Create the transaction object in the Network Map
- Step 2: Develop the Rule Processor(s)
- Step 2.a. Create the rule processor configurations
- Step 3: Create the Typology Configuration
- Step 4: Update the Network Map
- Step 4.a. Add the rule(s) under the typology in the Network Map

## The Network Map

Control of the routing of a transaction for evaluation is centralized in the Network Map. The Network Map is a JSON object with nested control information for the transactions, typologies and rules. The network map will be revised to meet the requirements of the processes outlined in this section, and in particular in a way that will keep the Network Map "light", to minimize the overhead in its transmission as part of the payload between processors.

 [Complete example of a network map](/Product/complete-example-of-a-network-map.md)

## General

1. In general, an object in the network map is a collection of objects and attributes that provide the following information:
    1. Which processor is going to do the work (id and version)
    2. Where will the processor be hosted (processors may be deployed to different servers or locations for operational reasons)
    3. Which configuration will be used to "drive" the processor (id and version, or just version)
    4. (Optional) additional routing attributes (e.g. the ISO messageId in the transaction object)
    5. An array of the nested objects within the overhead object
2. Naming is intended to be as compact as possible to minimize the size of the payload for transmission between processors.

## Messages  

1. At the root of the Network Map is a "messages" array of transaction objects ("transactions")
2. The messages object contains the information that will allow the Event Director to route a transaction for evaluation and also to ultimately aggregate the evaluation results at the transaction level (by the Transaction Aggregation and Decisioning Processor)
    1. **[message].id**: The Transaction Aggregation and Decisioning Processor name (e.g. "001") and version (e.g. "1.0.0") separated by an "@", i.e. "001@1.0.0"
        1. The MVP will only focus on pacs.002 evaluations.
        2. The design is intended to be flexible to allow for multiple concurrent variants and versions of the TADProc to be deployed in Tazama.
    2. **[message].cfg**: the version of the configuration that would drive the behaviour of the Transaction Aggregation and Decisioning Processor for the transaction.
        1. The config is intended to provide a final checkpoint for typology results and is generally optional. For the MVP, the TADProc will evaluation typologies against set thresholds (as defined in the transaction config) to trigger investigations through the Case Management Solution.
    3. **[transaction].txTp**: the ISO 20022 message definition ID for the message that will be evaluated in the typologies and rules defined in the Network Map under that transaction object.

## Typologies

1. Nested within each message object is an array of typology objects ("typologies")
2. The transaction object contains the information that will allow the ED to route a transaction and also to ultimately aggregate the evaluation results at the typology level (by the Typology Processor)
    1. **[typology].id**: The Typology Processor name (e.g. "001") and version (e.g. "1.0.0") separated by an "@", i.e. "001@1.0.0"
        1. For the MVP, we will only deploy a single Typology Processor, named "001". The MVP release version of the Typology Processor is expected to be "1.0.0", but may have incremental versions of the processor leading up to 1.0.0 during the MVP development process.
        2. The design is intended to be flexible to allow for multiple concurrent variants and versions of the Typology Processor to be deployed in Tazama.
    2. **[typology].cfg**: the version of the configuration that would drive the behaviour of the Typology Processor for the transaction.
        1. In our MVP design, the Typology Processor is a universal processing engine and a typology configuration could be considered the actual unique typology.

## Rules

1. Nested within each typology is an array of rule objects ("rules")
2. The transaction object contains the information that will allow the ED to route a transaction
    1. **[rule].id**: The Rule Processor name (e.g. "001") and version (e.g. "1.0.0") separated by an "@", i.e. "001@1.0.0"
        1. The MVP release version of a Rule Processor is expected to be "1.0.0", but may have incremental versions of the processor leading up to 1.0.0 during the MVP development process.
        2. The design is intended to be flexible to allow for multiple concurrent variants and versions of a Rule Processor to be deployed in Tazama.
    2. **[rule].cfg**: the version of the configuration that would drive the behaviour of the Rule Processor for the transaction.
        1. We are not providing for two separate Rule Processors (different name@version ID's) using the same configuration. Every rule configuration will be linked to a single rule processor ID. In other words, when a rule processor is updated with a new version, the rule configuration will be updated as well.
        2. Conversely, a rule config can be updated to a new version without issuing a new rule processor or version.
