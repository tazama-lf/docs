<!-- SPDX-License-Identifier: Apache-2.0 -->

# Standard Rule Processor Exit and Error Conditions

- [Standard Rule Processor Exit and Error Conditions](#standard-rule-processor-exit-and-error-conditions)
  - [Introduction](#introduction)
  - [Register of standard error conditions](#register-of-standard-error-conditions)
    - [Default “unhandled” error condition](#default-unhandled-error-condition)
    - [Rule config setup](#rule-config-setup)
      - [If the rule config cannot be retrieved from the cache or database:](#if-the-rule-config-cannot-be-retrieved-from-the-cache-or-database)
      - [If the rule description cannot be retrieved:](#if-the-rule-description-cannot-be-retrieved)
      - [If the rule config is invalid:](#if-the-rule-config-is-invalid)
      - [If the rule config has a missing exit condition:](#if-the-rule-config-has-a-missing-exit-condition)
      - [If the rule config has a missing parameter:](#if-the-rule-config-has-a-missing-parameter)
    - [Trigger payload validation](#trigger-payload-validation)
      - [If the DataCache object cannot be resolved from the trigger payload:](#if-the-datacache-object-cannot-be-resolved-from-the-trigger-payload)
    - [Query execution](#query-execution)
      - [If the response from the query means that there is a data error that needs to be reported:](#if-the-response-from-the-query-means-that-there-is-a-data-error-that-needs-to-be-reported)
      - [If the response from the query is not in the correct data format:](#if-the-response-from-the-query-is-not-in-the-correct-data-format)
      - [If the response from the query function call reports an error (e.g. DB timeout, DB unreachable, DB authentication failure, etc.):](#if-the-response-from-the-query-function-call-reports-an-error-eg-db-timeout-db-unreachable-db-authentication-failure-etc)
    - [Determine outcome handling](#determine-outcome-handling)
  - [Register of standard exit conditions](#register-of-standard-exit-conditions)
    - [.x00: If the current transaction is unsuccessful (`TxSts != 'ACCC'`):](#x00-if-the-current-transaction-is-unsuccessful-txsts--accc)
    - [.x01: If the number of returned results is less than the minimum number of results required for a deterministic outcome:](#x01-if-the-number-of-returned-results-is-less-than-the-minimum-number-of-results-required-for-a-deterministic-outcome)
    - [If the specific exit condition description is missing from the rule config:](#if-the-specific-exit-condition-description-is-missing-from-the-rule-config)

## Introduction

The purpose of this document is to define all the standard error (rule failure) and exit (valid, but either deterministic or non-deterministic) outcomes for rule processors in general.

Error and exit conditions are “hard-coded” into the rule logic, but the formatting and contents of the error and exit condition messages should be standardised across the platform.

All rule processors produce a rule processor result in the following format as a JSON object appended to the rule processor payload, for example:

```json
ruleResult = {
  "id": "001@1.0.0",
  "cfg": "1.0.0",
  "subRuleRef": ".01"
}
```

In cases where a standard error was encountered, a descriptive `reason` field will be attached to the `ruleResult` noting the cause for that error.

The deterministic outcomes for a rule processor will be defined either in rule “bands” or “cases”, e.g.

```json
    "bands": [
      {
        "subRuleRef": ".01",

        "upperLimit": 86400000,
        "reason": "Creditor account is less than 1 day old"
      },
      {
        "subRuleRef": ".02",
        "lowerLimit": 86400000,
        "upperLimit": 2592000000,
        "reason": "Creditor account is between 1 and 30 days old"
      },
      {
        "subRuleRef": ".03",
        "lowerLimit": 2592000000,
        "upperLimit": 7776000000,
        "reason": "Creditor account is between 30 and 90 days old"
      },
      {
        "subRuleRef": ".04",
        "lowerLimit": 7776000000,

        "reason": "Creditor account is more than 90 days old"
      }
    ]

```

The retrieval of the correct band for a given input `searchTerm` is automated with each rule processor’s `determineBandedOutcome` or `determineCasedOutcome` methods.

Error conditions do not need their own unique sub-rule reference and all error conditions are produced with a `".err"` subRuleReference. For error conditions, the description of the error must be passed in the `"reason"` field.

Exit conditions are defined in the rule configuration since some error conditions may also be deterministic and would need to be interpreted correctly by the typology processor. An exit condition carries an alternative “prefix” in their subRuleReference variables, e.g.

```text
        "subRuleRef": ".x00",
```

The prefix is somewhat arbitrary, but we have elected to use an “x” to identify exit conditions separately from regular deterministic banded or cased outcomes.

Furthermore, exit conditions are defined in the rule config, while error conditions are not, so that the typology processor can discriminate between deterministic and non-deterministic rule results. Exit conditions are defined separately from the result bands or cases, e.g.

```json
    "exitConditions": [
      {
        "subRuleRef": ".x00",
        "reason": "No verifiable creditor account activity detected"
      }],
    "bands": [
      {
        "subRuleRef": ".01",

        "upperLimit": 86400000,
        "reason": "Creditor account is less than 1 day old"
      }],
```

## Register of standard error conditions

The `ruleResult.subRuleRef` for an error condition is *always* `.err`

### Default “unhandled” error condition

Default "unhandled" error condition to be set at the initialisation of the ruleResult object at the top of the logic.service.ts file (This should eventually be in the rule processor scaffold):

```text
    reason: 'Unhandled rule result outcome',
```

### Rule config setup

#### If the rule config cannot be retrieved from the cache or database:

```text
    reason: 'Rule processor configuration not retrievable',
    desc: 'Rule description could not be retrieved'
```

#### If the rule description cannot be retrieved:

```text
    desc: 'No description provided in rule config'
```

#### If the rule config is invalid:

This validation can only be performed at rule configuration ingestion and in a generic manner for all rule processors, i.e. without creating individual `interfaces` for each rule processor, the rule-specific components of the rule config, such as parameters and exit conditions, cannot be evaluated in this way.

```text
    reason: 'Rule processor configuration invalid',
```

#### If the rule config has a missing exit condition:

Missing exit conditions can only be resolved at the point where the specific rule processor attempts to retrieve the exit condition from the rule config and fails. This is not strictly an error outcome for the rule processor, since it was able to determine an appropriate result.

#### If the rule config has a missing parameter:

Missing parameters can only be resolved at the point where the specific rule processor attempts to retrieve the parameter from the rule config and fails. A missing parameter will result in the rule processor not being able to determine a result and should produce an error condition outcome.

```text
    reason: 'Rule processor configuration invalid - missing parameter',
```

### Trigger payload validation

#### If the DataCache object cannot be resolved from the trigger payload:

```text
    reason: 'DataCache object not retrievable',
```

### Query execution

#### If the response from the query means that there is a data error that needs to be reported:

```text
    reason: 'Data error: irretrievable transaction history',
```

The precise circumstances of this outcome is rule-specific. For some rules, a `null` query result is deterministic and valid, but for other rules a `null` outcome may indicate an underlying data issue. The same may apply to an empty array result `[]` returned by the query. Typically a query that should at least contain the trigger payload in the outcome should throw an error when the query result is empty.

#### If the response from the query is not in the correct data format:

```text
    reason: 'Data error: query result type mismatch - expected <format>',
```

The expected format (number, timestamp, array of numbers, etc) must be included in the error message, to replace the `<format>` string, if possible.

#### If the response from the query function call reports an error (e.g. DB timeout, DB unreachable, DB authentication failure, etc.):

```text
    reason: \`${queryResponseError}\`,
```

The query function should explicitly report the error that was encountered so that it can be included in the rule result as a reason.

### Determine outcome handling

If an outcome was not able to be determined in the `Determine<Banded/Cased> Outcome` function due to a gap in the contiguous bands:

```text
    reason: 'Unresolvable rule result due to misaligned result categories',
```

To check if the `Determine<Banded/Cased> Outcome` function was called without a rule config object parameter should be handled via a `docstring` related to the function definition.

```text
reason: 'Rule config not provided in determineBandedOutcome function',
```

If the `Determine<Banded/Cased> Outcome` function was called without a searchTerm parameter

```text
reason: 'Search term not provided in determineBandedOutcome function',
```

## Register of standard exit conditions

The `reason` associated with a specific exit condition `subRuleRef` is defined in the rule config.

Different rules may require different exit conditions from the complete generic set, but the `subRuleRef` for specific error condition categories should be the same. The `reason` for an exit condition will be defined against the `subRuleRef` in the rule config.

### .x00: If the current transaction is unsuccessful (`TxSts != 'ACCC'`):

```text
    subRuleRef: '.x00',
```

### .x01: If the number of returned results is less than the minimum number of results required for a deterministic outcome:

```text
    subRuleRef: '.x01',
```

### If the specific exit condition description is missing from the rule config:

```text
    reason: 'Reason description could not be retrieved from the rule config',
```
