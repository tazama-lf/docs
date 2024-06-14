# Create New Rule Processor

![](../../Images/image-20220902-101425.png)

# Steps:

1. Develop the rule processor module (see: [Rule Processing](../01-Getting-Started/01-Developer-Documentation/02-Documentation/04-Rule-Processing.md) )
    1. A rule processor will have a unique ID
    2. A rule processor will have a name
    3. A rule processor will have a brief description
    4. A rule processor will have a unique version

2. Create the rule processor configuration (see: [Rule+Processing#3.1.-Read-rule-config](../01-Getting-Started/01-Developer-Documentation/02-Documentation/04-Rule-Processing.md#31-Read-rule-config) )
    1. The rule processor configuration will share the rule processor’s unique ID
    2. The rule processor configuration will have its own, unique version
3. Connect the rule processor
    1. Prerequisite: A rule processor must be associated with an existing typology. If the typology for a rule processor has not yet been created, the typology must be created before the rule processor can be connected. (There are cascading dependencies for the channel and transactions to also exist, though these are direct prerequisites for the typology and channel, respectively.)
    2. Update the typology expression (see: [Typology Processing#5.5.-Read-typology-configuration](../Typology-Processing.md#55-read-typology-configuration) )
        1. The result for a rule (or each of the sub-rules), which will be either TRUE or FALSE, must be associated with an integer between 0 and 100
        2. The typology expression must be updated by adding the rule ID for the new rule to the expression
    3. Update the Network Map (see: [Channel+Router+and+Setup+Processor+CRSP#3.1.-Read-Network-Map](Channel+Router+and+Setup+Processor+CRSP#3.1.-Read-Network-Map) )
        1. The new rule must be linked to all typologies for which it is to be executed by adding the rule to the `transactions.channels.typologies.rules` objects under the channel in the Network Map.
        2. The new rule must be described in the network map with the following information:

```json
"id": "003@1.0.0",
"host": "http://gateway.openfaas:8080/function/off-rule-003-rel-1-1-0"
"cfg": "1.0.0",
```

**Config file**

```json
{
    "id": "002@1.0.0",
    "cfg": "1.0.0",
    "config": {
       "timeframes": [
            {
                "threshold": 86400000
            }
        ],
        "bands": [
            {
                "subRuleRef": ".01",
                "outcome": true,
                "reason": "Transaction convergence detected on debtor account"
            },
            {
                "subRuleRef": ".00",
                "outcome": false,
                "reason": "No Transaction convergence detected on debtor account"
            }
                ]
    }
  }
```

**Result sample:**

```json
{
    "transaction": { transaction stuff
    },
    "networkMap": { networkMap stuff
    },
    "ruleResult": {
        "id": "002@1.0.0",
        "cfg": "1.0.0",
        "subRuleRef": ".01",
        "result": true,
        "reason": "Transaction convergence detected on debtor account"
    }
}
```

**Network map sample:**

```json
{
    "networkMap": {
        "messages": [
            {
                "id": "001@1.0.0",
                "host": "https://gateway.openfaas:8080/function/off-transaction-aggregation-decisioning-processor-rel-1-1-0",
                "cfg": "1.0.0",
                "txTp": "pacs.002.001.12",
                "channels": [
                    {
                        "id": "001@1.0.0",
                        "host": "https://gateway.openfaas:8080/function/off-channel-aggregation-decisioning-processor-rel-1-1-0",
                        "cfg": "1.0.0",
                        "typologies": [
                            {
                                "id": "028@1.0.0",
                                "host": "https://gateway.openfaas:8080/function/off-typology-processor-rel-1-0-0",
                                "cfg": "1.0.0",
                                "rules": [
                                    {
                                        "id": "002@1.0.0",
                                        "host": "https://gateway.openfaas:8080/function/off-rule-002-rel-1-0-0",
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
}

```
