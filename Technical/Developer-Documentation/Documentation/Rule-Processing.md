# 3. Rule Processing

![](../../../../Images/TMS_Rules_Processing_Context.png)

- [3. Rule Processing](#3-rule-processing)
- [Introduction](#introduction)
- [Definitions](#definitions)
- [Rule processing context](#rule-processing-context)
  - [3.0. Evaluate transaction](#30-evaluate-transaction)
  - [3.1. Read rule config](#31-read-rule-config)
    - [Example:](#example)
  - [3.2. Read historical transactions](#32-read-historical-transactions)
  - [3.3. Execute rule](#33-execute-rule)
  - [3.4. Submit rule results](#34-submit-rule-results)

# Introduction

The foundation of the Tazama Transaction Monitoring service is its ability to evaluate incoming transactions for financial crime risk through the execution of a number of conditional statements (rules) that render a boolean (True or False) result based on specific attributes of the incoming transaction and past transactions.

The Channel Router & Setup Processor (CRSP) is responsible for determining which channels and typologies a transaction must be submitted to for the transaction to be evaluated for Financial Crime Risk. As part of this process, the CRSP determines which rules must receive the transaction and then routes the transaction to these rules as the next step in the evaluation process.

The rules receive the transaction, as well as the portion of the Network Map that was used to identify the rules as recipients (and by association also identifies which typologies are beneficiaries of those rules’ results).

Each rule executes as a discrete and bespoke function in the evaluation process. (Once we have developed enough rules to make a determination, common rules, or common components of rules, can be abstracted into a library or rules could even be composed in a GUID/IDE and executed by a rules engine.)

Once a rule has completed its execution, it will pass its result, along with the transaction information and its Network sub-map to the Typology Processor where the rule result will be combined with the results from other rules to score a transaction according to a specific typology (a way to describe a specific kind of financial crime).

# Definitions

**Atomic Rule**: A single logic statement that evaluates to a single outcome. (Think of an atomic rule as a typical “IF” statement.)

Example:

IF an MSISDN has been associated with a new SIM ICCID within the last 3 days

In this example, the rule will evaluate directly to either TRUE or FALSE.

**Compound rule**: The combination of multiple atomic rules through logic operators (AND, OR, XOR) that evaluates to a single outcome.

Example:

IF the Payer is a private individual

AND

IF the Payer had never performed a transfer request before

Compound rules are expected to only feature as typologies where the results from several rules are combined into a typology and scored to identify potential financial crime.

The logical “sum” that is used to combine rule results is called the “typology expression”.

**Rule-set**: Multiple mutually exclusive logic statements that are combined to evaluate to a single outcome. (Think of a rule-set as a typical “CASE” statement.)

Example:

IF no transactions had been performed to or from a payee’s account within a given time-frame

| **Sub-rule ref** | **Statement**                                                                                                            | **Outcome**                      | **Reason**                                                  |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------ | -------------------------------- | ----------------------------------------------------------- |
| .01              | IF the elapsed time since the most recent transfer to or from the account is more than 3 months, but less than 6 months  | Payee account dormancy 3 = TRUE  | Payee account dormant for between 3 and 6 months            |
| .02              | IF the elapsed time since the most recent transfer to or from the account is more than 6 months, but less than 12 months | Payee account dormancy 6 = TRUE  | Payee account dormant for between 6 and 12 months           |
| .03              | IF the elapsed time since the most recent transfer to or from the account is more than 12 months                         | Payee account dormancy 12 = TRUE | Payee account dormant for longer than 12 months             |
| .00              | IF the elapsed time since the most recent transfer to or from the account is less than 3 months                          | Payee account dormancy = FALSE   | Payee account not dormant in the last 3 months              |
| .04              | IF no prior transfer requests from or to the account could be found at all                                               | Payee account dormancy = FALSE   | Inconclusive payee account dormancy - no transactions found |

In this example, the rule that is evaluated to be TRUE will be identified in the output of the rule. For example, if there had been no transfer requests from or to the account in 211 days, the rules processor will output “Rule 003@1.0.0.02: Payee account dormancy 6 = TRUE”, along with the appropriate reason code.

# Rule processing context

![](../../../../Images/TMS_Rules_Processing_Context.png)

**Figure**: *Tazama TMS Rules Processing Context*

## 3.0. Evaluate transaction

The Channel Routing and Setup Processor (CRSP) will submit the transaction to each of the rules identified by the CRSP as required for the evaluation of the transaction. The CRSP will include the local Network Sub-map that contains the transaction, channel, rule and typology routing information determined for the transaction.

The CRSP will also consolidate multiple occurrences of a specific unique rule into a single rule processor execution, across any number of channels or typologies in the Network sub-map (for a specific transaction type).

For each rule processor invoked by the CRSP:

## 3.1. Read rule config

The rule processor will read its default configuration parameters from a configuration file stored in the Tazama Configuration database. A rule processor can be parameterised with the following information:

**Thresholds**: If a condition is to be evaluated against a specific value for the rule to be either TRUE or FALSE, e.g. IF multiple incoming transactions within the last hour show similar or identical values for transaction amounts (**within 5%**): The threshold for the evaluation is **5%**.

**Time-frames**: If a condition is to be evaluated over data accumulated during a specific period, e.g. IF multiple incoming transactions **within the last hour** show similar or identical values for transaction amounts (within 5%): The time-frame for the evaluation is **1 hour**. Timeframes are always specified in Epoch Millis as the lowest common unit of measure for time in the Tazama system. (See: [https://www.epochconverter.com/](https://www.epochconverter.com/) )

**Band limits**: If a number of rule conditions are evaluated as a rule-set, band limits define the lower and upper bounds of each of the rule bands. In our rule-set example above: IF no transactions had been performed to or from a payee’s account within a given time-frame, the band limits are:

| **Sub-Rule Ref** | **Lower limit** | **Upper limit** |
| ---------------- | --------------- | --------------- |
| .00              |                 | 3 months        |
| .01              | 3 months        | 6 months        |
| .02              | 6 months        | 12 months       |
| .03              | 12 months       |                 |

Unless otherwise specified in a rule specification, the lower limits are “greater or equal to” and the upper limits are “less than”.

The configuration for a specific rule will be read from a JSON configuration file stored in the config database.

For a consistent approach in defining the parameters for various rule processors, we are defining the configuration for an atomic rule based on a threshold parameter the same way as we would define the multiple bands for a rule-set. In effect, a threshold merely defines two bands where the threshold is the upper limit in one band, and the lower limit in the second.

Some bands do not have an explicit lower or upper limit and these bands are considered to be “unbounded” with an unspecified lower or upper limit. We define these limits with a “null” value, specifically to differentiate them from 0 (zero) limits that actually defines a legitimate explicit value.

In JSON, we do not explicitly specify a “null” value, but rather we leave the limit that would be “null” completely out of the config file. We would then need to interpret the “missing” limit as having a “null” value when the configuration is read into the processor.

Some rules contain “exit” bands in their configurations where both the upper and lower limits would be “null”. For example, a rule-set may include an exit condition for when there is insufficient transaction history to draw a conclusion. Exit condition outcomes are almost always “false” with a sub-rule reference of “.00”

We also apply a standard operator to the evaluation of limits in any band:

Lower limits are always evaluated with a >= (greater or equal)

Upper limits are always evaluated with a < (less than)

### Example:

Rule 018 is an atomic rule with two outcomes against a calculated threshold value. The threshold in the configuration is the multiplier that is used to calculate the threshold that is used to determine the rule result. The specification of the configuration is presented as follows:

Threshold = 1.5

Time-frame = 3 months

| Rule ref | Sub-rule ref | Statement                                                                            | Outcome | Reason                                         |
| -------- | ------------ | ------------------------------------------------------------------------------------ | ------- | ---------------------------------------------- |
| 018      | .01          | IF the debtor transfers >  (maximum amount * threshold) in the timeframe (3 months) | TRUE    | Exceptionally large outgoing transfer detected |
| 018      | .02          | IF the debtor transfers <= (maximum amount * threshold) in the timeframe (3 months) | FALSE   | Outgoing transfer within historical limits     |
| 018      | .00          | If no transaction history can be retreived for the rule                              | FALSE   | Insufficient transaction history               |

Translated to a “band” specification, this would be presented as follows:

| Rule ref | Sub-rule ref | lower limit | upper limit | Statement                                                                            | Outcome | Reason                                         |
| -------- | ------------ | ----------- | ----------- | ------------------------------------------------------------------------------------ | ------- | ---------------------------------------------- |
| 018      | .01          | 0           | 1.5         | IF the debtor transfers >  (maximum amount * threshold) in the timeframe (3 months) | TRUE    | Exceptionally large outgoing transfer detected |
| 018      | .02          | 1.5         | null        | IF the debtor transfers <= (maximum amount * threshold) in the timeframe (3 months) | FALSE   | Outgoing transfer within historical limits     |
| 018      | .00          | null        | null        | If no transaction history can be retreived for the rule                              | FALSE   | Insufficient transaction history               |

The representation of this specification in a config file would then be:

```json
{
    "id": "018@1.0.0",
    "cfg": "1.0.0",
    "config": {
        "timeframes": [
            {
                "threshold": 7889229000
            }
        ],
        "bands": [
            {
                "subRuleRef": ".00",
                "outcome": false,
                "reason": "Insufficient transaction history"
            },
            {
                "subRuleRef": ".01",
                "lowerLimit": 0,
                "upperLimit": 1.5,
                "outcome": true,
                "reason": "Exceptionally large outgoing transfer detected"
            },
            {
                "subRuleRef": ".02",
                "lowerLimit": 1.5,
                "outcome": true,
                "reason": "Outgoing transfer within historical limits"
            }
        ]
    }
}
```

## 3.2. Read historical transactions

Some rules require additional data from transactions that had been processed previously, or even the results from previous evaluations. These rules must be able to retrieve the required information from the transaction history repository/database.

For example, the rule:

IF multiple incoming transactions within the last hour show similar or identical values for the transaction description by calculating the Damerau–Levenshtein distance between the descriptions

would require all previous transactions routed to a single creditor account within the last hour. (Coincidentally, explicit values for “multiple” and “similar” would be defined through “threshold” parameters, as would an explicit “time-frame” for “within the last hour”.)

## 3.3. Execute rule

Taking into account the transaction and the input parameters, the rule would execute according to its coded instructions to determine a TRUE or FALSE result, as well as the reason for the result.

A rule may render multiple TRUE or FALSE outcomes, but for different reasons. For example, a rule may render a FALSE result if there are insufficient historical transactions to effectively calculate a result, or if the rule calculation fell below the required threshold for a TRUE result. For this reason, a rule result must always be supported by a descriptive reason. The reason that is part of a rule result will be used in the report to users on the transaction outcomes as well as more descriptive information to support investigations.

## 3.4. Submit rule results

The rule processor passes its completed result to the Typology Processor. In contrast to a rule processor which is discrete and bespoke, the Typology Processor is a single interpreter that calculates typology scores for any typology based on an external typology-specific configuration.

The rule result message includes the original transaction, the Network Sub-map and the rule execution result (Rule identifier, sub-rule identifier (for rule-sets), boolean rule result and result reason).
