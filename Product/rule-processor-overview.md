Rule Processor Overview

The foundation of the Tazama Transaction Monitoring software is its ability to evaluate incoming transactions for financial crime behaviour through the execution of a number of conditional statements (rules) that render a boolean (True or False) result. Rule evaluations consider specific attributes of the incoming transaction and the historical behaviour of the transaction participants.

The Channel Router & Setup Processor (CRSP) is responsible for determining which typologies are applicable for a transaction. (Typologies are a way to describe a specific financial crime scenario.) As part of this process, the CRSP determines which rules must receive the transaction and then routes the transaction to these rules as the next step in the evaluation process.

The rules receive the transaction, as well as the portion of the Network Map that was used to identify the rules as recipients (and by association also identifies which typologies are beneficiaries of the rule results).

Each rule executes as a discrete and bespoke function in the evaluation process.

Once a rule has completed its execution, it will pass its result, along with the transaction information and its Network sub-map to the Typology Processor where the rule result will be combined with the results from other rules to score a transaction according to a specific typology.

Tazama is preconfigured with a number of rule processors, but these rule processors are not publicly accessible to hide them from prying, unscrupulous eyes. Uncontrolled access to rule processors, and the typologies they belong to, may allow fraudsters to reverse engineer the detection mechanisms that are designed to stop them. Tazama has provided one rule processor as publicly available example of a rule processor, and we will use this rule processor as a reference rule in our documentation.



