<!-- SPDX-License-Identifier: Apache-2.0 -->

<a id="top"></a>

# Guide for upstream and downstream integration into Tazama<!-- omit in toc -->

#### Table of Contents <!-- omit in toc -->

- [1.  Background](#1--background)
- [2. Message Ingestion](#2-message-ingestion)
- [3. Message Egress](#3-message-egress)
  - [3.1. Event-flow rule processor output](#31-event-flow-rule-processor-output)
  - [3.2. Typology processor output](#32-typology-processor-output)
  - [3.3	Transaction Aggregation and Decisioning processor (TADProc) output](#33transaction-aggregation-and-decisioning-processor-tadproc-output)

### 1.  Background

The Tazama Transaction Monitoring System is a rules-based forward-chaining inference engine that ingests transaction data as JSON-formatted ISO20022 messages and evaluates the data in real-time using a number of pre-built and configured rule processors for fraud and money-laundering behaviors. Rule results are summarized into fraud and money-laundering scenarios (known as typologies) and the system is able to block or flag transactions if typologies breach configured thresholds.

![tazama role](/images/tazama-role.png)

The core detection capability within the platform is distributed across 3 distinct steps in the end-to-end evaluation flow.

![tazama end to end flow](/images/tazama-flow.png)

Once data is ingested into the transaction history by the TMS API, the Event Director (ED) performs an initial "triage" step to determine if the transaction should be inspected by the platform, and in what way. Currently this is a very simple decision based on the transaction type only (i.e. pain.001, pain.013, pacs.008 and pacs.002), though we envisage that the decision-making here can be more complex in the future by inspecting attributes contained in the message. For now, the ED uses the transaction type to select the typologies that are to be evaluated and triggers the rules required by the typologies. The ED routing is configured via a network map that defines the hierarchy of typologies and rules.

Each rule processor that receives the trigger payload from the Event Director evaluates the transaction and the historical behavior of its participants according to its specification and configuration. Rule processors are driven by a combination of parameters and result specifications to determine only one of configurable set of related outcomes. The rule outcome is then submitted to the typology processor for scoring.

![tazama rule / typology](/images/tazama-config-rule-processor.drawio.svg)

The typology processor assigns a weighting to each rule outcome as it is received based on the rule's parent typologies' configurations. Once all the rule results for a specific typology have been received, the typology adds all the weighted scores together to form the typology score. The typology score can be evaluated against an "interdiction" threshold to determine if the client system should be instructed to block a transaction "in flight". The typology configuration also contains an investigation threshold that will trigger a review or investigation process at the end of the transaction evaluation.

Once these three steps are complete, the evaluation of the transaction is wrapped up in the Transaction Aggregation and Decisioning Processor where the results from typologies are aggregated and reviewed to determine if an investigation alert should be sent to the Case Management System. If any typology had breached either its investigation or interdiction threshold, the system will trigger an investigation alert for that transaction.

The Tazama system is provided as a software engine and as such is generally implemented as a back-end service that taps into transaction flows.

The purpose of this guide is to provide a brief introduction into the integration with the Tazama system. Tazama is a real-time transaction monitoring system that ingests transaction data from a transaction system in a JSON-based ISO20022 format, and then delivers evaluation results as one of a number of JSON documents, depending on where in the evaluation process the result originated.

For more detailed information on the Tazama product, please review the [Tazama overview](/readme.md) page.

<div style="text-align: right"><a href="#top">Top</a></div>

### 2. Message Ingestion

Tazama provides transaction monitoring “as-a-service” via its Transaction Monitoring Service (TMS) API. Transactions are submitted to Tazama and Tazama delivers an evaluation result in response. Transactions are submitted to the TMS API as JSON-formatted ISO20022 messages. At the moment, the system is capable of ingesting the following ISO20022 messages:
•	pain.001.001.11 (CustomerCreditTransferInitiationV11) - https://www.iso20022.org/standardsrepository/type/pain.001.001.11
•	pain.013.001.09 (CreditorPaymentActivationRequestV09) - https://www.iso20022.org/standardsrepository/type/pain.013.001.09
•	pacs.008.001.10 (FIToFICustomerCreditTransferV10) - https://www.iso20022.org/standardsrepository/type/pacs.008.001.10
•	pacs.002.001.12 (FIToFIPaymentStatusReportV12) - https://www.iso20022.org/standardsrepository/type/pacs.002.001.12


![tazama integration overview](/images/tazama-integration-overview.drawio.svg)

The payment initiation messages pain.001 and pain.013 are optional and not enabled by default. To enable the API to receive these messages, the following TMS API environment variable must be set prior to deployment:

```
QUOTING=true
```

The ISO20022 messages typically have a much larger number of fields than what Tazama needs and the TMS API only requires and validates the specific information that the evaluation of a message relies on. The additional information can be submitted, and will be persisted in the transaction history databases, but the additional fields will be ignored during the evaluation of a message.

The JSON format for each of the messages are defined in a series of TypeScript interface files located in the [Tazama frms-coe-lib code library](https://github.com/tazama-lf/frms-coe-lib/tree/main/src/interfaces)

The schemas for each of the messages as they are expected by the TMS API are defined [here](https://github.com/tazama-lf/tms-service/tree/main/src/schemas)

For a variety of reasons, a client system may not be able to submit messages to Tazama in the exact format it expects. To accommodate integration from other client systems without the need for changes to the Tazama API itself, Tazama recommends the use of the Payment Platform Adapter as preface to the TMS API. The intention of such a PPA would be to transform messages from the client system’s format to Tazama’s ISO20022 format.

Tazama developed a Payment Platform Adapter for [Mojaloop](http://mojaloop.io) which can be found [here](https://github.com/frmscoe/payment-platform-adapter)

The Mojaloop PPA is not currently in service, but is due to be updated for an upcoming Mojaloop implementation. While the code is somewhat stale, it gives some insight into the composition and functionality of a Tazama PPA.

<div style="text-align: right"><a href="#top">Top</a></div>

### 3. Message Egress

![tazama relay service](/images/tazama-integration-relay-service.drawio.svg)

Tazama delivers evaluation results directly out of various processors in its internal evaluation flow. Messages between internal processors are basically in JSON format, but are transmitted via protocol buffers from one processor to the next. As an evaluation is performed, each processor plane adds its own evaluation results to the message payload.

![tazama message payload](/images/tazama-integration-output.drawio.svg)

Rule processor results are appended directly to the message, but are then combined and nested under typology results by the typology processor to deliver the typology result. The typology results are then combined and nested under the final evaluation result into a report.

Evaluation results are delivered immediately when an evaluation decision is clear to deliver results as soon as possible. In other words, if we know the transaction should be blocked based on an operational condition, or if a typology threshold is breached, the result is delivered immediately without waiting for the evaluation of the entire transaction to be completed first. Because of the focus on immediate egress and depending on where in the flow a result is delivered, the result will only contain the information that was available at the time of the result's determination. In other words, when a rule processor delivers a result, there is no typology information yet, and if one typology threshold is breached, no information about adjacent typologies will be available yet either. 

The only processor that is capable of delivering a complete evaluation result is the Transaction Aggregation and Decisioning Processor (TADProc) which will generate the alert that goes to the Case Management System.

Tazama implements message relay from the system to external systems via a series of discrete point-to-point relay services. Each relay service is tasked to monitor a specific NATS subject and as soon as messages are posted to the subject, the message is relayed to the destination configured for that relay service.

Relay service configuration is established at deployment through the relay service environment file. The user can deploy a relay service for one of three different types of destinations: NATS (the existing native Tazama interservice pub/sub mechanism), REST (unauthenticated) and RabbitMQ. The user can also choose to propagate the relayed message as a serialized JSON object, or unserialized via protocol buffers. Either way, the target system must then have some kind of mechanism to receive and interpret the relayed message.

The relay service and its configuration is documented in detail [here](
https://github.com/tazama-lf/relay-service)

<div style="text-align: right"><a href="#top">Top</a></div>

#### 3.1. Event-flow rule processor output

Tazama 2.1.0 introduced the Event-Flow Rule Processor (EFRuP) as a new component of the system. The EFRuP evaluates the participants of a transaction against a number of conditions to determine if the transaction should be blocked based on conditions that had been imposed on the debtor, creditor, or their accounts. The blocking instruction is submitted to the "interdiction" relay service and contains the result of the EFRuP as a rule processor, for example:

Each message will contain a "transaction" object that records the message that was sent to Tazama and subsequently triggered an evaluation. Not all messages are evaluated; only messages where the "TxTp" value is represented in the network map will be evaluated - messages with an unlisted value will be ignored for evaluation purposes, though they will still be ingested as transaction history.

The contents of the transaction object is an exact copy of the ingested message, with the transaction type ("TxTp") appended by the TMS API based on which TMS API endpoint was used to submit the message.

```JSON
{
  "transaction": {
    "TxTp": "pacs.002.001.12",
    "FIToFIPmtSts": {
      "GrpHdr": {
        "MsgId": "f8b8...",
        "CreDtTm": "2025-01-14T05:52:31.244Z"
      },
      "TxInfAndSts": {
        "OrgnlInstrId": "5ab4...",
        "OrgnlEndToEndId": "ceef...",
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
                  "MmbId": "fsp001"
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
                  "MmbId": "fsp001"
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
                  "MmbId": "fsp002"
                }
              }
            }
          }
        ],
        "AccptncDtTm": "2023-06-02T07:52:31.000Z",
        "InstgAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "fsp001"
            }
          }
        },
        "InstdAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "fsp002"
            }
          }
        }
      }
    }
  },
```
The "networkMap" object is appended by the event director and records the route that was defined for the transaction type ("TxTp") in the message.

This routing information records all the typologies and their associated rules that will be used to evaluate the message, along with the specific processor and configuration versions that must be used.

In this example, we see that there will be a single typology (999) with configuration version 1.0.0 executed by the typology processor version 1.0.0 and the typology will receive rule results from two rule processors: EFRuP version 1.0.0 and 901 version 1.0.0 and configuration version 1.0.0. (The EFRuP does not require external configuration at this time.)

```JSON
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
            "cfg": "999@1.0.0",
            "rules": [
              {
                "id": "EFRuP@1.0.0",
                "cfg": "none"
              },
              {
                "id": "901@1.0.0",
                "cfg": "1.0.0"
              }
            ]
          }
        ]
      }
    ]
  },
```
The "DataCache" object is a caching object appended by the TMS API's data transformation service and records information from earlier messages (such as a pacs.008) that are linked to the current message (typically through a common "EndToEndId"). The contents of the data cache is used by rule processors to retrieve commonly required information related to preceding messages without having to fetch it from the database and impeding performance.

```JSON
  "DataCache": {
    "dbtrId": "dbtr_...",
    "cdtrId": "cdtr_...",
    "cdtrAcctId": "cdtrAcct_...",
    "dbtrAcctId": "dbtrAcct_...",
    "instdAmt": {
      "amt": 566.18,
      "ccy": "XTS"
    },
    "intrBkSttlmAmt": {
      "amt": 566.18,
      "ccy": "XTS"
    },
    "xchgRate": 1,
    "creDtTm": "2025-01-14T05:47:31.244Z"
  },
```
The "metaData" object contains the turn-around times for preceding processors and is used for performance monitoring.

```JSON
  "metaData": {
    "prcgTmDP": 6892128,
    "prcgTmED": 1462670
  },
```
The "ruleResult" object contains the result of the Event Flow Rule Processor's evaluation of the participants against conditions linked to the participants. In this case, one of the participants, or their accounts, have been blocked from transacting. The cause of the block will have to be retrieved by a case management system by polling the admin API.

More detailed information about the Event Flow Rule Processor can be found [here](
https://github.com/tazama-lf/event-flow) and [here](https://github.com/tazama-lf/docs/blob/main/Product/event-flow-rule-processor.md)

<div style="text-align: right"><a href="#top">Top</a></div>

#### 3.2. Typology processor output

The typology processor combines the results from the rule processors into a number of configured typologies, or scenarios, that are intended to give a client system or investigator some insight into why a particular transaction was flagged as suspicious.
The typology processor performs its work over three steps when receiving each rule result from a rule processor:
1.	Assign a weighted score to the rule result based on a typology configuration
2.	When all the rule results are received, calculate a typology score as a sum of all the weighted rule results, according to the typology configuration
3.	Evaluated the typology score against the thresholds defined in the typology configuration

![tazama rule and typology processors](/images/tazama-integration-rule-typology.drawio.svg)

When the typology processor calculates a score that breaches the interdiction threshold defined for that typology, the typology processor will immediately raise an interdiction against the transaction to instruct the transaction system to block the transaction. As with the EFRuP "blocking" instruction, the interdiction instruction is submitted to the "interdiction" relay service and contains the typology processor result for that typology, for example:

Each message will contain a "transaction" object that records the message that was sent to Tazama and subsequently triggered an evaluation. Not all messages are evaluated; only messages where the "TxTp" value is represented in the network map will be evaluated - messages with an unlisted value will be ignored for evaluation purposes, though they will still be ingested as transaction history.

The contents of the transaction object is an exact copy of the ingested message, with the transaction type ("TxTp") appended by the TMS API based on which TMS API endpoint was used to submit the message.

```JSON
{
  "transaction": {
    "TxTp": "pacs.002.001.12",
    "FIToFIPmtSts": {
      "GrpHdr": {
        "MsgId": "f8b8...",
        "CreDtTm": "2025-01-14T05:52:31.244Z"
      },
      "TxInfAndSts": {
        "OrgnlInstrId": "5ab4...",
        "OrgnlEndToEndId": "ceef...",
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
                  "MmbId": "fsp001"
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
                  "MmbId": "fsp001"
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
                  "MmbId": "fsp002"
                }
              }
            }
          }
        ],
        "AccptncDtTm": "2023-06-02T07:52:31.000Z",
        "InstgAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "fsp001"
            }
          }
        },
        "InstdAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "fsp002"
            }
          }
        }
      }
    }
  },
```
The "networkMap" object is appended by the event director and records the route that was defined for the transaction type ("TxTp") in the message.

This routing information records all the typologies and their associated rules that will be used to evaluate the message, along with the specific processor and configuration versions that must be used.

In this example, we see that there will be a single typology (999) with configuration version 1.0.0 executed by the typology processor version 1.0.0 and the typology will receive rule results from two rule processors: EFRuP version 1.0.0 and 901 version 1.0.0 and configuration version 1.0.0. (The EFRuP does not require external configuration at this time.)

```JSON
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
            "cfg": "999@1.0.0",
            "rules": [
              {
                "id": "EFRuP@1.0.0",
                "cfg": "none"
              },
              {
                "id": "901@1.0.0",
                "cfg": "1.0.0"
              }
            ]
          }
        ]
      }
    ]
  },
```
The "DataCache" object is a caching object appended by the TMS API’s data transformation service and records information from earlier messages (such as a pacs.008) that are linked to the current message (typically through a common "EndToEndId"). The contents of the data cache is used by rule processors to retrieve commonly required information related to preceding messages without having to fetch it from the database and impeding performance.

```JSON
"DataCache": {
    "dbtrId": "dbtr_...",
    "cdtrId": "cdtr_...",
    "cdtrAcctId": "cdtrAcct_...",
    "dbtrAcctId": "dbtrAcct_...",
    "instdAmt": {
      "amt": 566.18,
      "ccy": "XTS"
    },
    "intrBkSttlmAmt": {
      "amt": 566.18,
      "ccy": "XTS"
    },
    "xchgRate": 1,
    "creDtTm": "2025-01-14T05:47:31.244Z"
  },
```
The "metaData" object contains the turn-around times for preceding processors and is used for performance monitoring.

```JSON
  "metaData": {
    "prcgTmDP": 6892128,
    "prcgTmED": 1462670
  },
```
The "typologyResult" object contains the result of the Typology Processor's evaluation of the transaction. The typology result provides all the information required to determine why the typology breached the threshold, including the individual rule results and their associated weighted scores (you can see rule 901 accumulated a score of 400 for the result indicated by the sub-rule reference of ".03"), the total typology score (400), and the various thresholds set for the typology. This typology generated an interdiction because the total typology score was greater or equal to the configured interdiction threshold value of 400.

The typology description is not included in the result and must be read from the typology configuration in the configuration database, or an equivalent list of values in the case management system.

The "review" flag (true in this case) indicates that the result will also be sent to the case management system by the TADProc for review.

```JSON
  "typologyResult": {
    "id": "typology-processor@1.0.0",
    "cfg": "999@1.0.0",
    "result": 400,
    "ruleResults": [
      {
        "id": "EFRuP@1.0.0",
        "cfg": "none",
        "subRuleRef": "none",
        "prcgTm": 412705,
        "wght": 0
      },
      {
        "id": "901@1.0.0",
        "cfg": "1.0.0",
        "subRuleRef": ".03",
        "prcgTm": 1479181,
        "wght": 400
      }
    ],
    "prcgTm": 1437831,
    "review": true,
    "workflow": {
      "alertThreshold": 200,
      "interdictionThreshold": 400,
      "flowProcessor": "EFRuP@1.0.0"
    }
  }
```

More detailed information about the Typology Processor can be found [here](https://github.com/tazama-lf/typology-processor) and [here](https://github.com/tazama-lf/docs#34-typology-processor)

<div style="text-align: right"><a href="#top">Top</a></div>

#### 3.3	Transaction Aggregation and Decisioning processor (TADProc) output

The TADProc combines the results from all typologies into a final transaction evaluation result. If any of the typologies in the evaluation breached their thresholds, or if there had been any override conditions specified that suppressed the typology processor behaviour, the TADProc will generate an investigation alert that will be routed to a case management system.

An alert instruction is submitted to the "cms" relay service and contains the complete evaluation result for the submitted transaction, for example:

Each message will contain a "transaction" object that records the message that was sent to Tazama and subsequently triggered an evaluation. Not all messages are evaluated; only messages where the "TxTp" value is represented in the network map will be evaluated - messages with an unlisted value will be ignored for evaluation purposes, though they will still be ingested as transaction history.

The contents of the transaction object is an exact copy of the ingested message, with the transaction type ("TxTp") appended by the TMS API based on which TMS API endpoint was used to submit the message.

```JSON
{
  "transaction": {
    "TxTp": "pacs.002.001.12",
    "FIToFIPmtSts": {
      "GrpHdr": {
        "MsgId": "f8b8...",
        "CreDtTm": "2025-01-14T05:52:31.244Z"
      },
      "TxInfAndSts": {
        "OrgnlInstrId": "5ab4...",
        "OrgnlEndToEndId": "ceef...",
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
                  "MmbId": "fsp001"
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
                  "MmbId": "fsp001"
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
                  "MmbId": "fsp002"
                }
              }
            }
          }
        ],
        "AccptncDtTm": "2023-06-02T07:52:31.000Z",
        "InstgAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "fsp001"
            }
          }
        },
        "InstdAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "fsp002"
            }
          }
        }
      }
    }
  },
```
The "networkMap" object is appended by the event director and records the route that was defined for the transaction type ("TxTp") in the message.

This routing information records all the typologies and their associated rules that will be used to evaluate the message, along with the specific processor and configuration versions that must be used.

In this example, we see that there will be a single typology (999) with configuration version 1.0.0 executed by the typology processor version 1.0.0 and the typology will receive rule results from two rule processors: EFRuP version 1.0.0 and 901 version 1.0.0 and configuration version 1.0.0. (The EFRuP does not require external configuration at this time.)

```JSON
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
            "cfg": "999@1.0.0",
            "rules": [
              {
                "id": "EFRuP@1.0.0",
                "cfg": "none"
              },
              {
                "id": "901@1.0.0",
                "cfg": "1.0.0"
              }
            ]
          }
        ]
      }
    ]
  },
```
The "DataCache" object is a caching object appended by the TMS API's data transformation service and records information from earlier messages (such as a pacs.008) that are linked to the current message (typically through a common "EndToEndId"). The contents of the data cache is used by rule processors to retrieve commonly required information related to preceding messages without having to fetch it from the database and impeding performance.

```JSON
"DataCache": {
    "dbtrId": "dbtr_...",
    "cdtrId": "cdtr_...",
    "cdtrAcctId": "cdtrAcct_...",
    "dbtrAcctId": "dbtrAcct_...",
    "instdAmt": {
      "amt": 566.18,
      "ccy": "XTS"
    },
    "intrBkSttlmAmt": {
      "amt": 566.18,
      "ccy": "XTS"
    },
    "xchgRate": 1,
    "creDtTm": "2025-01-14T05:47:31.244Z"
  },
```
The "metaData" object contains the turn-around times for preceding processors and is used for performance monitoring.

```JSON
"metaData": {
    "prcgTmDP": 6892128,
    "prcgTmED": 1462670
  },
```
The "report" object contains the result of the complete evaluation of the transaction. The report provides all the information required to determine why the transaction was deemed suspicious, including the individual typology results. Each typology contains a "review" flag that, if true, indicates that the specific typology identified suspicious behaviour or that the event flow processor outcome resulted in a different outcome (block or override) to normal processing

If the "status" of the report is "ALRT" (alert) then the TADProc will send the report to the case management system.

If the "status" of the report is "NALT" (no alert) then the TADProc will not send a report to the case management system.

```JSON
  "report": {
    "evaluationID": "d643...",
    "metaData": {
      "prcgTmDP": 3234241,
      "prcgTmED": 70686
    },
    "status": "ALRT",
    "timestamp": {},
    "tadpResult": {
      "id": "004@1.0.0",
      "cfg": "1.0.0",
      "prcgTm": 1936516,
      "typologyResult": [
        {
          "id": "typology-processor@1.0.0",
          "cfg": "999@1.0.0",
          "result": 200,
          "ruleResults": [
            {
              "id": "EFRuP@1.0.0",
              "cfg": "none",
              "subRuleRef": "none",
              "prcgTm": 499791,
              "wght": 0
            },
            {
              "id": "901@1.0.0",
              "cfg": "1.0.0",
              "subRuleRef": ".02",
              "prcgTm": 2185855,
              "wght": 200
            }
          ],
          "prcgTm": 1283670,
          "review": true,
          "workflow": {
            "alertThreshold": 200,
            "interdictionThreshold": 400,
            "flowProcessor": "EFRuP@1.0.0"
          }
        }
      ]
    }
  }
```

More detailed information about the TADProc can be found [here](https://github.com/tazama-lf/transaction-aggregation-decisioning-processor) and [here](https://github.com/tazama-lf/docs?tab=readme-ov-file#35-transaction-aggregation-and-decisioning-processor-tadproc)

<div style="text-align: right"><a href="#top">Top</a></div>
