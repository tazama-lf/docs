# Product Overview

- [Product Overview](#product-overview)
  - [What is Tazama](#what-is-tazama)
  - [Understanding Typologies and Rules](#understanding-typologies-and-rules)
  - [Solution Components of Tazama](#solution-components-of-tazama)
    - [Transaction Monitoring Service API](#transaction-monitoring-service-api)
    - [Data Preparation (DP)](#data-preparation-dp)
    - [Channel Router and Setup Processor (CRSP)](#channel-router-and-setup-processor-crsp)
    - [Rule Processors](#rule-processors)
    - [Typology Processor](#typology-processor)
    - [Channel Aggregation and Decisioning Processor (CADProc)](#channel-aggregation-and-decisioning-processor-cadproc)
    - [Transaction Aggregation and Decisioning Processor (TADProc)](#transaction-aggregation-and-decisioning-processor-tadproc)

## What is Tazama

Tazama is an Open Source solution built to support any Digital Financial Services Provider (DFSP) that requires Transactivon Monitoring. Whether that DFSP is a small provider running one or 2 transactions per day or a national payment switch running at over 3,000 Transactions per second. With it they can implement simple or complex rules, implement Fraud Detection controls or support Anti Money Laundering activities.

In the following pages, we intend to give you a clear understanding of the Product, and how all the components of the Architecture work together.

## Understanding Typologies and Rules

To help detect any financial crime we have an extensive list of Typologies. A classic example of a typology is a Phishing Scam - where a susceptible individual is phoned by someone claiming to be legitimately chasing a payment from the individual. For example a tax collection bureau alleging someone has failed to pay taxes and there is now an urgent demand or risk of prison.

By assessing the transfer to the fraudsters, it is possible to identify more high risk transactions. Such as an **elderly** person, sending a **large amount** of funds to a **new payee (or creditor)**. The three rules being assessed in this example are:

- Age
- Value of transaction
- Previous relationship with recipient

If the Fraudster recipient was the customer being monitored it is likely they will receive the funds, and quickly move it to the next person in their money laundering chain. This would be captured in a Layering Typology which would include **age of the account** or **dormant account suddenly becoming active** instead of age of the participant.

In the creation of a typology, it is worth highlighting that our phishing example can also create a false positive when a grandparent sends a large sum for an important life event to one of their grandchildren. Previously gifts had been sent via the parents and as such no historical financial relationship had been established. It is for this reason that a rule such as “allow-list of sender and receiver pairs” can be implemented. The typology will then assess if this transaction can be progressed because it is approved in the override request. It is worth noting that a diligent fraudster would look to circumnavigate this control by sending a small transaction that would be allowed, and then moving larger amounts once the history had been established. It is therefore important that an understanding of the customers in a given DFSP is developed, as finding the balance of low false positives and managing the activity of fraudsters “testing the boundaries” are critical to the success of an implementation.

Further information on Typologies and the approach adopted are available from the Mojaloop convening. Just after 7 minutes and 35 seconds in [this video](https://youtu.be/6bjQoEAM8XI?list=PLhqcvNJ3bJt7U8ab05ayGv16-6n5jZOH2&t=459) there is a recap of the APRICOT model.

## Solution Components of Tazama

The Tazama solution has a number of key components that have been selected and architected to allow maximum flexibility, ensure data protection, and reduced Operational Costs. They are the:

- Transaction Monitoring Service API
- Data Preparation
- Channel Router and Setup Processor (CRSP)
- Rules Processor
- Typology Processor
- Channel Aggregator and Decision Processor (CADProc)
- Transaction Aggregator and Decision Processor (TADProc)

![end_to_end_flow](../../Images/end_to_end_flow.png)

### Transaction Monitoring Service API

The Transaction Monitoring Service (TMS) API is the point of interaction for the DFSP. It has been designed to support ISO 20022 compliant transaction messages to give implementers the confidence that, as the world's payments and transfers move to ISO 20022, the platform is already designed to support them.

To ensure that only authorised data is received, calls to the API are authenticated. This authentication is done by the keyCloak (an external open source identity and access management solution) which is exposed to the DFSP as the TMS is hidden behind a firewall. This approach gives the flexibility for the platform to be deployed independently or inside the DFSPs infrastructure.

Once the submitter has been authenticated, the message contents are then validated, to ensure that only valid messages are processed. Once the message is cleared it is then sent on for Data Preparation.

As the Minimum Viable Product of Tazama has been built for the Mojaloop Payment Switch, a subset of the ISO 20022 messages are currently supported. In Mojaloop, the QUOTES messages are expected to be translated to pain.001 (POST) and pain.013 (PUT) and the TRANSFER messages are translated to pacs.008 (POST) and pacs.002 (PUT). It is expected that the Tazama platform will be prefaced with a Payment Platform Adapter to transform non-ISO 20022 messages, such as the ones used by Mojaloop, into the ISO 20022 format required by the TMS API. The Payment Platform Adapter is not in scope for the Tazama MVP.

Further information on the role of the TMS API is available on the [Transaction Monitoring Service API](./product-overview/transaction-monitoring-service-api.md) page.

### Data Preparation (DP)

In the data preparation phase, we address some of the challenges and risks in the various data sources received. The challenges include the unambiguous identification of the person who is performing a transaction (resolved through entity resolution - see [Entity Resolution Explained](./product-overview/data-preparation/entity-resolution-explained.md) for a detailed overview), while the risks include the exposure of customer personally identifiable information (PII) during a data breach (resolved through pseudonymisation - see [Pseudonymisation of customer data](./product-overview/data-preparation/pseudonymisation-of-customer-data.md) for a detailed overview).

Customer PII is intended to be protected through pseudonymisation as early in the process as possible and is the first step in data preparation. Pseudonymisation was not implemented exhaustively in the Tazama MVP. The only information that is being pseudonymised is the combination of fields that make up the account information for the debtor and the creditor:

- The account-holding DFSP
- The account identifier type
- The account identifier

The underlying information is deducted from the transaction record and replaced with the pseudonym, which allows us to continue processing but have reduced the risk of exposing this particular PII.

Entity resolution also offers quasi-pseudonymisation where customer PII information such as the name and date of birth is distilled to a unique identifier which can be used to reference the customer across the platform, though the underlying information is, to date, still exposed in the transaction record. The underlying name information can be deducted from the transaction record, if required, though the date of birth data is required for downstream processing.

Once pseudonymisation of the account information is complete, we resolve the transaction debtor and creditor into unique entities. The resolution part of the entity resolution process aims to determine if a new (prospective) entity is the same entity that had been introduced to the ecosystem previously, or if an entity is indeed a brand new entity. Effective entity resolution relies on what could be called the “big five” attributes of entity resolution: Date of Birth, Nationality, Identity Information, Name and Location. We use the combination of these attributes to match entities, though the only reliable information available to the entity resolution out of a Mojaloop Switch is the date of birth and the name.

Given not all key information is held within an ISO20022 message, there is the option to enrich the data stream at this stage. The project included a proof of concept for enrichment using United Nations Sanctions data, but no enrichment was implemented in the final release.

The message history is saved and the various transaction network graphs are updated before the transaction is sent on to the Channel Router and Setup Processor (CRSP) to commence the transaction evaluation.

Further information on the role of Data Preparation is available on the [Data Preparation](01-Data-Preparation.md) page.

### Channel Router and Setup Processor (CRSP)

The Channel Router & Setup Processor (CRSP) is responsible for determining which channels and typologies a transaction must be submitted to for the transaction to be evaluated for Financial Crime Risk. As part of this process, the CRSP determines which rules must receive the transaction and then which typologies are to be scored. The CRSP routes the transaction to the individual rule processors.

A channel is a virtual construct that serves as a way to group typologies into specific "themes" according to the operational requirements of the client. Channels can be themed for interdiction (typologies requiring an urgent Go/No Go decision) or set up to separately contain fraud and money laundering typologies. Channels allow for more expensive resources to be assigned to higher priority tasks.

Channel creation and transaction routing is configurable through a network map that is interpreted in the Channel Router and Setup Processor to invoke rules and typologies within configured channels. Rules and typologies can be updated or new versions added to the platform through configuration by only making changes to the network map.

Further information on the role of the Channel Router and Setup Processor (CRSP) is available on the [Channel Router and Setup Processor (CRSP)](../Product/02-Channel-Router-And-Setup-Processor-Crsp.md) page.

### Rule Processors

A rule processor is designed to address a singular scenario, but its output might be used by multiple typologies. For example a check on the age of the account, when the risk of having accepted a rogue actor as a customer is higher, will be used in more than one typology. This approach reduces the overall impact of combining a rule and typology into a singular function as each typology risks repeating the requests (in this example the age of the account) for the same transaction.

A rule can be used to assess more than one outcome, such as age bands if needed, as the same source data is used the only variable in the calculation.

Rule processors are templated so that logging, data input, determined outcomes, data output and telemetry are consistently applied by all rule processors. It is just the specific rule’s logic, including the queries that retrieve transaction history according to the rule requirements, that changes between rules. Currently all rules must be developed individually, but the parameters used in the calculation of a rule and its outcomes are contained in a configuration file. The rule behaviour can be configured outside of the rule code, reducing the operational burden for modifying a rule to a configuration process.

Once the rule has completed its evaluation, the output is forwarded to the Typology Processor.

Further information on the role of the Rules Processor is available on the following page [Rule Processor Overview](../Product/03-Rule-Processor-Overview.md)

### Typology Processor

The typology processor is designed to aggregate and assess the outcomes from the all rules within the scope of a specific typology. The scope of a typology is defined in a typology configuration specific to each typology. The typology processor scores the combined effect of a typology’s rules to determine if the weighted aggregation of the rule outcomes has reached a predefined threshold for raising a fraud or money laundering alert. Each rule’s weighted contribution to the typology score, as well as the scoring predicate, or sum, is also defined in the typology configuration.

Returning to our earlier example of a phishing scam where rules are implemented to assess an **elderly** person, sending a **large amount** of funds to a **new payee (or creditor)**. The three rules being assessed in this example are:

- Age

- Value of transaction

- Previous relationship with recipient

With the output from these rules (and more, to reduce false positives) an assessment is made as to the likelihood of the DFSP customer falling victim to a phishing scam. The explicit identification of the contributing rules will later be able to assist a Financial Crime Analyst in investigating suspicious behaviour, but also in the reduction of unnecessary investigations.

If a suspicious transaction is identified, there are a number of actions that can be considered. If the transaction is considered:

- High risk - the transaction can be interdicted (blocked) immediately, with a call out to the DFSP transacting and/or case management platforms;

- Moderate risk - an investigation alert created immediately;

- Low risk - the transaction will pass without intervention, but the evaluation outcome will be stored for future retrieval.

Note that interdiction has not been deployed for the MVP release.

Once completed the typology result is forwarded to the Channel Aggregation and Decisioning Processor (CADProc).

Further information on the role of the Typology Processor is available on the [Typology Processing](../Product/05-Typology-Processing.md) page.

### Channel Aggregation and Decisioning Processor (CADProc)
[Typology Processing](../Product/05-Typology-Processing.md)
With different typologies split across a number of channels, we start the consolidation process by aggregating the results from the typologies in a single channel. This approach allows us to send a “go” decision based on a specific channel’s results. For an interdicting channel, if all interdicting typologies are clear, the transaction can be released without having to wait for all channels to complete processing. Remember that the “no go” (interdicting) action will be taken by the typology processor.

Further information on the role of the Channel Aggregation and Decisioning Processor (CADProc) is available on the [Channel Aggregation and Decisioning Processor (CADProc)](../Product/06-Channel-Aggregation-And-Decisioning-Processor-Cadproc.md) page.

### Transaction Aggregation and Decisioning Processor (TADProc)

The final assessment step is to consolidate all the results from all the channels and persist the results by writing the transaction evaluation results to the database. The complete results can also be routed to a Case Management System via an egress API. The Tazama platform does not currently integrate with an existing Case Management System, but does have the capability to submit the transaction evaluation results in JSON format to an external platform. An implementer will be able to use this JSON output to pass an alert to their existing Case Management or Ticket Management systems.

Further information on the role of the Transaction Aggregator and Decision Processor (TADProc) is available on the [Transaction Aggregation and Decisioning Processor (TADProc)](../Product/07-Transaction-Aggregation-And-Decisioning-Processor-Tadproc.md) page.
