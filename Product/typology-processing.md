<!-- SPDX-License-Identifier: Apache-2.0 -->

# Typology Processing <!-- omit in toc -->

- [Introduction](#introduction)
- [Typology Processor Context](#typology-processor-context)
  - [4. Submit rule results](#4-submit-rule-results)
  - [5.1. Determine beneficiary typologies](#51-determine-beneficiary-typologies)
  - [5.2. Determine all rules](#52-determine-all-rules)
  - [5.3.1 Fetch rule results](#531-fetch-rule-results)
  - [5.3.2. Check rule completion](#532-check-rule-completion)
  - [5.4. Append rule result](#54-append-rule-result)
  - [5.5. Read typology configuration](#55-read-typology-configuration)
      - [5.5.1. The Typology Configuration](#551-the-typology-configuration)
  - [5.6. Calculate typology score](#56-calculate-typology-score)
  - [5.7. Submit typology results](#57-submit-typology-results)
  - [5.8 A note on typology interdiction](#58-a-note-on-typology-interdiction)

## Introduction

The foundation of the Tazama Transaction Monitoring service is its ability to evaluate incoming transactions for financial crime risk through the execution of a number of conditional statements (rules) that are then combined into typologies that describe the nature of the financial crime that the system is trying to detect.

The Event Director (ED) is responsible for determining which typologies a transaction must be submitted to for the transaction to be evaluated for Financial Crime Risk. As part of this process, the ED determines which rules must receive the transaction and then which typologies are to be scored. The ED routes the transaction to the individual rule processors.

The rules receive the transaction, as well as the portion of the Network Map that was used to identify the rules as recipients (and by association also identifies which typologies are beneficiaries of those rules' results).

Each rule executes as a discrete and bespoke function in the evaluation process. Once a rule has completed its execution, it will pass its result, along with the transaction information and its Network sub-map to the Typology Processor where the rule result will be combined with the results from other rules as the results arrive to score a transaction according to a specific typology.

The Typology Processor is a single and centralized configuration-driven processing function that calculates a typology score for any and every typology in the system based on the incoming rule results for a typology, the Network Sub-map that defines the rules that roll up into a typology and a typology logic statement or "expression" that defines how the rules are to be composed into a typology score.

Once each typology has been scored, the result of the typology will be passed to the Transaction Aggregation and Decisioning Processor (TADProc) which will check each typology result as it is delivered for any immediate workflow triggers. 

## Typology Processor Context

![Typology processor context](../images/tazama-context-typology-processor.png)

<div style="text-align: right">
    <a href="#introduction">Top</a>
</div>

### 4. Submit rule results

The rule processor passes its completed result to the Typology Processor.

The rule result message includes the original transaction, the Network Sub-map and the rule execution result 

The rule result includes the rule identifier and the rule configuration, sub-rule identifier (`subruleref`), processing time for the rule and result score.

**Rule result example**

```JSON
{
    "id": "901@1.0.0",
    "cfg": "1.0.0",
    "subRuleRef": ".02",
    "prcgTm": 17682366,
    "wght": 200
  }
```
**Note** The ERFuP rule does not generate a score and the `wght` will always be 0

### 5.1. Determine beneficiary typologies

When the Typology Processor receives a rule result, the Typology Processor must interrogate the Network Sub-Map to identify which typologies in the Network Sub-map are the recipients (beneficiaries) of the rule result.

### 5.2. Determine all rules

For each typology identified as a beneficiary of the incoming rule result, the Typology Processor must again interrogate the Network Sub-Map to determine which other rules have been invoked that also has this typology as a beneficiary. This step defines all the constituent rules for which the typology expects results before it can calculate a score.

### 5.3.1 Fetch rule results

For each typology identified as a beneficiary of the incoming rule result, and using the list of constituent rules determined in 5.2, the Typology Processor must retrieve any previously cached rule results (if any) that had been received for the typology for the current transaction.

### 5.3.2. Check rule completion

For each typology identified as a beneficiary of the incoming rule result, and using the list of constituent rules determined in 5.2 and previously cached rule results (if any), the Typology Processor must check if all the rule results specified in the Network Sub-map have now been received.

### 5.4. Append rule result

If all of the rule results specified in the Network Sub-map for a specific typology have not yet been received, the incoming rule result must be cached so that it can be retrieved at a future time when all of the rules had been received.

### 5.5. Read typology configuration

If all of the rule results specified in the Network Sub-map for a specific typology have been received, the Typology Processor must retrieve the typology configuration for the beneficiary typology so that the rule results can be combined into a typology score.

At present, the calculation of a typology score is a straight-forward logic expression: typology score = rule_result_1.score + … + rule_result_n.score

<div style="text-align: right">
    <a href="#introduction">Top</a>
</div>

##### 5.5.1. The Typology Configuration

The typology configuration contains two sections: the first (**rules**) defines all the rules and their outcomes, along with the weighted score attributed to each true or false outcome; the second (**expression**) defines the expression that combines the rule results into the typology score.

**Example**:

The archetypical scam typology (typology 28) contains 18 different rules that feed the typology. These rules are composed into the typology via the typology configuration as follows:

```json
{
    "typology_name": "False promotions, phishing, or social engineering scams, such as fraudsters impersonating providers and advising customers they have won a prize in a promotion and to send money to the fraudster's number to claim the prize.",
    "id": "028@1.0.0",
    "cfg": "1.0.0",
    "rules": [
        {
            "id": "003@1.1.0",
            "cfg": "1.1.0",
            "termId": "v003at100at100",
            "wghts": [
                {
                    "ref": ".01",
                    "wght": "100"
                },
                {
                    "ref": ".02",
                    "wght": "100"
                },
                {
                    "ref": ".03",
                    "wght": "100"
                },
                {
                    "ref": ".00",
                    "wght": "100"
                }
            ]
        }
        {
            "id": "084@1.1.0",
            "cfg": "1.1.0",
            "termId": "v084at100at100",
            "wghts": [
                {
                    "ref": ".00",
                    "wght": "100"
                },
                {
                    "ref": ".01",
                    "wght": "100"
                }
            ]
        }
    ],
    "expression": [
        "Add",
        "v003at100at100",
        "v084at100at100"
    ]
}
```

The event flow processor is a special processor that is defined differently in the typology configuration. [EFRuP Typology configuration](./event-flow-rule-processor.md#2-typology-configuration)

### 5.6. Calculate typology score

For each beneficiary typology with a complete set of rule results, and using the typology expression and the associated score values, the Typology Processor must calculate the typology score for the typology.

**Note** The ERFuP rule does not contribute to the typology score and the `wght` for EFRuP rule will always be 0.

### 5.7. Submit typology results

Once the calculation of the typology score is complete, the Typology Processor must pass the typology result, including the transaction information, Network Sub-map, typology results and rule results to the Transaction Aggregation and Decisioning Processor.

### 5.8 A note on typology interdiction

The typology processor will interdict a transaction directly if the threshold for interdiction has been met, unless there is an override in place in which case the typology processor will not trigger an interdiction.

1. For a given typology, a specific threshold value must be linked to the typology for the following workflow outcomes:
    1. **Interdiction**: If a typology score is equal to or greater than this value, the Typology Processor will trigger an interdiction workflow to instruct the client system to block the transaction, unless there is an override in place, in which case the Typology Processor will not trigger an interdiction.
    2. **Review**: If a typology score is equal to or greater than this value, the Typology Processor will trigger an alert to the Case Management System to initiate an investigation into the transaction. In the case where the  [event flow processor](./event-flow-rule-processor.md) results in a different outcome to normal typology processing, then `review` will also be `true`.
    3. **None**: If a typology score is less than the Review threshold, no triggered action is taken by the Typology Processor.
2. The threshold for interdiction and investigation will be defined in the typology configuration.
