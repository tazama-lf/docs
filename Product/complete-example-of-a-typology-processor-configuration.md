# Complete example of a typology processor configuration

Building on the example rule configurations provided here:

[Complete example of a rule processor configuration](/product/complete-example-of-a-rule-processor-configuration.md)

## Typology configuration for a typology with two rules

```
{
  "desc": "Double-payment to a merchant.",
  "id": "typology-processor@1.0.0",
  "cfg": "001@1.0.0",
  "rules": \[
    {
      "id": "006@1.0.0",
      "cfg": "1.0.0",
      "ref": ".err",
      "true": 0,
      "false": 0
    },
    {
      "id": "006@1.0.0",
      "cfg": "1.0.0",
      "ref": ".x00",
      "true": 100,
      "false": 0
    },
    {
      "id": "006@1.0.0",
      "cfg": "1.0.0",
      "ref": ".x01",
      "true": 100,
      "false": 0
    },
    {
      "id": "006@1.0.0",
      "cfg": "1.0.0",
      "ref": ".01",
      "true": 0,
      "false": 0
    },
    {
      "id": "006@1.0.0",
      "cfg": "1.0.0",
      "ref": ".02",
      "true": 200,
      "false": 0
    },
    {
      "id": "006@1.0.0",
      "cfg": "1.0.0",
      "ref": ".03",
      "true": 300,
      "false": 0
    },
    {
      "id": "078@1.0.0",
      "cfg": "1.0.0",
      "ref": ".err",
      "true": 0,
      "false": 0
    },
    {
      "id": "078@1.0.0",
      "cfg": "1.0.0",
      "ref": ".00",
      "true": 0,
      "false": 0
    },
    {
      "id": "078@1.0.0",
      "cfg": "1.0.0",
      "ref": ".01",
      "true": 0,
      "false": 0
    },
    {
      "id": "078@1.0.0",
      "cfg": "1.0.0",
      "ref": ".02",
      "true": 1,
      "false": 0
    },
    {
      "id": "078@1.0.0",
      "cfg": "1.0.0",
      "ref": ".03",
      "true": 0,
      "false": 0
    }
  \],
  "expression": {
    "operator": "\*",
    "terms": \[
      {
        "id": "006@1.0.0",
        "cfg": "1.0.0"
      },
      {
        "id": "078@1.0.0",
        "cfg": "1.0.0"
      }
    \]
  },
  "workflow": {
    "alertThreshold": 200,
    "interdictionThreshold": 300
  }
}
```

In this sample typology:

*   If the rule result that is submitted by rule processor 006 is `subRuleRef` .02 and true, indicating two duplicated consecutive transaction amounts, the typology processor will assign a score of 200 to the result.
    
*   If the rule result that is submitted by rule processor 006 is `subRuleRef` .03 and true, indicating three or more duplicated consecutive transaction amounts, the typology processor will assign a score of 300 to the result.
    
*   If the result from rule processor 006 is anything other than .02 or .03 and false, the typology processor will assign a score of 0 (zero).
    
*   If the rule result that is submitted by rule processor 078 is `subRuleRef` .02 and true, indicating a merchant payment, the typology processor will assign a score of 1 to the result.
    
*   If the result from rule processor 078 is anything other than .02 and false, the typology processor will assign a score of 0 (zero).
    

When both rule results are delivered and scored, the typology processor will multiply them together, according to the `expression`. Hence, if the transaction was a merchant payment, the result of the calculation would be either 200 or 300, depending on whether there were 2 or 3 consecutive transactions with the same amount. If the transaction is not a merchant payment, the multiplier from that rule evaluation would be 0 and the result would also be 0.

Finally, according to the `workflow` object, if the typology score is 200 or greater, the system would issue an investigative alert against the transaction at the end of the evaluation process. If the typology score is 300 or greater, the system would interdict (block) the transaction immediately.