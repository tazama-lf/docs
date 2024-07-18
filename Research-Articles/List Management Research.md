## Story statement

**As an** Tazama system operator,
**I want** the system to block a transaction based on the evaluation of a blocking conditions against one of the transaction attributes regardless of the natural system evaluation outcome AND
**I want** the system to allow a transaction based on the evaluation of allow conditions against one of the transaction attributes regardless of the system natural system evaluation outcome and existing blocking conditions AND
**I want** the system to be able to even block allow conditions for a transaction based on the evaluation of immutable and fatal blocking conditions against one of the transaction attributes
**So that** the system can exert operational control over evaluations based on the outcome of business processes and prior evaluations

# Overview

#### Table of contents

[Introduction](#introduction)<br>

[Block lists](#block-lists)
 - [Basics](#basics)<br>
 - [Creation](#creation)<br>
 - [Utilization](#utilization)<br>
 - [Maintenance](#maintenance)<br>

[Allow lists](#allow-lists)
 - [Basics](#basics-2)<br>
 - [Creation](#creation-2)<br>
 - [Utilization](#utilization-2)<br>
 - [Maintenance](#maintenance-2)<br>

[Resolving block vs allow conflicts](#resolving-block-vs-allow-conflicts)

[The block evaluation workflow](#the-block-evaluation-workflow)

[Summary](#summary)

# Introduction

Tazama provides the capability to maintain multiple lists of referenceable information that can be used in rule processors to add specific logic outcomes to a typology.

We initially envisage 3 major types of lists to be managed through this functionality:

 - Allow lists - Entries in this list will result in an automated over-ride to allow behaviour that might otherwise be prevented.
 - Watch lists - Entries in this list will result in an additional exception process to alter default behaviour.
 - Block lists - Entries in this list will result in the suspension of processing that might otherwise be allowed.

Note that, in line with global trends, the terms whitelist and blacklist have been deprecated and are no longer in use. Whitelists will henceforth be known as "allow" lists and blacklists will be known as "block" lists.

In some instances, a specific entry may appear on multiple lists. In such cases, and in particular where an entry is defined on both allow and a block lists, the default behaviour is to allow. This way, an allow action acts as the final (and often temporary) override for a block action. However, there is also an expectation that some blocks may not be overridden under any circumstances and the system would then need a mechanism to fatally block a transaction, regardless of an existing allow condition to prevent abuse or mistakes.

Entries in any list can be managed either automatically, as the result of an Tazama system process, or manually, via the ArangoDB API.

List management at large also includes the management of "watch" lists that offer the system an opportunity to reinforce the evaluation of participants for specific repeat behaviours, but watch lists have been determined to function in a very different way and can be implemented separately from block and allow lists, and also once customer requirements are more clear.

# Block lists

## Basics

An entry on a block list signifies that transactions related to that entry will not be allowed to occur.

![image](https://c.tenor.com/bIJa2uRURiQAAAAC/lord-of-the-rings-you-shall-not-pass.gif)

For example, if an end-user is defined on a block list, that end-user may not be allowed to perform any transactions. Or, if a person is specified on a sanctions list, and that entry is translated into an Tazama block list, that person may not be allowed open an account, or even create a user profile at all.

## Creation

An entry on a block list may be created via a system operator's process, external to the Tazama system. The Tazama system will provide endpoints in the ArangoDB API to allow the operator to implement the entry on internal Tazama block lists.

An entry on a block list may also be created by the Tazama system itself, as an outcome of a transaction evaluation. A block list entry will usually only be made in evaluations that result in the interdiction of the requested transaction. For instance, a client may be performing a transaction where the evaluated risk of account take-over is so high that the account is blocked until the appropriate remediation is performed (such as the issuing and successful resolution of a Multi-Factor Authentication request).

## Types of block conditions

We envisage a number of different types of block conditions:

1. **Direct block**: The specific entity is blocked from performing some or all system activities via a block flag set on the entity record in the Tazama History Graph. Block flags may be set on Entities and Accounts. The flags are specified as part of the graph data model and if the model is expanded with information on, say, FSPs or payment methods, flags can be attached here as well.
2. **Indirect block**: The specific entity is blocked from performing an activity because it contains an attribute that is listed on a block list. For example, the ability for any entity transacting from an embargoed country is blocked by implementing a block against certain values of the entity's country of origin property.
3. **Inherited block**: There is a specific hierarchy to the objects within the Tazama system. For example, an entity/account-holder has an account. If a block has been implemented against the entity/account-holder for certain activities, the entity/account-holder should not be able to perform those activities through their accounts either.

## Utilization

Once an entry has been created in a block list, it is expected that the presence of the entry should affect default system behaviour to prevent specific actions.

The blocking of a transaction via a block list may result in an override of Tazama's default behaviour. For example, the Typology Processor may determine that a transaction should be allowed to proceed, but the outcome of a block evaluation would determine that the transaction should be blocked. Even if the Typology Processor determines that a transaction should be interdicted, the outcome of a block evaluation would override the interdiction process with a pre-emptive block.

For this purpose the block evaluation outcome should be submitted to each typology as an additional and slightly different outcome to normal rules evaluation, and should deliver a typology result that can be actioned separately from the regular rules evaluation of the transaction, without discarding the original, regular typology result completely.

It is also important to define a predictable hierarchy of outcomes for the typology processor. Proposed for the MVP deliverable of block list functionality is the following hierarchy:

Block > interdict > alert > proceed

Functionally there's no difference in the impact on the transaction between a block and an interdiction, but it is important to note the difference so that the system operator can always see why something was blocked.

![image](https://github.com/frmscoe/General-Issues/assets/123470803/139114b2-34cc-4df2-ba2d-17388d5c81f7)

## Maintenance

Whereas adding an entry on a block list may be through either operator (external) processes or Tazama (internal) processes, removing an entry from a block list should be wholly the result of an external process via the ArangoDB API. It is expected that clearing an item from a block list would be the result of an investigation, perhaps, or the remediation of the circumstances that resulted in the blocking in the first place.

# Allow lists

## Basics

An entry on an allow list signifies that transactions related to that entry will be allowed to occur, regardless of the outcome of any evaluation.

![image](https://i.imgur.com/sEvn4xh.gif)

For example, if an end-user is already listed on a block list, that end-user may not be allowed to perform any transactions. But, if the end-user is simultaneously on an allow list, the end-user will be able to perform transactions after all, for as long as the end-user is specified on the allow list. This is, in reality, a terrible example. It would be better if the business processes that placed the end-user on the block list are resolved so that the end-user is actually removed from the block list, but this example serves to illustrate the power of the allow list, and also how it must be handled with the utmost caution and discretion.

The allow list provides a mechanism that allows an Tazama operator to override the automated blocking of a transaction, especially when the block is as a result of a false-positive evaluation outcome, at least until the circumstances resulting in the false-positive outcome is resolved.

## Creation

An entry on an allow list may only be created via a system operator's processes, external to the Tazama system. The Tazama system will provide endpoints in the ArangoDB API to allow the operator to implement the entry on internal Tazama allow lists.

As an example, an allow list entry might be the outcome of an end-user complaint regarding repeated interdicted transactions. An initial investigation determines that the end-user is not at fault, but the rules and typologies that are flagging the end-user for interdiction may need to be updated to resolve the false-positive outcome on their own. The recalibration of the system will take some time, and the end-user, and the operator's customer experience, should not needlessly suffer any further delays.

An entry on an allow should never be inserted by the Tazama system directly, and certainly not automatically under any circumstances.

## Types of allow conditions

We envisage a number different types of allow conditions:

1. **Direct allow**: The specific entity is allowed to perform specified system activities via an allow flag set on the entity record in the Tazama History Graph. Allow flags may be set on entities/account-holders and accounts. As the graph data model expands, flags may be set on additional nodes.
2. **Point-to-point allow**: The specific entity is allowed to perform a specified activity involving a specific other entity. For example, an account is able to transact with a single other account for a limited time.
3. **Inherited allow**: There is a specific hierarchy to the objects within the Tazama system. For example, an entity/account-holder has an account. If an allow condition has been implemented against the entity/account-holder for certain activities, the entity/account-holder should be able to perform those activities through their accounts as well.

## Utilization

Once an entry has been created in an allow list, it is expected that the presence of the entry should affect default system behaviour to always allow specific actions.

The typology processor expects to receive a final block or allow outcome, determined in a previous rule-based evaluation.

As with a blocking outcome, the allowing of a transaction via an allow list may result in an override of Tazama's default behaviour. For example, the Typology Processor may determine that a transaction should be interdicted, but the outcome of a block evaluation would determine that the transaction should be allowed.

For this purpose the block evaluation outcome should be submitted to each typology as an additional and slightly different outcome to normal rules evaluation, and should deliver a typology result that can be actioned separately from the regular rules evaluation of the transaction, without discarding the original, regular typology result completely.

It is also important to define a predictable hierarchy of outcomes for the typology processor. Proposed for the MVP deliverable of allow list functionality is the following hierarchy:

Allow > interdict > alert > proceed

![image](https://c.tenor.com/b30WqILuGhgAAAAC/wait-a-minute-nevermind.gif)

Hmmm. Here we have a bit of a quandary.

If we followed our established pattern for rule-result-to-typology-aggregation, we would feed the result of the allow list evaluation to the typology processor where it would be used to negate a typology's unadulterated outcome. The most straight-forward way to achieve this negation would be to use the allow list outcome as a zero-multiplier to the typology score: no score, no alert. Unfortunately this method is indiscriminate, and terminal. We would not be able to see what the typology score would otherwise have been, and we would also not be able to block the transaction for the same typology for reasons other than the scope of the allowed condition.

For example, let's say that the debtor's account is on an allow list. But it is, in fact, the general behaviour of the debtor themselves that is causing the interdiction. Should the amnesty afforded via the debtor's account be applied to the transaction when the debtor is the problem?

It seems unwise to grant blanket amnesty to a transaction based only on _some_ of the attributes evaluating to an allow override, while other attributes may result in an interdiction.

Allow overrides are a very powerful tool in changing default system behaviour and as such is also open to abuse, either to solve operational problems, or by compromised internal users.

To mitigate the impact of indiscriminate allow overrides, allow conditions must be limited in scope and specifically time-boxed. Blanket amnesties for entities should be avoided in favour of deliberate targetted overrides. For example, instead of allowing an entity/account-holder to perform any transaction, it would be preferable to only allow the entity/account-holder to perform a transaction from one specific account to another specific account.

## Maintenance

Removing an entry from an allow list should be wholly the result of an external process facilitated via the ArangoDB API. It is expected that clearing an item from an allow list would be the result of the remediation of the circumstances that resulted in false-positive evaluation outcomes in the first place.

It is recommended that allow list overrides should be strictly time-boxed and the Tazama system could enforce this limitation automatically.

# Resolving block vs allow conflicts

Conflicting block and allow outcomes should be resolved prior to the outcome being sent to the typology processor. In other words, the typology processor should receive a single unambiguous instruction to either block or allow.

If various block evaluations are performed in individual single-purpose rules, and allow evaluations are also performed in individual single-purpose rules, the Tazama system requires an additional "Arbitration Processor" to determine the combined effect of block and allow outcomes before sending the outcome to the typology processor.

![image](https://github.com/frmscoe/General-Issues/assets/123470803/affdf8fa-a2e3-4b1a-9e5f-efdd1e6fab73)

It is also important to define a predictable hierarchy of outcomes for the arbitration processor. Proposed for the MVP deliverable of list functionality is the following hierarchy:

Non-overridable (hard) block > Allow > Overridable (soft) block

A non-overridable block is required to define a hard, immutable and fatal block of an entity within the system, regardless of related circumstances. Consider the following example:

A customer is blocked (permanently banned) on the FSP's network and prevented from transacting. A typology evaluation renders a series of interdictions against the FSP's customers that are determined to be false-positive outcomes. The compliance officer decides to temporarily allow all transactions from the FSP via an allow override while the rules and typologies are reviewed and updated. Without the non-overridable block feature, the allow override at the FSP level would allow the previously blocked entity/account-holder to transact via an inherited allow override.

# The block evaluation workflow

![image](https://github.com/frmscoe/General-Issues/assets/123470803/5e47c9f3-ccd5-43a5-b4ea-8510f9fdaeb0)

In the diagram above, the state of every attribute that can influence the flow control of a transaction is evaluated for both the debtor and the creditor in a transaction. This may include the creditor/debtor accounts, the debtor/creditor themselves, their FSPs, their identifying KYC information, etc. Flow control can be determined on any attribute that has a flow control condition (block or allow) attached.

The various blocking types do not necessarily have to evaluated in sequence and some concurrency in the evaluating processor will assist in performing the evaluations simultaneously. Whether sequentially or simultaneously, the outcome of the evaluation would be a single result: should the transaction be blocked or allowed.

This outcome must be ingested into the typology processor. The flow evaluation outcome is specifically intended to override the system's natural determination _without altering it_. In other words and for example, if the flow control evaluation determines to allow a transaction, but the typology scoring determines an interdiction, the interdiction result should still be carried forward to the TADProc and alerted, but the interdiction itself should not be performed by the typology processor.

Furthermore, for the reason outlined earlier, if the flow control evaluation is not integrated into the typology processor result, the execution of the typology processor result would have to be implemented wherever the flow control evaluation result is integrated. For instance, if we collected interdicting transactions into a separate channel, then the flow control evaluation will have to be integrated into the channel processor in order to override the outcome of a group of typologies at once, but in this case we lose the ability to interdict a transaction immediately on the first typology that generates such an action.

If only some typologies may be influenced by the flow control outcome, it may be better to create a specialised flow control/interdicting typology processor instead that can override the natural (interdicting) outcome of a typology directly. This way non-interdicting typology performance would not be impeded by unnecessary evaluations; however we would still want to be able to block a transaction by merging a blocking outcome with the typology's natural allow outcome, effectively turning a non-interdicting typology into an interdicting typology by override. The only processing effort we are then actually saving is natural interdicting decisioning by the non-interdicting typology processor: this doesn't seem to warrant a completely separate processor.

# Summary
1. For now, flow control attributes will be set via the ArangoDB API. No flow control attributes will be set automatically based on system evaluation outcomes until required for a specific implementation and customer requirements are clear.
2. A new "core" processor is required to determine whether a transaction should be blocked or allowed. While unique in function compared to existing behavioural rule processors, this new processor will be integrated into the rule processor plane.
3. The result of the flow control "rule" processor will be integrated into the typology processor so that the typology processor will retain the ability to interdict a transaction immediately, if required, but this interdiction can also be overridden without altering the original outcome.
4. The initial implementation should cover, at least, direct hard and soft block conditions, as well as direct allow conditions; however the implementation should allow for future expansion to also cater for indirect, inherited and point-to-point conditions.

![image](https://github.com/frmscoe/General-Issues/assets/123470803/4389675d-2514-4b93-b9fc-d009aac8e496)

We have not yet covered the specification of flow control attributes and where these will be hosted. In the current system database architecture, this specification of conditions can be performed in one of two ways: we can either create explicit attribute-linked "lists" of values with blocked and/or allowed statuses, or we can integrate the blocking mechanism into the graph database as new edge collections attached to specific nodes. The latter solution will only be viable where the flow control attributes are nodes in the graph, but this approach may be marginally more performant for those entities and will make the determination of inherited conditions easier.

## Acceptance criteria
1. [How will we know that the feature is completely and correctly implemented?]
