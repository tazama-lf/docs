<!-- SPDX-License-Identifier: Apache-2.0 -->

# Complete example of a typology processor configuration

Building on the example rule configurations provided here:

[Complete example of a rule processor configuration](/product/complete-example-of-a-rule-processor-configuration.md)

## Typology configuration for a typology with two rules

```JSON
{
    "desc": "Double-payment to a merchant",
    "id": "typology-processor@1.0.0",
    "cfg": "001@1.0.0",
    "workflow": {
        "alertThreshold": 200,
        "interdictionThreshold": 300,
        "flowProcessor": "EFRuP@1.0.0"
    },
    "rules": [
        {
            "id": "006@1.0.0",
            "cfg": "1.0.0",
            "termId": "v006at100at100",
            "wghts": [
                {
                    "ref": ".err",
                    "wght": 0
                },
                {
                    "ref": ".x00",
                    "wght": 0
                },
                {
                    "ref": ".x01",
                    "wght": 0
                },
                {
                    "ref": ".01",
                    "wght": 0
                },
                {
                    "ref": ".02",
                    "wght": 200
                },
                {
                    "ref": ".03",
                    "wght": 300
                }
            ]
        },
        {
            "id": "078@1.0.0",
            "cfg": "1.0.0",
            "termId": "v078at100at100",
            "wghts": [
                {
                    "ref": ".err",
                    "wght": 0
                },
                {
                    "ref": ".00",
                    "wght": 0
                },
                {
                    "ref": ".01",
                    "wght": 0
                },
                {
                    "ref": ".02",
                    "wght": 1
                },
                {
                    "ref": ".03",
                    "wght": 0
                }
            ]
        },
        {
            "id": "EFRuP@1.0.0",
            "cfg": "none",
            "termId": "vEFRuPat100atnone",
            "wghts": [
                {
                    "ref": ".err",
                    "wght": "0"
                },
                {
                    "ref": "override",
                    "wght": "0"
                },
                {
                    "ref": "non-overridable-block",
                    "wght": "0"
                },
                {
                    "ref": "overridable-block",
                    "wght": "0"
                },
                {
                    "ref": "none",
                    "wght": "0"
                }
            ]
        }
    ],
    "expression": [
        "multiply",
        "v006at100at100",
        "v078at100at100"
    ]
}
```

In this sample typology:

*   If the rule result that is submitted by rule processor 006 is `subRuleRef` .02, indicating two duplicated consecutive transaction amounts, the typology processor will assign a score of 200 to the result.
    
*   If the rule result that is submitted by rule processor 006 is `subRuleRef` .03, indicating three or more duplicated consecutive transaction amounts, the typology processor will assign a score of 300 to the result.
    
*   If the result from rule processor 006 is anything other than .02 or .03 and false, the typology processor will assign a score of 0 (zero).
    
*   If the rule result that is submitted by rule processor 078 is `subRuleRef` .02, indicating a merchant payment, the typology processor will assign a score of 1 to the result.
    
*   If the result from rule processor 078 is anything other than .02 and false, the typology processor will assign a score of 0 (zero).

The `workflow` object indicates that the `flowProcessor` ìs configured for the event flow processor, `EFRuP@1.0.0`. The result of EFRuP can be one of `override`, `non-overridable-block`, `overridable-block` or `none`. Scores are not applicable to the EFRuP outcome and are all assigned a weight of 0.

When both rule results are delivered and scored, the typology processor will multiply them together, according to the `expression`. Hence, if the transaction was a merchant payment, the result of the calculation would be either 200 or 300, depending on whether there were 2 or 3 consecutive transactions with the same amount. If the transaction is not a merchant payment, the multiplier from that rule evaluation would be 0 and the result would also be 0. 

Note that the event flow processor scores are not applicable and are ignored in the expression.

According to the `workflow` object, if the typology score is 200 or greater, the system would issue an investigative alert against the transaction at the end of the evaluation process. If the typology score is 300 or greater, the system would interdict (block) the transaction immediately.


