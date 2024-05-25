<!-- SPDX-License-Identifier: Apache-2.0 -->

# Complete example of a rule processor configuration

## A “banded” rule configuration:

```
{
    "id": "006@1.0.0",
    "cfg": "1.0.0",
    "desc": "Outgoing transfer similarity - amounts",
    "config": {
      "parameters": {
        "maxQueryLimit": 3,
        "tolerance": 0.1
      },
      "exitConditions": [
        {
          "subRuleRef": ".x00",
          "reason": "Incoming transaction is unsuccessful"
        },
        {
          "subRuleRef": ".x01",
          "reason": "Insufficient transaction history"
        }
      ],
      "bands": [
        {
          "subRuleRef": ".01",
          "upperLimit": 2,
          "reason": "No similar amounts detected in the most recent transactions from the debtor"
        },
        {
          "subRuleRef": ".02",
          "lowerLimit": 2,
          "upperLimit": 3,
          "reason": "Two similar amounts detected in the most recent transactions from the debtor"
        },
        {
          "subRuleRef": ".03",
          "lowerLimit": 3,
          "reason": "Three or more similar amounts detected in the most recent transactions from the debtor"
        }
      ]
    }
  }
```

## A “cased" rule configuration

```
{
    "id": "078@1.0.0",
    "cfg": "1.0.0",
    "desc": "Transaction type",
    "config": {
      "parameters": {},
      "exitConditions": [],
      "cases": [
        {
          "subRuleRef": ".00",
          "reason": "The transaction type is not defined in this rule configuration"
        },
        {
          "subRuleRef": ".01",
          "value": "WITHDRAWAL",
          "reason": "The transaction is identified as a cash withdrawal"
        },
        {
          "subRuleRef": ".02",
          "value": "PAYMENT",
          "reason": "The transaction is identified as a merchant payment"
        },
        {
          "subRuleRef": ".03",
          "value": "TRANSFER",
          "reason": "The transaction is identified as a direct funds transfer"
        }
      ]
    }
  }
```