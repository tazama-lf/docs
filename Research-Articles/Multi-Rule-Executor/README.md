# Multi Rule Executor

Tazama has an event-director which forwards requests to one or many rules (depending on the configuration). In its current state, a single rule is a single deployment of the rule-executor - the difference being in the libraries that specify the rule logic (consult the rule-executor documentation). So if your configuration has 10 rules, one would need to deploy the 10 corresponding rule-executors for each rule.

The documents in this folder will explore options for a single deployment rule-executor that is capable of evaluating multiple rules' outcomes for a single request.