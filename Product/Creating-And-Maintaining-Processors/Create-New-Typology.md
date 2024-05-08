# Create New Typology

- [Create New Typology](#create-new-typology)
- [Steps:](#steps)

![](../Images/image-20220902-103424.png)

About “Create Processor”:

The universal typology processor has already been developed and implemented in Tazama as a standard feature of the Tazama evaluation pipeline (see: [Typology Processing](../../../Product/05-Typology-Processing.md))

1. The typology processor will have a unique ID

2. The typology processor will have a unique version

3. *Future Enhancement*: Currently, the typology processor itself will be updated through a development and change control process to deploy new code. For the Network Map to completely control the routing of a transaction through the pipeline, the typology processor itself should be defined in the Network Map.

# Steps:

1. Create the typology configuration (see: [Typology Processing | 5.5. Read typology configuration](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/1740494/Typology+Processing#5.5.-Read-typology-configuration))
    1. The typology configuration will include the rule results scoring table: the result for each rule (or each set of the sub-rules), which will be either TRUE or FALSE, must be associated with an integer between 0 and 100
    2. The typology configuration will include the typology expression
        ![](../../Images/image-20210819-131055.png)
    3. If the rule processors for the typology are still to be deployed, the typology configuration could be missing or empty. When the typology processor is called on to execute the typology configuration, the typology processor will identify that no rules are in scope and no expression exists and then automatically complete the typology with a score of 0 (zero).
2. Connect the typology
    1. Prerequisite: The typology processor must exist and be deployed to the platform.
    2. Prerequisite: A typology must be associated with an existing channel. If the channel for a typology has not yet been created, the channel must be created before the typology can be connected. (There are cascading dependencies for the transaction definition to also exist, though this is a direct prerequisite for the channel.)
    3. *Future enhancement*: Update the channel configuration (see: [https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6324453/Channel+Aggregation+and+Decisioning+Processor+CADProc#6.4.-Read-channel-configuration](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6324453/Channel+Aggregation+and+Decisioning+Processor+CADProc#6.4.-Read-channel-configuration) )
        1. Optional: The typology may be added to the “proceed” set of typologies in the channel configuration, if “no action” typology result, combined with “no action” typology results from other typologies in the “proceed” set, would trigger a “proceed” instruction to the client system.
    4. Update the Network Map (see: [https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6520927/Channel+Router+and+Setup+Processor+CRSP#3.1.-Read-Network-Map](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6520927/Channel+Router+and+Setup+Processor+CRSP#3.1.-Read-Network-Map) )
        1. The new typology must be linked to the channel within which it is to be executed by adding the typology to the `transactions.channels.typologies` object under the channel in the Network Map.
        2. The new typology must be described in the network map with the following information:
            ```json
            "id": "028@1.0.0",
            "host": "https://gateway.openfaas:8080/function/off-typology-processor-rel-1-0-0",
            "cfg": "1.0.0",
            "rules": [
            ```
        3. **typology[].id** The typology.id @version should reflect the ID of the specific typology processor that will be invoked for this instance of the network map. There may, at some future point, be multiple typology processors active in an Tazama implementation for different scoring or monitoring schemes. Typology processors with arbitrarily different themes may then have a different ID, after which iterations or versions of a specific typology processor “theme” (hence, ID), will have separate version progression.  
            The specific typology that we want to evaluate in the specific version of the typology processor is the 028 part. So, for example, if I want to evaluate typology 028 in a different typology processor, the configuration will be slightly different:
            ```json
            "id": "028@2.0.0",
            "host": "https://gateway.openfaas:8080/function/off-typology-processor-rel-2-0-0",
            "cfg": "2.0.0",
            "rules": [
            ```
            **typology[].cfg** The configuration version relates to the typology being evaluated and not the typology processor doing the evaluation. A typology processor does not, currently, require any parameters for itself, but only parameters for the typology to be evaluated.
    5. Update the Transaction Configuration
        1. The new typology must be added to the transaction configuration to capture the typology thresholds for alerting.

**Typology config sample:**

```json
{
    "typology_name": "Sample",
    "id": "999@1.0.0",
    "cfg": "1.0.0",
    "rules": [
        {
            "id": "001@1.0.0",
            "cfg": "1.0.0",
            "ref": ".01",
            "true": "100",
            "false": "0"
        },
        {
            "id": "001@1.0.0",
            "cfg": "1.0.0",
            "ref": ".02",
            "true": "100",
            "false": "0"
        },
        {
            "id": "001@1.0.0",
            "cfg": "1.0.0",
            "ref": ".03",
            "true": "100",
            "false": "0"
        },
        {
            "id": "001@1.0.0",
            "cfg": "1.0.0",
            "ref": ".04",
            "true": "100",
            "false": "0"
        },
        {
            "id": "001@1.0.0",
            "cfg": "1.0.0",
            "ref": ".00",
            "true": "100",
            "false": "0"
        }
    ],
    "expression": {
        "operator": "+",
        "terms": [
            {
                "id": "001@1.0.0",
                "cfg": "1.0.0"
            }
        ]
    }
}

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
