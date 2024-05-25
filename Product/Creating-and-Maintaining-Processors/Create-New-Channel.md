# Create New Channel

- [Create New Channel](#create-new-channel)
- [Steps:](#steps)

![](../../Images/image-20220902-104055.png)

**About “Create Processor”:**

A channel in Actio does not utilise a specific channel “processor” the way that a rule utilises a rule processor. A channel is a virtual construct that is used to organise typologies into different themes or use cases. Channels are defined in the Network Map and “created” by the Channel Router and Setup Processor when an incoming transaction is routed to rule processors and typologies. A channel ceases to exist when the scoring of all its typologies are complete and it is closed off by the Channel Aggregation and Decisioning Processor. (see: [Channel Aggregation and Decisioning Processor (CADProc)](../../../Product/06-Channel-Aggregation-And-Decisioning-Processor-Cadproc.md) )

1. The channel will have a unique ID
2. Every evaluation pipeline will always have at least one channel
3. A channel may be defined under multiple transactions, though if we consider that the transaction (as the thing that we are evaluating) is the root of the network map, during the evaluation of a transaction there will only be a single “instance” of that channel during the transaction evaluation.
4. *Future enhancement*: The channel will also eventually need its own channel configuration (for “proceed” triggers) and the channel configuration and version will also have to be defined for the channel.

# Steps:

1. Create the channel configuration (see: [https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6324453/Channel+Aggregation+and+Decisioning+Processor+CADProc#6.4.-Read-channel-configuration](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6324453/Channel+Aggregation+and+Decisioning+Processor+CADProc#6.4.-Read-channel-configuration) )
    1. The channel configuration is only required if the channel is expected to trigger an interdiction, investigation or “proceed” instruction on the aggregated effect of a predefined collection of typologies. (This is out of scope for the MVP).
    2. The channel configuration will include the set of typologies and their thresholds for interdiction or investigation, as well as the workflow destination for each of the defined trigger actions.
    3. If the channel configuration is missing or empty the Channel Aggregation and Decisioning Processor will determine that no “proceed” typology sets are specified. The channel result will then always be: “Interdiction not configured.”
2. Connect the channel
    1. Prerequisite: A channel must be associated with a transaction. If the transaction for a channel has not yet been created, the transaction must be created before the channel can be connected.
    2. Update the Network Map (see: [https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6520927/Channel+Router+and+Setup+Processor+CRSP#3.1.-Read-Network-Map](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6520927/Channel+Router+and+Setup+Processor+CRSP#3.1.-Read-Network-Map) )
        1. The new channel must be linked to the transaction (or transactions) for which typologies within the channel is to be executed by adding the channel to the `transactions.channels` object under the transaction (or transactions) in the Network Map.
        2. The new channel must be described in the network map with the following information:
        ```json
                                "id": "001@1.0.0",
                                "host": "https://gateway.openfaas:8080/function/off-channel-aggregation-decisioning-processor-rel-1-1-0",
                                "cfg": "1.0.0",
                                "typologies": [
        ```
    3. Update the Transaction Configuration
        1. Typologies in the transaction configuration are presented in their channel context.

**Network map sample:**

```json
{
    "active": true,
    "messages": [
        {
            "id": "004@1.0.0",
            "host": "http://gateway.openfaas:8080/function/off-transaction-aggregation-decisioning-processor-rel-1-0-0",
            "cfg": "1.0.0",
            "txTp": "pacs.002.001.12",
            "channels": [
                {
                    "id": "001@1.0.0",
                    "host": "http://gateway.openfaas:8080/function/off-channel-aggregation-decisioning-processor-rel-1-0-0",
                    "cfg": "1.0.0",
                    "typologies": [
                        {
                            "id": "001@1.0.0",
                            "host": "http://gateway.openfaas:8080/function/off-typology-processor-rel-1-0-0",
                            "cfg": "1.0.0",
                            "rules": [
                                {
                                    "id": "002@1.0.0",
                                    "host": "http://gateway.openfaas:8080/function/off-rule-002-rel-1-0-0",
                                    "cfg": "1.0.0"
                                },
                                {
                                    "id": "016@1.0.0",
                                    "host": "http://gateway.openfaas:8080/function/off-rule-016-rel-1-0-0",
                                    "cfg": "1.0.0"
                                },
                                {
                                    "id": "017@1.0.0",
                                    "host": "http://gateway.openfaas:8080/function/off-rule-017-rel-1-0-0",
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


```

**Transaction configuration sample:**

```json
{
    "messages": [
        {
            "id": "004@1.0.0",
            "cfg": "1.0.0",
            "txTp": "pacs.002.001.12",
            "channels": [
                {
                    "id": "001@1.0.0",
                    "cfg": "1.0.0",
                    "typologies": [
                        {
                            "id": "001@1.0.0",
                            "cfg": "1.0.0",
                            "threshold": 500
                        },
                        {
                            "id": "002@1.0.0",
                            "cfg": "1.0.0",
                            "threshold": 200
                        },
                        {
                            "id": "003@1.0.0",
                            "cfg": "1.0.0",
                            "threshold": 350
                        }
                    ]
                }
            ]
        }
    ]
}

```
