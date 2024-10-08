<!-- SPDX-License-Identifier: Apache-2.0 -->

###### Top

## Tazama Demo UI Guide <!-- omit in toc -->

#### Table of Contents <!-- omit in toc -->

- [Introduction](#introduction)
- [Landing page](#landing-page)
- [Create debtors and creditors](#create-debtors-and-creditors)
- [Transpose debtors and creditors](#transpose-debtors-and-creditors)
- [Create and send transactions](#create-and-send-transactions)
- [Evaluation result dashboard overview](#evaluation-result-dashboard-overview)
    - [Event Director (ED) Panel Overview](#event-director-ed-panel-overview)
    - [Rules Panel Overview](#rules-panel-overview)
    - [Typology Panel Overview](#typology-panel-overview)
    - [TADPROC Panel Overview](#tadproc-panel-overview)
- [Evaluation result dashboard analysis](#evaluation-result-dashboard-analysis)
    - [Rule Panel Analysis](#rule-panel-analysis)
    - [Typology Panel Analysis](#typology-panel-analysis)
- [UI Configuration](#ui-configuration)

## Introduction

The purpose of this guide is to explain how to use the Tazama Demo User Interface (UI).

The Tazama system is provided as a software engine and as such is generally implemented as a back-end service that taps into transaction flows. As such, demonstrating the software features and capabilities with a visually appealing narrative is challenging. To date, demonstrations have relied on API-simulations via Postman, or simply slideshows. This demo app has been created to be able to demonstrate the system's capabilities.
 
The basic narrative of the demo is to set up a number of light-weight identities and then simulate transactions from a debtor to a creditor via a mocked up mobile device interface. The user interface then reports the outcomes of the various system processes for rule and typology evaluation, and then allow the narrator to highlight interesting elements of the evaluation outcomes, such as the result of a specific rule, the composition of a typology and the outcome of the typology scoring, and whether a transaction is blocked or whether an investigation alert was raised.

For more information on the Tazama system, see the [Product Overview](https://github.com/frmscoe/docs)

#### Display Format <!-- omit in toc -->
The Tazama Demo UI is desgined to be browser-based and presented in a single-page 'dashboard' in full HD (1080p) or greater resolution with an aspect ratio of 16:9.

## Landing page

The demo opens on the following page

 ![demo-landing-page](../images/demo-landing-page.png)

The UI is instantiated with a pre-fabricated debtor and creditor and associated accounts. When an entity is created, one associated account is also created. The UI has space for 4 debtor entities and 4 creditor entities and 4 accounts each.

The system configuration is read from an environment file when the UI starts up so that the layout of rules and typologies are built dynamically to match the system's current configuration.

## Create debtors and creditors

![create-entity](../images/demo-create-entity.png) Click on this icon to replace a pre-fabricated entity with a new randomized entity, and to create up to 4 debtors and creditors.

Click on plus icon to create a new account, creating up to 4 accounts per entity with randomized information.
![create-account](../images/demo-create-account.png)  

To delete an entity (debtor or creditor), hover over the entity or it's accounts and click on the dustbin icon that appears on the right.
![delete-entity](../images/demo-delete-entity.png)  

To edit an entity (debtor or creditor) or an account, click on the edit icon 
![edit-entity-account](../images/demo-edit-entity-account.png)  

On the entity pop-up modal it is possible to edit the Full name, Birth Date, City of Birth, Country of Birth and Mobile number.
![edit-entity-info](../images/demo-edit-entity-info.png)  
Note: The mobile number format is validated according to the ISO20022 standard https://www.iso20022.org/standardsrepository/type/PhoneNumber

It is also possible to edit the Account Name on the account pop-up modal.
![edit-account-info](../images/demo-edit-account-info.png)

## Transpose debtors and creditors

It is possible to copy an entity from a debtor to a creditor role, or vice versa. This could be useful if the user wants to illustrate a number of transactions where the debtor's or the creditor's role in the transactions is reversed. For example, for some transactions, the debtor has to first receive a number of transactions before making a payment that is then indicative of anomalous behaviours.

In the first scenario below, Alice is the debtor and Electra is the creditor.
![transpose-start](../images/demo-transpose-1.png)

By clicking on Alice (anywhere on the debtor entity or account icons) and dragging the debtor across to the creditors panel, the debitor Alice becomes a creditor, or vice versa.
![transpose-end](../images/demo-transpose-2.png)

[Top](#top)

## Create and send transactions

The user can compose a transaction between selected debtor and creditor accounts by clicking on the `new transaction` button and submitting the transaction for evaluation by clicking on the `send` button. The transaction is submitted to the Tazama TMS API and the evaluation process is being triggered. The flow of the transaction is tracked visually on the UI dashboard.

![new-transaction](../images/demo-new-transaction.png)
Each click on the `new transaction` button replaces the transaction details with a new randomized transaction.

Click on the `edit` icon to change the transaction details manually.
![edit-transaction-1](../images/demo-edit-tx-button.png)

The Amount, Description and Latitude & Longitude can be edited and saved.
![edit-transaction](../images/demo-edit-transaction.png)

When the `SEND` button is clicked, the UI composes and posts the pacs.008 message to the Tazama TMS API, waits for a success (200 OK) response from the API, and then composes and posts the pacs.002 message to the Tazama TMS API, after which the UI renders the evaluation results from every processor involved in the evaluation.
![send-transaction](../images/demo-send-button.png)

[Top](#top)

## Evaluation result dashboard overview
The images used in the examples below are from a scenario where two transactions are performed, with the same debtor and creditor, soon after each other.

#### Event Director (ED) Panel Overview
![ed-panel](../images/demo-ed-panel.png)

- When the UI receives a 200 OK response from the Tazama TMS API after the submission of the pacs.008 message, the ED light is set to orange
- When the UI receives a 200 OK response from the Tazama TMS API after the submission of the pacs.002 message, the ED light is set to green
- If either the pacs.008 or pacs.002 messages renders a response other than 200 OK, the ED light is set to red

![ed-panel-error](../images/demo-ed-panel-error.png)
In this case, the UI is attempting to send the exact same transaction that has just been sent.  Click on `New Transaction` to generate a new transaction.

[Top](#top)

#### Rules Panel Overview
![rules-panel](../images/demo-rules-panel.png)

Each rule processor will publish its results onto its own NATS subject to which the UI will be subscribed. When the rule result is published by the rule processor, the UI reads and interprets the rule result and updates the rule processor's corresponding light on the dashboard.  

The colour of the light is determined by whether or not the specific rule result reference defined by the subRuleRef value in the rule result is assigned a weighting by the typology processor for ANY typology.
- If the ruleResult is assigned a weighting greater than 0, the rule light is set to red
- If the ruleResult is assigned a 0 weighting, the rule light is set to green
  
[Top](#top)

#### Typology Panel Overview
![typology-panel](../images/demo-typology-panel.png)

The typology processor publishes a typology result for each completed typology onto the TADProc's NATS subscription subject to which the UI is subscribed. When the typology result is published by the typology processor, the UI reads and interprets the typology result and updates the typology's corresponding light on the dashboard. 

- If the typology result value is less than alert threshold value, the typology light is set to green
-  If the typology result value is greater than or equal to the alert threshold value, but less than the interdiction threshold value (if it exists), the typology light is set to orange
- If the typology result value is greater than or equal to the interdiction threshold value (if it exists), the typology light is set to red
  
[Top](#top)

#### TADPROC Panel Overview
![tadproc-panel](../images/demo-tadproc-panel.png)

The Transaction Aggregation and Decisioning Processor (TADPROC) publishes a completed evaluation result onto the TADROC's publishing/CMS subscription subject on NATS to which the UI is subscribed. When the evaluation result is published by the TADProc, the UI reads and interprets the evaluation result and updates the TADProc light on the dashboard. 
- If the report status is `ALRT` (alert), the TADProc light is set to red
- If the report status is `NALT` (not alert), the TADProc light is set to green

![tadproc-panel](../images/demo-tadproc-red.png)

If the report status is `ALRT`, a `stop` sign is displayed between the debtor and credit mobile devices indicated that the transaction should be interdicted.
![result-stop](../images/demo-result-stop.png)

[Top](#top)

## Evaluation result dashboard analysis

#### Rule Panel Analysis
The user can hover over a specific rule light or number to temporarily display a summary of the rule result. In the example, below the cursor is hovering over rule 008, as can be seen by the light grey highlight, and the rule result panel for rule 008 pops up on the right of the list of rules.
![rules-panel-analysis](../images/demo-rules-panel-analysis.png)

In this case, rule 008 light is red and shows the rule result weighting of 200, while any of the green rule lights show a rule result of zero. In addition to displaying the rule weighting, the rule description, subruleref (.02) and its description is also displayed in the rule result modal.
![rule-result-red](../images/demo-rule-result-red.png)

While hovering over a specific rule light to temporarily display a summary of the rule result, the typologies in which the rule result is consumed are also simultaneously temporarily highlighted.  In the example below, while hovering over rule 008, typologies 024, 026 and 095 are highlighted in light grey.
![rules-hover-typology](../images/demo-rules-hover-typology.png)

If the user hovers over a rule light, the information is displayed temporarily, but not persisted. In other words, when the user hovers somewhere else that is not a rule light, the previous selected state is restored. If the user clicks on the rule light or description the selected state is displayed persistently. In the example below, after clicking on rule 008, typologies 024, 026 and 095 are highlighted in a darker shade of grey.
![rules-click-typology](../images/demo-rules-click-typology.png)

Once a state is persisted by clicking on a rule, hovering over other rules, highlights the typologies that depend on the second rule result, in a lighter shade of grey.  In this case, hovering over rule 030 (after clicking on rule 008), highlights typologies 037, 047, 105, 044, 045, 214 in a lighter shade of grey.
![rules-hover-typology2](../images/demo-rules-hover-typology2.png)

[Top](#top)

#### Typology Panel Analysis

The user can hover over a specific typology light to temporarily display a summary of the typology result. In the example, below the cursor is hovering over typology 095, as can be seen by the light grey highlight, and the typology result modal for typology 095 pops up on the right of the list of typologies.
![typology-panel-analysis](../images/demo-typology-panel-analysis.png)

In this case, typology 095 light is red, and the typology result panel shows the typology result of 800, an alert threshold of 500 and an interdiction threshold of 600.
![rule-typology-red](../images/demo-typology-result-red.png)

While hovering over a specific typology light to temporarily display a summary of the typology result, the rules which contribute to the typology result are simultaneously highlighted.
In the example below, while hovering over typology 095, rules 006, 007, 008, 024, 026, 074 and 075 are highlighted in light grey.
![typology-hover-rules](../images/demo-typology-hover-rules.png)

If the user hovers over a rule light, the information is displayed temporarily, but not persisted. In other words, when the user hovers somewhere else that is not a rule light, the previous selected state is restored. If the user clicks on the rule light or description the selected state is displayed persistently. In the example below, after clicking on typology 095, rules 006, 007, 008, 024, 026, 074 and 075 are highlighted in a darker shade of grey.
![typology-click-rules](../images/demo-typology-click-rules.png)

Once a state is persisted by clicking on a typology, hovering over other typologies, highlights the rules that contribute to the second typology result, in a lighter shade of grey.  In this case, hovering over typology 024 (after clicking on typology 095), highlights rules 002, 016, 017, 021, 025, 027, 054, 063, 084, 090 091 in a lighter shade of grey.
![typology-hover-rules2](../images/demo-typology-hover-rules2.png)

[Top](#top)

## UI Configuration

Click on the `settings` icon to update the UI configuration variables 
![demo-settings-icon](../images/demo-settings-icon.png)

The `reset` button restores the settings back to the variables defined in the demo.env file. The settings can be manually edited and saved by clicking on the `update` button.
![configuration UI](../images/demo-config-ui.png)

[Top](#top)







 






