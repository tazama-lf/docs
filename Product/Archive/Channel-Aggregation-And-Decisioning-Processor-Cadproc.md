# Channel Aggregation and Decisioning Processor (CADProc)

- [Channel Aggregation and Decisioning Processor (CADProc)](#channel-aggregation-and-decisioning-processor-cadproc)
  - [Introduction](#introduction)
  - [Channel Aggregation and Decisioning Processor Context](#channel-aggregation-and-decisioning-processor-context)
    - [5. Submit typology results](#5-submit-typology-results)
    - [6.1. Determine beneficiary channel](#61-determine-beneficiary-channel)
    - [6.2. Determine all typologies](#62-determine-all-typologies)
    - [6.3 Fetch typology results](#63-fetch-typology-results)
    - [6.4. Read channel configuration](#64-read-channel-configuration)
    - [6.5. Check channel triggers](#65-check-channel-triggers)
      - [6.5.1. Send GO/NO GO instruction](#651-send-gono-go-instruction)
      - [6.5.2. Create investigation case](#652-create-investigation-case)
    - [6.6. Check channel completion](#66-check-channel-completion)
      - [6.6.1. Append typology result](#661-append-typology-result)
      - [6.6.2. Submit channel results](#662-submit-channel-results)

## Introduction

The foundation of the Actio Transaction Monitoring service is its ability to evaluate incoming transactions for financial crime risk through the execution of a number of conditional statements (rules) that are then combined into typologies that describe the nature of the financial crime that the system is trying to detect.

The Channel Router & Setup Processor (CRSP) is responsible for determining which channels and typologies a transaction must be submitted to for the transaction to be evaluated for Financial Crime Risk. As part of this process, the CRSP determines which rules must receive the transaction and then which typologies are to be scored. The CRSP routes the transaction to the individual rule processors.

The rules receive the transaction, as well as the portion of the Network Map that was used to identify the rules as recipients (and by association also identifies which typologies are beneficiaries of those rules’ results).

Each rule executes as a discrete and bespoke function in the evaluation process. Once a rule has completed its execution, it will pass its result, along with the transaction information and its Network sub-map to the Typology Processor where the rule result will be combined with the results from other rules as the results arrive to score a transaction according to a specific typology.

The Typology Processor is a single and centralised configuration-driven processing function that calculates a typology score for any and every typology in the platform based on the incoming rule results for a typology, the Network Sub-map that defines the rules that roll up into a typology and a typology logic statement or “expression” that defines how the rules are to be composed into a typology score.

Once each typology has been scored, the result of the typology will be passed to the Channel Aggregation and Decisioning Processor (CADP) which will check each typology result as it is delivered for any immediate workflow triggers. All typology results for a specific channel will be combined by the CADP into a single comprehensive channel result.

## Channel Aggregation and Decisioning Processor Context

![](../Images/image-20220901-144326.png)

### 5. Submit typology results

Once calculation of the typology score is complete, the Typology Processor must pass the typology result, including the transaction information, Network Sub-map, typology results and rule results to the Channel Aggregation and Decisioning Processor (CADProc).

### 6.1. Determine beneficiary channel

When the CADProc receives a typology result, the CADProc must interrogate the Network Sub-Map to identify which channel in the Network Sub-map is the recipient (beneficiary) of the typology result.

While it is conceivable that a typology may exist in multiple channels, for the purpose of the MVP we are restricting a typology to a single channel only.

### 6.2. Determine all typologies

The CADProc must again interrogate the Network Sub-Map to determine which other typologies have been invoked that also has this channel as a beneficiary. This step defines all of the constituent typologies for which the channel expects results before the channel can be closed.

### 6.3 Fetch typology results

For each typology identified as a constituent typology in 6.2, the CADProc must retrieve any previously cached typology results (if any) that had been received for the channel for the current transaction.

### 6.4. Read channel configuration

If interdiction is implemented, the CADProc must retrieve the channel triggers from the Actio configuration store so that the CADProc can determine if the typology just received requires an immediate response.

For a specified collection of typologies, if the typology score of each of the typologies is less than the Review threshold, the CADProc will trigger an immediate “proceed” notification to the workflow orchestrator to instruct the client system to go ahead with the transaction.

It is conceivable that the GO-list may contain different typologies that the NO-GO-list. In other words, we may find that a specific set of typologies, when evaluated together, provide enough information to allow a system to proceed with a transaction even if other typologies point out an interdiction. Actio may then issue conflicting triggers where one typology indicates interdiction and a set of different typologies may indicate an immediate proceed. The execution priority of the conflicting triggers must be determined by the client system operator during Actio implementation and may be:

1. **First come, first served**: If the interdiction trigger occurs before the proceed trigger, Actio will instruct the client system to interdict the transaction. If the converse occurs, the client system will be instructed to proceed with the transaction.
2. **Interdiction Priority**: All typologies in the list of interdicting typologies in the CADProc config must be received and evaluated before the set of GO typologies can be evaluated. If any typology indicates interdiction, the CADProc will immediately trigger an interdiction notification to the client system. Only once all interdictable typologies have been evaluated (and passed), only then will the list of “proceed” typologies be evaluated.
3. **Proceed Priority**: All typologies in the list of “proceed” typologies in the CADProc config must be received and evaluated before any interdicting typologies can be triggered. If a proceed notification is then issued, any subsequent interdicting notifications from subsequent typologies must be ignored, though an alert must still be issued to the Case Management System for investigation.

“Proceed Priority” is the recommended approach. Proceed priority will be required in situations where a temporary allow list can be used to over-ride an interdiction outcome.

If a channel configuration for a channel cannot be found, or is empty, no interdiction is required or will be performed in the channel.

### 6.5. Check channel triggers

If interdiction is implemented, the CADProc will evaluate the current typology against the channel configuration to determine if any immediate action is required. The outcomes of the evaluation depends on the typology score against the defined thresholds and may be to:

#### 6.5.1. Send GO/NO GO instruction

If the typology score is equal to or greater than the interdiction threshold defined for the typology in the CADProc configuration, the CADProc must trigger an interdiction message to the workflow engine to notify the client system to block the transaction.

The interdiction trigger message must contain the information required to identify the transaction and the typology that triggered the interdiction.

If the typology score is less than the interdiction threshold defined for the typology in the CADProc configuration AND all other interdicting typologies have been received AND no other typology has a typology score greater or equal to its Interdiction threshold, THEN:

If the typology is in a “proceed” set in the channel configuration AND all other typologies in the “proceed” set has been received AND all of the typologies in the “proceed” set has a score of less than the interdiction threshold set for the typology, THEN the CADProc must trigger a “proceed” message to the workflow engine to notify the client system to proceed with the transaction.

NOTE: Because of the dynamic nature of the network map, it is possible that a typology that is in the channel configuration as either an interdicting typology or in a “proceed” set has not been invoked for the current transaction. This is not an issue for the interdicting typology - the interdicting typology will simply never produce a result that will need to be evaluated. In the case of a “proceed set” the set will have to be trimmed to match the typologies that are actually present in the sub-map, otherwise the “proceed” set may hold up further processing while it waits for a result that will never arrive.

#### 6.5.2. Create investigation case

If the typology score is equal to or greater than the review threshold defined for the typology in the CADProc configuration, the CADProc must trigger a review message to the case management system to flag the transaction for review.

The trigger message must contain the information required to identify the transaction and the typology that triggered the investigation.

### 6.6. Check channel completion

Using the list of constituent typologies determined in 6.2 and previously cached typology results (if any), the CADProc must check if all of the typology results specified in the Network Sub-map have now been received.

#### 6.6.1. Append typology result

If all of the typologies specified in the Network Sub-map for the channel have not yet been received, the incoming typology result must be cached so that it can be retrieved at a future time when another typology result is received.

#### 6.6.2. Submit channel results

If all typology results have been received and processed by the CADProc, the CADProc must pass the channel results, including the transaction information, Network Sub-map, channel trigger results, typology results and rule results to the Transaction Aggregation and Decisioning Processor.
