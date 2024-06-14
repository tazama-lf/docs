# Create New Transaction

![](../../Images/image-20220902-104423.png)

About “Create Processor”:

A transaction in Tazama does not utilize a specific transaction “processor” the way that a rule utilizes a rule processor. A transaction is the root node in a Network Map. This means that the transaction attributes are evaluated by the CRSP and the CRSP then interrogates the Network Map to determine which typologies and rules are required to evaluate the transaction. The transaction routing and the evaluations by the rule and typology processors are then within the context of the transaction. The transaction is split amongst the channels, rules processors and typology processor and finally recombined by the Transaction Aggregation and Decisioning Processor to close off the evaluation of the transaction. (see: [Channel Aggregation and Decisioning Processor (CADProc)](../99-Archive/Channel-Aggregation-And-Decisioning-Processor-Cadproc.md) )

1. The transaction message will have a unique ID that relates to the transaction message type and is used to identify the specific TADProc that will be used to produce the transaction results.
2. Every message evaluated by Actio will be defined in the Network Map as the root of its own channel, typology and rule tree. This means that transactions are considered discrete and mutually exclusive in the design and while a rule, typology or a channel may be duplicated between transactions, the nett effect is that the evaluation process will behave as if the transaction we are evaluating is the only one that exists in the configuration.
3. The transaction will have a type. In ISO 20022, the type of a message, or more accurately the “MessageDefinitionIdentifier”, defines the Business Area, Message Identifier/Functionality, Variant and version of a particular message.
    1. We prefer to call this the transaction “type” rather than “identifier” to avoid confusion with the transaction ID. Actually, we should just be calling it the Message Definition Identifier.
    2. The message type is not actually explicitly part of the message data. In other words, the message does not explicitly self-identify. Sort of:
        1. XML:
            ```xml
            <?xml version="1.0" encoding="utf-8"?>
            <Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.11">
                <CstmrCdtTrfInitn>
            ```
        2. JSON (see: [https://www.iso20022.org/sites/default/files/documents/D7/ISO20022_API_JSON_Whitepaper_Final_20180129.pdf](https://www.iso20022.org/sites/default/files/documents/D7/ISO20022_API_JSON_Whitepaper_Final_20180129.pdf)):

            ```json
            {
              "$schema": "http://json-schema.org/draft-04/schema#",
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "@xmlns": {
                  "default": "urn:iso:std:iso:20022:tech:json:pain.001.001.11"
                },
                "account_details_confirmation": {
                  "$ref": "#/definitions/CustomerCreditTransferInitiationV11"
                }
              },
              "definitions": {
                "CustomerCreditTransferInitiationV11": {
            ```
    3. A message type identifier (TxTp) to an ISO message at ingestions for control and information purposes was added.
4. The transaction will need its own transaction configuration to define the processing of the transaction evaluation results, and in particular to trigger an alert based on the typologies scored during the process.

Now:

## Steps:

1. Create the transaction configuration (see: [Channel_Router_and_Setup_Processor_CRSP#3.1.-Read-Network-Map](../Channel-Router-And-Setup-Processor-CRSP.md#31-read-network-map))
    1. The transaction configuration must specify the transaction attributes that will direct the evaluation of the transaction to a specific typology (and, by association, the rules and the specific channel).
        1. Instead of reinventing the wheel, it may be worth considering an implementation of some kind of query language where we can parse statements that are linked to the transaction and map the result of the statement to a typology. We would need to know more about the rules and typologies and how these differ from transaction to transaction and attribute to attribute.
    2. If the transaction configuration is missing or empty the Channel Router and Setup Processor will route the transaction to all channels, their associated typologies and their associated rules.
2. Connect the transaction
    1. Update the Network Map (see: [Channel_Router_and_Setup_Processor_CRSP#3.1.-Read-Network-Map](../Channel-Router-And-Setup-Processor-CRSP.md#31-read-network-map))
        1. The new transaction must be added to the Network Map as a transaction object to which a channel (and then typologies, and ultimate also rules) can be linked. The new transaction will be located in the `transactions` object in the Network Map.
        2. The new transaction must be described in the network map with the following information:
            ```json
                            "id": "004@1.0.0",
                            "host": "https://gateway.openfaas:8080/function/off-transaction-aggregation-decisioning-processor-rel-1-1-0",
                            "cfg": "1.0.0",
                            "txTp": "pacs.002.001.12",
                            "channels": 
            ```

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
