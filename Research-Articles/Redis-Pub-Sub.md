# Redis Pub-Sub

- [Redis Pub-Sub](#redis-pub-sub)
  - [Design](#design)
    - [Producer scaling](#producer-scaling)
  - [Problems](#problems)
    - [Guaranteed delivery](#guaranteed-delivery)
    - [Subscriber scaling](#subscriber-scaling)
    - [Producer and subscriber scaling](#producer-and-subscriber-scaling)

## Design

### Producer scaling

![image](../images/Producer_scaling.png)

```plantuml
@startuml
participant "Channel Router Setup Processor" as crsp
participant "Rule Processor" as rp
participant "Rule Processor 2" as rp2
participant "redis" as r
participant "Typology Processor" as t
participant "Channel Aggreggation Decision Processor" as cadp

group Startup
    t -> r: Subscribe RuleResultChannel
end group

group Request 1
    crsp->rp: HTTP POST RuleRequest
    rp->r: PUBLISH RuleResultChannel RuleResult
    r->t: RuleResult
    r->rp: 1
    note over r, rp
      Number of TP's that 
      received the message 
    end note
    rp->crsp: Done
    t->cadp: HTTP POST TypologyResult
end group

group Request 2
    crsp->rp2: HTTP POST RuleRequest
    rp2->r: PUBLISH RuleResultChannel RuleResult
    r->t: RuleResult
    r->rp2: 1
    note over r, rp
      Number of TP's that 
      received the message 
    end note
    rp2->crsp: Done
    t->cadp: HTTP POST TypologyResult
end group
@enduml
```

## Problems

### Guaranteed delivery

![image](../images/Main_flow_and_Error_Handling.png)

```plantuml
@startuml
participant "Channel Router Setup Processor" as crsp
participant "Rule Processor" as rp
participant "redis" as r
participant "Typology Processor" as t
participant "Channel Aggreggation Decision Processor" as cadp

group Startup
    t -> r: Subscribe RuleResultChannel
end group

group Main Success
    crsp->rp: HTTP POST RuleRequest
    rp->r: PUBLISH RuleResultChannel RuleResult
    r->t: RuleResult
    r->rp: 1
    note over r, rp
    Number of clients that 
    received the message 
    end note
    rp->crsp: Done
    t->cadp: HTTP POST TypologyResult
end group

group #LightPink ALT TP Error
    crsp->rp: HTTP POST RuleRequest
    rp->r: PUBLISH RuleResultChannel RuleResult
    r->t: RuleResult
    r->rp: 1
    note over r, rp
    Number of clients that 
    received the message 
    end note
    rp->crsp: Done
    t->t: Internal Error
    note over t #Orange
    No guaranteed processing of Rule Result - 
    causes this transaction to never finish, 
    as Typology never finishes, as this Rule 
    Result was lost.
    end note 
end group
@enduml
```

### Subscriber scaling

![image](../images/Scale_Typology_Processor.png)

```plantuml
@startuml
participant "Channel Router Setup Processor" as crsp
participant "Rule Processor" as rp
participant "redis" as r
participant "Typology Processor" as t
participant "Typology Processor 2" as t2
participant "Channel Aggreggation Decision Processor" as cadp

group Startup
    t -> r: Subscribe RuleResultChannel
    t2 -> r: Subscribe RuleResultChannel
end group

group Main Success
    crsp->rp: HTTP POST RuleRequest
    rp->r: PUBLISH RuleResultChannel RuleResult
    r->t: RuleResult
    r->t2: RuleResult
    note over r, t2 #LightPink
    The same Rule Result is sent to 
    both Typology instances.
    end note
    r->rp: 2
    note over r, rp
    Number of TP's that 
    received the message 
    end note
    rp->crsp: Done
    t->cadp: HTTP POST TypologyResult
    t2->cadp: HTTP POST TypologyResult
end group
@enduml
```

### Producer and subscriber scaling

![image](../images/Producer_and_subscriber_scaling.png)

```plantuml
@startuml
participant "Channel Router Setup Processor" as crsp
participant "Rule-001" as rp
participant "Rule-002" as rp2
participant "redis" as r
participant "Typology Processor" as t
participant "Typology Processor 2" as t2
participant "Channel Aggreggation Decision Processor" as cadp

group Startup
    t -> r: Subscribe RuleResultChannel
    t2 -> r: Subscribe RuleResultChannel
end group

group Main Success
    crsp->rp: HTTP POST RuleRequest
    rp->r: PUBLISH RuleResultChannel RuleResult
    r->t: RuleResult
    r->t2: RuleResult
    note over r, t2 #LightPink
    The same Rule Result is sent to 
    both Typology instances.
    end note
    r->rp: 2
    note over r, rp
    Number of TP's that 
    received the message 
    end note
    rp->crsp: Done

    t->t: Not all rule \nresults received
    t2->t2: Not all rule \nresults received

    crsp->rp2: HTTP POST RuleRequest
    rp2->r: PUBLISH RuleResultChannel RuleResult
    r->t: RuleResult
    r->t2: RuleResult
    note over r, t2 #LightPink
    The same Rule Result is sent to 
    both Typology instances.
    end note
    r->rp2: 2
    note over r, rp2
    Number of TP's that 
    received the message 
    end note
    rp->crsp: Done


    t->cadp: HTTP POST TypologyResult
    t2->cadp: HTTP POST TypologyResult
end group
@enduml
```
