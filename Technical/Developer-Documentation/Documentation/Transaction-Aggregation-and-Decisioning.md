# Transaction Aggregation and Decisioning

- [Transaction Aggregation and Decisioning](#transaction-aggregation-and-decisioning)
- [Introduction](#introduction)
- [Transaction Aggregation and Decisioning Processor Context](#transaction-aggregation-and-decisioning-processor-context)
  - [4. Submit rule results](#4-submit-rule-results)
  - [5. Submit typology results](#5-submit-typology-results)
  - [6. Submit channel results](#6-submit-channel-results)
  - [7.1. Determine beneficiary transaction](#71-determine-beneficiary-transaction)
  - [7.2. Determine all channels](#72-determine-all-channels)
  - [7.3 Fetch channel results](#73-fetch-channel-results)
  - [7.4. Check transaction completion](#74-check-transaction-completion)
  - [7.4.1. Append typology result](#741-append-typology-result)
  - [7.4.2. Read transaction configuration](#742-read-transaction-configuration)
  - [7.4.3 Check typology triggers](#743-check-typology-triggers)
  - [7.4.3.1. Create/Update investigation case](#7431-createupdate-investigation-case)
  - [7.4.4. Write transaction results](#744-write-transaction-results)

# Introduction

The foundation of the Tazama Transaction Monitoring service is its ability to evaluate incoming transactions for financial crime risk through the execution of a number of conditional statements (rules) that are then combined into typologies that describe the nature of the financial crime that the system is trying to detect.

The Channel Router & Setup Processor (CRSP) is responsible for determining which channels and typologies a transaction must be submitted to for the transaction to be evaluated for Financial Crime Risk. As part of this process, the CRSP determines which rules must receive the transaction and then which typologies are to be scored. The CRSP routes the transaction to the individual rule processors.

The rules receive the transaction, as well as the portion of the Network Map that was used to identify the rules as recipients (and by association also identifies which typologies are beneficiaries of those rules’ results).

Each rule executes as a discrete and bespoke function in the evaluation process. Once a rule has completed its execution, it will pass its result, along with the transaction information and its Network sub-map to the Typology Processor where the rule result will be combined with the results from other rules as the results arrive to score a transaction according to a specific typology.

The Typology Processor is a single and centralised configuration-driven processing function that calculates a typology score for any and every typology in the platform based on the incoming rule results for a typology, the Network Sub-map that defines the rules that roll up into a typology and a typology logic statement or “expression” that defines how the rules are to be composed into a typology score.

Once each typology has been scored, the result of the typology will be passed to the Channel Aggregation and Decisioning Processor (CADProc) which will check each typology result as it is delivered for any immediate workflow triggers. All typology results for a specific channel will be combined by the CADProc into a single comprehensive channel result.

Once each channel has been completed, the result of the channel will be passed to the Transaction Aggregation and Decisioning Processor (TADProc). All channel results for a specific channel will be combined by the CADProc into a single comprehensive channel result and written to the database. The TADProc will alert the CMS of any typologies that warrant investigation.

# Transaction Aggregation and Decisioning Processor Context

![](../../../../images/Actio_TMS_TADP_Context.png)

**Figure**: *Tazama TMS Transaction Aggregation and Decisioning Context*

## 4. Submit rule results

The rule processor passes its completed result to the Typology Processor.

The rule result message includes the original transaction, the Network Sub-map and the rule execution result (Rule identifier, sub-rule identifier (for rule-sets), boolean rule result and result reason).

## 5. Submit typology results

Once calculation of the typology score is complete, the Typology Processor must pass the typology result, including the transaction information, Network Sub-map, typology results and rule results to the Channel Aggregation and Decisioning Processor (CADProc).

## 6. Submit channel results

If all typology results have been received and processed by the CADProc, the CADProc must pass the channel results, including the transaction information, Network Sub-map, channel trigger results, typology results and rule results to the Transaction Aggregation and Decisioning Processor.

## 7.1. Determine beneficiary transaction

**In scope for the MVP**

When the TADProc receives a channel result, the TADProc must interrogate the Network Sub-Map to identify which transaction in the Network Sub-map is the recipient (beneficiary) of the channel result.

## 7.2. Determine all channels

**In scope for the MVP**

The TADProc must again interrogate the Network Sub-Map to determine which other channels have been invoked that also has this transaction as a beneficiary. This step defines all of the constituent channels for which the transaction expects results before the transaction can be closed.

## 7.3 Fetch channel results

**In scope for the MVP**

For each channel identified as a constituent channel in 7.2, the TADProc must retrieve any previously cached channel results (if any) that had been received for the current transaction.

## 7.4. Check transaction completion

**In scope for the MVP**

Using the list of constituent channels determined in 7.2 and previously cached channel results (if any), the TADProc must check if all of the channel results specified in the Network Sub-map have now been received.

## 7.4.1. Append typology result

**In scope for the MVP**

If all of the channels specified in the Network Sub-map for the channel have not yet been received, the incoming channel result must be cached so that it can be retrieved at a future time when another channel result is received.

## 7.4.2. Read transaction configuration

**In scope for the MVP**

The channel architecture provides three specific opportunities to take action in response to a typology score:

1. During the scoring of the typology itself

2. During the aggregation of the typology score with other typology scores in the CADProc

3. During conclusion of the transaction evaluation in the TADProc

Where interdiction is required, either option 1 and 2 above is the most suitable to satisfy requirements for urgency and immediacy. Where interdiction is not required, evaluation of the typology is still required to determine if an investigation is warranted, but not as urgently. The evaluation for investigation purposes only can be performed in the TADProc on the conclusion of the transaction evaluation.

The purpose of step 7.3 is to allow for the creation of a case should any typology breach its review thresholds and only if interdiction (and associated case creation) is not in scope for the deployment.

The TADProc must retrieve the typology triggers from the Tazama configuration store so that the TADProc can determine if any of the typologies just received with the channel results warrant an investigation.

The typology triggers must define a specific threshold value linked to each of the typologies that defines the following workflow outcomes:

1. **Review**: If a typology score is equal to or greater than this value, the TADProc will trigger an alert to the Case Management System to initiate an investigation into the transaction.

2. **None**: If a typology score is less than the Review threshold, no triggered action is taken by the TADProc.

**From an MVP perspective**, we will not be implementing interdiction; however we will build the anchor points for interdiction into the CADProc. In the absence of interdiction, a fully functional transaction configuration for the TADProc will be developed to trigger investigations through the Case Management System.

Additionally, if a transaction configuration for a transaction cannot be found, or is empty, no investigation will be triggered out of the transaction.

## 7.4.3 Check typology triggers

**In scope for the MVP**

If all channel results had been received, evaluate each typology in every channel against the transaction configuration to determine if an investigation is required. The outcomes of the evaluation depends on the typology score against the defined thresholds and may be to create (or update) an investigation case, or to do nothing.

The evaluation outcome of a typology against its thresholds must be logged for each typology, i.e. that the typology was evaluated, what the threshold was, and what the determination was (Review, or None).

## 7.4.3.1. Create/Update investigation case

**In scope for the MVP**

If the typology score is equal to or greater than the review threshold defined for the typology in the TADProc configuration, the TADProc must trigger a review message to the case management system to flag the transaction for review.

The trigger message must contain the information required to identify the transaction and the typology that triggered the investigation.

Each typology that is triggered for review must be sent to the CMS. If multiple alerts are generated for a specific transaction, the CMS will resolve how to combine them into a single case.

## 7.4.4. Write transaction results

**In scope for the MVP**

If all channel results had been received and processed by the TADProc, the TADProc must write the channel results to the transaction history database, including the transaction information, Network Sub-map, transaction trigger results, channel trigger results, typology results and rule results.
