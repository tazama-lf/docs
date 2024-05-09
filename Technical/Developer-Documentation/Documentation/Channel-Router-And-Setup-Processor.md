# Channel Router and Setup Processor

![](/Images/Actio_TMS_CRSP_Context.png)

- [Channel Router and Setup Processor](#channel-router-and-setup-processor)
- [Introduction](#introduction)
- [Channel Router and Setup Processor Context](#channel-router-and-setup-processor-context)
  - [2. Evaluate Transaction](#2-evaluate-transaction)
  - [3.1. Read Network Map](#31-read-network-map)
  - [3.2. Determine Channels](#32-determine-channels)
  - [3.3. Determine Typologies](#33-determine-typologies)
  - [3.4. Determine Rules](#34-determine-rules)
  - [3.5. Prune the Network Map](#35-prune-the-network-map)
  - [3.6. Deduplicate Rules](#36-deduplicate-rules)
  - [3.7. Evaluate Transaction](#37-evaluate-transaction)
  - [3.8. CRSP Response](#38-crsp-response)

# Introduction

The foundation of the Tazama Transaction Monitoring system is its ability to evaluate incoming transactions for financial crime risk through the execution of a number of conditional statements (rules) that are then combined into typologies that describe the nature of the financial crime that the system is trying to detect. Typologies are in turn arranged into channels, according to an arrangement required by the operator.

![image](../../../Images/image-20210817-043926.png)

The Channel Router & Setup Processor (CRSP) is responsible for determining which channels and typologies a transaction must be submitted to for the transaction to be evaluated for Financial Crime Risk. As part of this process, the CRSP determines which rules must receive the transaction and then which typologies are to be scored. The CRSP routes the transaction to the individual rule processors.

# Channel Router and Setup Processor Context

![](../../../Images/Actio_TMS_CRSP_Context.png)

## 2. Evaluate Transaction

Once all the data preparation work in NiFi is complete, NiFi will route the incoming transaction message to the Channel Router & Setup Processor (CRSP) to commence the evaluation of the transaction.

## 3.1. Read Network Map

The network map defines the configuration according to which a transaction will be routed to typologies and their associated rule processors. The network map is a polynomial tree that contains the associations between a message type (at the root) and channels, typologies and rules:

![](../../../Images/image-20211018-085245.png)

The primary purpose of the CRSP is to determine which typologies are appropriate for the incoming transaction and then to route the transaction to the rules associated to those typologies. The network map allows the configuration of the relationships between message types, channels, typologies and rules to be centralised into an external configuration, rather than hard-coded in the CRSP.

The network map also contains the detailed identification and version information of each of the evaluation nodes comprising the network map.

Because the network map is routed to each evaluation node along with the incoming transaction, it would be possible to update the network map, or any of the evaluation nodes, while the system is in operation and without impacting the evaluation of any transactions in progress. It is also equally important that each iteration of the network map is properly versioned and also that the system keeps a record of which version of a network map was used when a transaction was evaluated so that the execution of the evaluation can be audited and even replayed or simulated.

The network map is a JSON object with nested key-value pairs describing the nodes in the map and their relationships.

Sample network map:

```json
[
    {
        "messages": [
            {
                "id": "001@1.0.0",
                "host": "http://openfaas:8080",
                "cfg": "1.0.0",
                "TxTp": "pain.001.001.11",
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

Discussion notes for future changes:

1. Can we add (optional) channel_description, typology_description and rule_description fields?

    1. No, to keep the file small, user-readable information is omitted.

2. We should separate processor and config versioning

    1. This has been implemented in the current version of the network map structure (id vs cfg for each processor)

3. Why is the typology_id not also a UUIDv4?

    1. This is now redundant with the new structure.

4. We should add attribute tags to the typology and the transaction nodes so that the CRSP can interrogate the transaction for those attributes and their values to determine if the typology is in scope for the evaluation.

    1. Reserved for future enhancement once we require additional logic processing from the CRSP for specific rules and typologies

5. The original Network Map contained a "transactions" array, which contained all the transaction types that we want to evaluate in Actio. The term "transaction" in this context creates some confusion with the transaction as the thing that facilitates the flow of funds and the message format as the thing that contains the information (structure and type) about the transaction.

    1. **2021/10/18**: The term “messages” will replace the term “transactions” in the Network Map.

## 3.2. Determine Channels

With the network map in hand, the CRSP interrogates the incoming transaction and determines which channels from the map are to be utilised for evaluating the transaction, based on the transaction’s message type.

Currently, all transactions are submitted to all channels and the only attribute from the transaction that is used to evaluate the channel is the message type (TxTp) (pain.001, pain.013, pacs.008 and pacs.002).

Increased granularity in the channels will be implemented once more typologies have been completed and we’ve decided how the channels for the MVP will be composed.

## 3.3. Determine Typologies

Once the channels have been determined, and for each channel in the evaluation scope, the CRSP determines which typologies to evaluate. The typologies are determines based on an evaluation of the contents of a transaction against the minimum access criteria of a typology, as defined in the network map. For example, if a typology relies on the presence of foreign currency exchange in the transaction, but there is no currency exchange present in the transaction, then the typology can be omitted from the evaluation scope.

Currently, since each channel will be in scope for the evaluation, it is not necessary for typologies to be present in multiple channels. In general, evaluating the same typology twice for a specific transaction is unnecessary and wasteful.

The set of rules that are executed to evaluate a typology are defined in the network map. The exact method for combining the rule results into a typology score is defined in the typology expression. The typology expression is an external configuration file that defines the rules for a typology, the translation of the rule results to a numerical value and the sum or “expression” that defines how the rule result scores are to be compiled into the typology score.

The typology expression can change over time as needs dictate. Rules may be removed, or new rules added; the rule result scores may be tweaked as part of a calibration process; the typology expression may be changed to redefine the calculation of the typology score. It is essential that the typology expression is properly versioned, and that the appropriate version is referenced in the network map.

The typology processor will likely remain unchanged for longer than the typology configurations that enable its execution, but the typology processor may be updated from time to time. Therefore the typology processor itself will have to be independently versioned from the typology expressions and the version of the typology processor employed for the incoming transaction will have to be referenced in the network map.

*Note for future feature enhancement (MVP scope):* Typologies must be tagged with the attributes that will determine if they are in scope for an evaluation, and the CRSP will have to evaluate these attributes when composing the evaluation scope via the network map.

## 3.4. Determine Rules

Each typology comprises a number of rules that are executed to support the calculation of the typology’s score. The typology score provides an indication of the measure of financial crime risk detected in the transaction.

The rules for a specific typology is generally static and rules are not currently expected to be eliminated for evaluation by the CRSP. In rare circumstances where the same typology would be executed with a different set of rules (e.g. one set of rules including Forex, and another set excluding Forex), the two typologies will be created as a completely separate typologies instead.

A single rule may be executed for multiple typologies (and even across multiple channels). Singular execution will minimise unnecessary system processing.

Each rule is parameterised through an external configuration file that contains information about the thresholds and evaluation bands within a rule. Rule parameters can change over time as rules are calibrated for improved detection capabilities. It is essential that the rule configuration is properly versioned, and that the appropriate version is referenced in the network map.

A rule processor will likely remain unchanged for longer than its config, but may also be updated periodically. Therefore the rule processor itself will have to be independently versioned from its rule config and the version of the rule processor employed for the incoming transaction will have to be referenced in the network map.

## 3.5. Prune the Network Map

Once the CRSP has determined which typologies and rules will be invoked for the incoming transaction, the CRSP will prune (remove) all the unwanted typologies (and their associated rules) from the network map. What will remain will be an abbreviated network map, or a network sub-map, that only contains the channels, typologies and rules that are in scope for the evaluation of the incoming transaction’s message type.

## 3.6. Deduplicate Rules

A single rule could be used to evaluate more than one typology. One of the primary advantages and reasons for the config-driven approach is to be able to minimise the number of times that a specific rule has to be executed. To achieve this objective, the CRSP will draft a list of all of the rules in the network sub-map and then eliminate duplicate rules from the list.

A rule in the network map can be uniquely described by the combination of the following attributes:

```
                                        "id": "003@1.0.0",
                                        "host": "http://openfaas:8080",
                                        "cfg": "1.0.0"
```

The CRSP must remove all duplicate rules for the unique combination of these fields to identify only one unique rules processor (and rule processor version and rule processor configuration version) to execute for the evaluation of the transaction.

![](../../../../Images/image-20210817-123535.png)

What the separated criteria for a rule processor’s uniqueness also means is that we could, in theory, execute the same rule processor with two different rule configurations, or even be able to override a rule’s configuration for a specific typology under specific circumstances. At the moment, this is not intended to be in scope for the MVP and will only be explored once transaction evaluation is calibrated over live data.

## 3.7. Evaluate Transaction

Using the list of unique rules from step 3.6, the CRSP invokes all of the unique rule processors and passes the transaction message and network sub-map to each rule processor for processing.

## 3.8. CRSP Response

The CRSP must send an HTTP response back to the service that invoked it, in this case the data preparation (NiFi) service, to communicate the successful completion of its work. The response message must include the outgoing payload as part of the response so that the automated testing can confirm that the functioning and outgoing message is correct.