<!-- SPDX-License-Identifier: Apache-2.0 -->

# Processor results propagation

- [Processor results propagation](#processor-results-propagation)
  - [Processor results sequence diagram](#processor-results-sequence-diagram)
  - [Processor results flow](#processor-results-flow)
  - [Processor results formatting](#processor-results-formatting)
    - [Rule processor results](#rule-processor-results)
    - [Typology processor results](#typology-processor-results)
    - [CADProc results](#cadproc-results)
    - [TADProc results](#tadproc-results)
  - [Sample TADProc result](#sample-tadproc-result)

## Processor results sequence diagram

Array of rule evaluation results
```mermaid
%%{init: {'themeVariables': {'backgroundColor': '#ffffff', 'nodeBorder': 'none', 'mainBkg': '#ffffff', 'lineColor': '#000000', 'borderWidth': '2px', 'arrowheadSize': '1em'}}}%%
sequenceDiagram
    participant rules as "Rules Processor"
    participant typologies as "Typology Processors"
    participant tadp as "Transaction Aggregation & Decisioning Processor"
    participant cms as "Case Management"

    activate rules
    rules ->> rules: Execute rule
    rules ->> typologies: Submit rule result
    Note left of rules: Rule results include:<br/>* Original transaction data<br/>* Network sub-map<br/>* Rule evaluation results<br/>** Rule processor identifier<br/>** Rule configuration version<br/>** Sub-rule reference<br/>** Rule result<br/>** Rule processing time
    deactivate rules

    activate typologies
    typologies ->> typologies: Collect rule results
    typologies ->> typologies: Calculate typology score
    typologies ->> tadp: Submit typology result
    Note left of typologies: Typology results include:<br/>* Original transaction data<br/>* Network sub-map<br/>* Typology scoring results<br/>** Typology processor identifier<br/>** Typology identifier (configuration)<br/>** Typology score<br/>** Typology alert threshold<br/>** Typology interdiction threshold<br/>** Typology processing time<br/>** Array of rule evaluation results<br/>*** Rule processor identifier<br/>*** Rule configuration version<br/>*** Sub-rule reference<br/>*** Rule result<br/>*** Rule processing time<br/>*** Rule weighting
    deactivate typologies

    activate tadp
    tadp ->> tadp: Collect typology results
    tadp ->> tadp: Collect typology results
    tadp ->> tadp: Determine alert status
    tadp ->> cms: Submit transaction result
    Note left of tadp: Transaction results include:<br/>* Transaction (alert) id<br/>* Original transaction data<br/>* Network sub-map<br/>* Transaction evaluation results<br/>** Evaluation identifier<br/>** Evaluation status<br/>** Evaluation timestamp<br/>** Evaluation processing time<br/>** Transaction evaluation result<br/>*** Array of typology evaluation results<br/>**** Array of rule evaluation results
    deactivate tadp
    activate cms
    deactivate cms
```

1. Each rule processor delivers its results to the Typology Processor.
2. The typology processor aggregates the results from a number of rules associated with a specific typology into a typology result.
4. The Transaction Aggregation & Decisioning Processor (TADProc) will aggregate the results from all the typologies associated with a specific transaction into a final result.
5. The network map contains the overall structure and relationship between the transaction, typologies and rules.
6. The structure of the results maps exactly to the network map. The specific processor id, including the version, as well as the specific config version that was used to execute a processor is included in the processor results to account for situations where the same processor may be called with different versions or configurations to evaluate a transaction.

## Processor results flow

![](../images/image-20211124-135720.png)

1. As a transaction progresses through the evaluation pipeline, the results from each processor should be wrapped around the results from a previous processor:
2. ruleResults {} are issued from a rule processor
3. In the typology processor, the ruleResults are wrapped inside the typology results:  
    typologyResults {ruleResults[1..n]}
4. Finally, in TADProc, the typology results wrapped inside the transaction results:  
    transactionResults {typologyResults[1..n] {ruleResults[1..n]}}

## Processor results formatting

### Rule processor results

All rule processor results must contain the following information:

Original transaction +

Network map +

“ruleResult”:

```json
                            {
                                "id": "002@1.0.0",
                                "cfg": "1.0.0",
                                "subRuleRef": ".01",
                                "reason": "Debtor received < 10 transactions within the last 72 hours"
                            }
```

| **Field** | **Source** | **Example** |
| --- | --- | --- |
| ruleResult.id | Rule ID from networkMap.messages[0].typologies[0].rule[0].id including the “@version” part. | 028@1.0.0 |
| ruleResult.cfg | Rule config version from networkMap.messages[0].typologies[0].rule[0].cfg | 1.0.0 |
| ruleResult.subRuleRef | The specific sub-rule reference for the rule result based on the execution of the rule processor. | .01 |
| ruleResult.reason | The descriptive reason for the rule result based on the execution of the rule processor. | Debtor received < 10 transactions within the last 72 hours |

### Typology processor results

All typology processor results must contain the following information:

Original transaction +

Network map +

“typologyResult”:

```json
                    {
                        "id": "001@1.0.0",
                        "cfg": "1.0.0",
                        "result": 600,
                        "ruleResults": [
                            {
                                "id": "002@1.0.0",
                                "cfg": "1.0.0",
                                "subRuleRef": ".01",
                                "reason": "Debtor received < 10 transactions within the last 72 hours"
                            },
                            {
                                "id": "016@1.0.0",
                                "cfg": "1.0.0",
                                "subRuleRef": ".01",
                                "reason": "Creditor received >= 10 transactions within the last 24 hours"
                            },
                            {
                                "id": "026@1.0.0",
                                "cfg": "1.0.0",
                                "subRuleRef": ".01",
                                "reason": "Accumulation and rapid disbursement detected in debtor account"
                            },
                            {
                                "id": "044@1.0.0",
                                "cfg": "1.0.0",
                                "subRuleRef": ".01",
                                "reason": "No prior successful and complete outgoing transactions from the debtor found"
                            },
                            {
                                "id": "048@1.0.0",
                                "cfg": "1.0.0",
                                "subRuleRef": ".01",
                                "reason": "Transaction amount >= 1 but less then 2 standard deviations from historical maximum"
                            }
                        ]
                    }
```

| **Field** | **Source** | **Example** |
| --- | --- | --- |
| typologyResult.id | Typology ID from networkMap.messages[0].typologies[0].id including the “@version” part. | 028@1.0.0 |
| typologyResult.cfg | Typology config version from networkMap.messages[0].typologies[0].cfg | 1.0.0 |
| typologyResult.result | Typology score calculated by the typology processor based on the rule results and typology configuration information. | 500 |
| typologyResult.threshold | Note: The typology processor only retrieves the typology threshold information from the typology configuration if the platform is configured to interdict a transaction from the typology processor.<br><br>If the platform is not configured to interdict a transaction from the typology processor, this value will only be read from the transaction configuration by the TADProc.<br><br>The typology processor must only add this field to the output if the platform is configured for interdiction and then set the value to the threshold read from the typology configuration file. If the platform is not configured for interdiction, this value must be omitted. | 500 |
| typologyResult.ruleResults | Collection of ruleResult objects submitted by rule processors | [ruleResult](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/1741435/Processor+results+propagation#Rule-processor-results) |

### TADProc results

All TADProc results must contain the following information:

Original transaction +

Network map +

“transactionResult”:

```json
{
    "resultId": "cbd3b57a-e659-4e54-8b45-36fbd56cd50c",
    "dateTime": "2021-12-02T12:45:57.000Z",
    "id": "004@1.0.0",
    "cfg": "1.0.0",
    "status": "ALRT",
    "description": "Alert triggered",
    "typologyResults": [
        {
            "id": "001@1.0.0",
            "cfg": "1.0.0",
            "result": 600,
            "threshold": 400,
            "ruleResults": [
                {
                    "id": "002@1.0.0",
                    "cfg": "1.0.0",
                    "subRuleRef": ".01",
                    "reason": "Debtor received < 10 transactions within the last 72 hours"
                },
                {
                    "id": "016@1.0.0",
                    "cfg": "1.0.0",
                    "subRuleRef": ".01",
                    "reason": "Creditor received >= 10 transactions within the last 24 hours"
                },
                {
                    "id": "026@1.0.0",
                    "cfg": "1.0.0",
                    "subRuleRef": ".01",
                    "reason": "Accumulation and rapid disbursement detected in debtor account"
                },
                {
                    "id": "044@1.0.0",
                    "cfg": "1.0.0",
                    "subRuleRef": ".01",
                    "reason": "No prior successful and complete outgoing transactions from the debtor found"
                },
                {
                    "id": "048@1.0.0",
                    "cfg": "1.0.0",
                    "subRuleRef": ".01",
                    "reason": "Transaction amount >= 1 but less then 2 standard deviations from historical maximum"
                }
            ]
        },
        {
            "id": "002@1.0.0",
            "cfg": "1.0.0",
            "result": 700,
            "threshold": 400,
            "ruleResults": [
                {
                    "id": "001@1.0.0",
                    "cfg": "1.0.0",
                    "subRuleRef": ".01",
                    "reason": "The derived creditor account age is less than 1 day"
                },
                {
                    "id": "016@1.0.0",
                    "cfg": "1.0.0",
                    "subRuleRef": ".01",
                    "reason": "Creditor received >= 10 transactions within the last 24 hours"
                },
                {
                    "id": "026@1.0.0",
                    "cfg": "1.0.0",
                    "subRuleRef": ".01",
                    "reason": "Accumulation and rapid disbursement detected in debtor account"
                },
                {
                    "id": "044@1.0.0",
                    "cfg": "1.0.0",
                    "subRuleRef": ".01",
                    "reason": "No prior successful and complete outgoing transactions from the debtor found"
                },
                {
                    "id": "045@1.0.0",
                    "cfg": "1.0.0",
                    "subRuleRef": ".01",
                    "reason": "First recorded successful and complete incoming transaction received by the creditor"
                }
            ]
        }
    ]
}
```

| **Field** | **Source** | **Example** |
| --- | --- | --- |
| transactionResult.resultId | Auto-generated UUIDv4 to identify the transaction result to down-stream applications | b5ef6a1d-59cd-4b95-87b0-45bee27224dd |
| transactionResult.dateTime | The time at which the result was completed | 2021-12-02T12:45:57.000Z |
| transactionResult.id | Message ID from networkMap.messages[0].id including the “@version” part. | 001@1.0.0 |
| transactionResult.cfg | Transaction configuration from networkMap.messages[0].cfg | 1.0.0 |
| transactionResult.status | If any typology had breached their threshold, the value is “ALRT”.<br><br>If no typology had breached their threshold, the value is “NALT”. | ALRT |
| transactionResult.description | Description related to the status:<br><br>ALRT - Alert triggered<br><br>NALT - No alert triggered | Alert triggered |
| transactionResult.typologyResults[i].threshold | The typology alert trigger threshold is read from the transaction configuration file for each typology and recorded against the typology result to which the threshold applies. | 500 |

## Sample TADProc result

<details>
  <summary>
    Sample TADProc result
  </summary>
  
```json
{
  "transactionID": "e90e20c349f74653877b8d034f2b2c9c",
  "transaction": {
    "TxTp": "pacs.002.001.12",
    "FIToFIPmtSts": {
      "GrpHdr": {
        "MsgId": "e90e20c349f74653877b8d034f2b2c9c",
        "CreDtTm": "2024-05-25T09:48:41.124Z"
      },
      "TxInfAndSts": {
        "OrgnlInstrId": "5ab4fc7355de4ef8a75b78b00a681ed2",
        "OrgnlEndToEndId": "9a94e27c779a43be8b1f28266ed04c5b",
        "TxSts": "ACCC",
        "ChrgsInf": [
          {
            "Amt": {
              "Amt": 0,
              "Ccy": "USD"
            },
            "Agt": {
              "FinInstnId": {
                "ClrSysMmbId": {
                  "MmbId": "dfsp001"
                }
              }
            }
          },
          {
            "Amt": {
              "Amt": 0,
              "Ccy": "USD"
            },
            "Agt": {
              "FinInstnId": {
                "ClrSysMmbId": {
                  "MmbId": "dfsp001"
                }
              }
            }
          },
          {
            "Amt": {
              "Amt": 0,
              "Ccy": "USD"
            },
            "Agt": {
              "FinInstnId": {
                "ClrSysMmbId": {
                  "MmbId": "dfsp002"
                }
              }
            }
          }
        ],
        "AccptncDtTm": "2023-06-02T07:52:31.000Z",
        "InstgAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "dfsp001"
            }
          }
        },
        "InstdAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "dfsp002"
            }
          }
        }
      }
    }
  },
  "networkMap": {
    "active": true,
    "cfg": "1.0.0",
    "messages": [
      {
        "id": "004@1.0.0",
        "cfg": "1.0.0",
        "txTp": "pacs.002.001.12",
        "typologies": [
          {
            "id": "typology-processor@1.0.0",
            "cfg": "002@1.0.0",
            "rules": [
              {
                "id": "002@1.0.0",
                "cfg": "1.0.0"
              },
              {
                "id": "010@1.0.0",
                "cfg": "1.0.0"
              }
            ]
          },
          {
            "id": "typology-processor@1.0.0",
            "cfg": "005@1.0.0",
            "rules": [
              {
                "id": "002@1.0.0",
                "cfg": "1.0.0"
              },
              {
                "id": "016@1.0.0",
                "cfg": "1.0.0"
              }
            ]
          }
        ]
      }
    ]
  },
  "report": {
    "evaluationID": "c69f9ce4-ba1f-4678-b93e-a411d14c5751",
    "metaData": {
      "prcgTmDP": 9138582,
      "traceParent": "00-01e287731b1f502d8100d16d57d54b0b-fd901109d06d18ee-01",
      "prcgTmED": 4300035
    },
    "status": "NALT",
    "timestamp": "2024-05-25T09:48:48.723Z",
    "tadpResult": {
      "id": "004@1.0.0",
      "cfg": "1.0.0",
      "typologyResult": [
        {
          "id": "typology-processor@1.0.0",
          "cfg": "002@1.0.0",
          "result": 0,
          "ruleResults": [
            {
              "id": "002@1.0.0",
              "cfg": "1.0.0",
              "subRuleRef": ".x01",
              "result": false,
              "prcgTm": 28308495,
              "wght": 0
            },
            {
              "id": "010@1.0.0",
              "cfg": "1.0.0",
              "subRuleRef": ".x01",
              "result": false,
              "prcgTm": 29160829,
              "wght": 0
            }
          ],
          "prcgTm": 54304231,
          "review": false,
          "workflow": {
            "alertThreshold": 400,
            "interdictionThreshold": 500
          }
        },
        {
          "id": "typology-processor@1.0.0",
          "cfg": "005@1.0.0",
          "result": 0,
          "ruleResults": [
            {
              "id": "002@1.0.0",
              "cfg": "1.0.0",
              "subRuleRef": ".x01",
              "result": false,
              "prcgTm": 19949903,
              "wght": 0
            },
            {
              "id": "016@1.0.0",
              "cfg": "1.0.0",
              "subRuleRef": ".x01",
              "result": false,
              "prcgTm": 29160829,
              "wght": 0
            }
          ],
          "prcgTm": 5639186,
          "review": false,
          "workflow": {
            "alertThreshold": 600
          }
        }
      ],
      "prcgTm": 23603253
    }
  }
}
```
</details>
