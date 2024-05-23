# Tazama Rules life-cycle

- [Tazama Rules life-cycle](#tazama-rules-life-cycle)
  - [1. Typology identification](#1-typology-identification)
  - [2. Rules discovery](#2-rules-discovery)
  - [3. Rules development](#3-rules-development)
  - [4. Rules testing](#4-rules-testing)
  - [5. Rules deployment](#5-rules-deployment)
  - [6. Rules execution](#6-rules-execution)
  - [7. Rules performance monitoring](#7-rules-performance-monitoring)
  - [8. Rule calibration](#8-rule-calibration)

The life-cycle for typologies and rules included in the Tazama platform broadly follow the process described in the image below:

![](../images/image-20210316-072938.png)

**Typologies** define the methods according to which financial crime is performed by criminals to defraud users in the eco-system or to launder money/finance terrorism.

**Rules** are the boolean statements that we deploy to attempt to detect a typology in a specific transaction or set of transactions.

## 1. Typology identification

There are numerous sources of typology information such as the [Financial Action Task Force](https://www.fatf-gafi.org/publications/methodsandtrends/?hf=10&b=0&s=desc(fatf_releasedate)) (FATF), [Committee of Experts on the Evaluation of Anti-Money Laundering Measures and the Financing of Terrorism](https://www.coe.int/en/web/moneyval/activities/typologies) (Moneyval), the [Global System for Mobile Communications Association](https://www.gsma.com/services/fraudsecurity/) (GSMA), the [Association of Certified Anti-Money Laundering Specialists](https://www.acams.org/en) (ACAMS) and regional Financial Intelligence Centers, such as the [FIC in South Africa](https://www.fic.gov.za/Resources/Pages/ScamsAwareness.aspx) and the [Australian Transaction Reports and Analysis Centre](https://www.austrac.gov.au/business/industry-specific-guidance) (AUSTRAC).

In 2020, Deloitte had compiled a comprehensive list of 232 typologies that were deemed relevant to push payments and mobile money funded by the Bill & Melinda Gates Foundation to support the development of a Fraud Risk Management (FRM) solution for the Mojaloop switching platform. The FRM workstream expanded the list with an additional 40 typologies focused on typologies related to internal fraud at the switching hub. This work forms the initial typology register on which the FRM development is based.

To assist with the prioritisation of the typologies, each typology was classified across 7 dimensions and 20 attributes through the APRICOT model, which was also invented by Deloitte as part of the FRM workstream. The model assists in narrowing down the list of typologies based on the anticipated deployment scope of the FRM solution, now codenamed Tazama.

While the register is the source for the initial set of typologies, financial crime is constantly evolving to stay ahead of detection and prevention methodologies. It is expected that new typologies will arise over time that will then have to be added to the register and subsequently included in the Tazama platform’s detection scope.

## 2. Rules discovery

The typologies merely provide the method according to which financial crime is executed and do not specifically provide the means of detection. We have chosen a rules-based approach to detecting financial crime related to the prioritised typologies as the basic foundation for transaction monitoring with the Tazama platform. We expect that detection may include machine learning and artificial intelligence in the future, though this approach will require additional research and resources that do not fall within the scope and budget of the Tazama development in the short term.

Rules discovery is currently largely driven by the collective experience of the team. Through brainstorming and research, we identify rules that can be used to detect a typology when a new transaction is evaluated within the Tazama Transaction Monitoring Service.

Rules can be broadly classified into the following types:

- **Atomic Rule**: A single logic statement that evaluates to a single boolean (true or false) outcome.

***Example***:

IF an MSISDN has been associated with a new SIM ICCID within the last 3 days

In this example, the rule will evaluate to either TRUE or FALSE.

- **Compound rule**: The combination of multiple atomic rules through logic operators (AND, OR, XOR) that evaluates to a single outcome.

***Example***:

IF the Payer is a private individual

AND

IF the Payer had never performed a transfer request before

Compound rules are expected to only be used during in the aggregation of rule results during the processing of a typology and should not be composed in any rules processor.

- **Rule-set**: Multiple mutually exclusive logic statements that are combined to evaluate to a single outcome. Rule-sets effectively resemble case statements composed out of atomic rules.

***Example***:

Rule xx: How long has the customer account been dormant?

| Sub-rule ref | Statement | Outcome | Reason |
| --- | --- | --- | --- |
| .01 | IF the elapsed time since the most recent transfer to or from the account is more than 3 months, but less than 6 months | Payee account dormancy 3 = TRUE | Payee account dormant for between 3 and 6 months |
| .02 | IF the elapsed time since the most recent transfer to or from the account is more than 6 months, but less than 12 months | Payee account dormancy 6 = TRUE | Payee account dormant for between 6 and 12 months |
| .03 | IF the elapsed time since the most recent transfer to or from the account is more than 12 months | Payee account dormancy 12 = TRUE | Payee account dormant for longer than 12 months |
| .00 | IF the elapsed time since the most recent transfer to or from the account is less than 3 months | Payee account dormancy = FALSE | Payee account not dormant in the last 3 months |
| .04 | IF no prior transfer requests from or to the account could be found at all | Payee account dormancy = FALSE | Inconclusive payee account dormancy - no transactions found |

In this example, the specific sub-rule that evaluates to be TRUE will be identified in the ultimate output of the rule. For example, if there had been no transfer requests from or to the account in 211 days, the rules engine will output “Rule xx.02” which is the identifier of the sub-rule that evaluated to true.

Rule-sets are typically used to group continuous results into specific bands or buckets. We are aiming to limit the typology processing to the evaluation of true/false values only.

Rules inevitably rely on data for their execution and the data that will be available in a deployment also has an impact on whether a specific rule is viable or not; however our initial approach is to specify rules based on an idealistic expectation of data availability and then we whittle down the rules based on the data that is available. The reasoning behind this is that we may identify rules that are so critical to the successful detection of a typology that it is worth expanding the scope of data collection just in order to enable the execution of the rule.

## 3. Rules development

Rules are expected to be developed as discrete modules of code that can be parameterised with inputs specific to a deployment or a typology. Each rule returns a boolean (true or false) result at the end of its execution.

Rules are developed in a modular fashion and inteded to be executed in the language or tool best suited to the type of rule. Our rules are predominantly developed in JavaScript and executed in Node.js, though there are rules that require more specialised tools such as TinkerPop Gremlin statements calling on a graph database for a result. Some rules can be fully self-contained, requiring no additional libraries, while other rules require access to mathematical or statistical libraries and many months' worth of historical data related to previous transactions passed through and stored by the platform. Some rules may also collect additional information hosted elsewhere or outside the platform.

All changes to an existing rule must be tracked so that a reviewer can easily see what had changed in the code since the previous deployed or approved version of the rule.

## 4. Rules testing

When a new rule is developed, the rule must be tested, and preferable in an automated fashion to meet the requirements of Continuous Integration/Continuous Deployment (CI/CD). There is a number of different types of testing that must be employed to ensure the effective functioning of a rule:

**Unit testing** ensures that the rule is functioning as expected, returning the correct result for the provided input parameters, in line with the rule specification.

**Integration testing** ensures that the rule fits within the existing architecture and eco-system without causing unintended consequences or accidental breakdowns.

**Performance testing** checks whether the rule meets the required metrics for efficient operation. Performance metrics may include turnaround time (the rule should not create any processing bottle-necks), use of resources (the efficient execution of the rule shouldn’t consume more than the budgeted amount of resources), detection effectiveness (the rule should improve the detection rate within the platform without increasing the rate of false positive results).

**Regression testing** ensures that the implementation of a rule leaves the platform in a similar or better position then it was in before the deployment of the new rule. We expect a standard battery of tests that tests the over-all end-to-end system health that produce the same results after the deployment of a new rule.

Rules testing can be performed in both a positive (does it work?) or a negative (can it break and how?) approach.

One of the key components of all types of testing of a rule is the data that is required to fuel the test. For unit testing, new data may be required to test the rule, but for integration, performance and regression testing, an existing library of test data will be required so that the test results are repeatable and comparable amongst different rules.

## 5. Rules deployment

If a rule has been tested and deemed fit for deployment, the rule must be deployed into a production environment. By nature, rules are deemed sensitive and critical to the operation of the platform. Deployment must be governed by a strict and secure change control process that includes a workflow that relies on segregated user roles for development, review and approval functions.

A new version of an existing rule must also be appropriately and uniquely versioned, since the key to the execution of a rule in the logs and results will include a unique rules ID as well as the version of the rule at the time that it was executed. Versioning is also necessary to facilitate replayability of a rule for regulatory or legislative “proof of results” requirements.

## 6. Rules execution

Once a rule is in production, the rule will be utilised to evaluate a transaction according to the rule’s code. Every time a rule is executed, the utilisation must be logged. Rules must be executed securely and integrity must be assured to eliminate malfunction or malfeasance.

Rules can be executed DRY (once per transaction with the same set of parameters for all typologies that may utilise that rule’s result) or WET (once per typology with a set of parameters specific to the typology that utilises the rule’s result).

The parameterisation of a DRY rule is configured when the rule is deployed into a channel. The parameterisation of a WET rule will be driven out of the typology as part of its configuration or code. The remaining input into a rule is from the data in the transaction being evaluated.

A DRY rule must return its result in a way that allows all of the typologies that require the result to access the result when they need it. Different rules are expected to deliver their results asynchronously and at vastly varying intervals, depending on the execution time of each rule. Rules based on historical data are particularly time-consuming, compared to very simple rules that merely interrogate the value of a field in a transaction.

WET rules will return their results directly to the typology that invoked the rule.

## 7. Rules performance monitoring

During the operation of the platform, the system will collect information about the performance of each of the rules. Performance in this case would be defined in terms of:

Telemetry (turnaround time and throughput, consumption of resources)

Detection rate

False positive rate

Poor or diminishing performance may result in the review of a rule in order to improve the rule functioning.

The evaluation of the rule performance would be informed by analytics based on data collected by the system during its operation, complaints and feedback received based on undetected fraud and the results of investigations into alerts generated by the system.

With the exception of telemetry, real-time performance monitoring is unlikely to be useful and daily or weekly reporting on performance trends should be sufficient.

## 8. Rule calibration

Rules are subject to two types of variation over time. Firstly, the parameters that drive a rule, such as specific thresholds against which data will be evaluated, may change over time, or from one deployment to the next. Second, each rule is expected to carry a certain weight when taken into account when calculating the probability of a typology being triggered based on the sum of the rules used to evaluate the transaction.

In both of these cases, the performance monitoring of the rules (and the typologies) must ultimately assist the platform operator in tweaking the input parameters of the rules as well as the weighting of the rule contributions to the typology probability scoring.

In turn, the analysis of the performance metrics will point to adjustements in the configuration of rule input parameters, rules weightings, and even if a specific rule is relevant at all.
