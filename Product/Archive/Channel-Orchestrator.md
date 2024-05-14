# Channel Orchestrator

Channel Orchestrator is the best place to manage the status/progress of the transaction/rules/typologies/scoring (and now the old school approach)  

1. It knows which Rules and Typologies are active and in which channels
2. Every Rule and Typology and Scoring will update the Status to the Channel Orchestrator
3. Channel Orchestrator will expose API to query Status of any particular Rule or Typology or Scoring or the overall Transaction

Tracking will have to be architected. Where we also send a status message for any processing of any Rule, Typology, Scoring to another processor (which I believe should be the Channel Orchestrator). This way we can avoid polling

gRPC = REST (but smaller more efficient packet size) + streaming and other things. gRPC is just a more efficient alternative to REST.

Design workshop with some of the techies to trash this one out I believe? We will need to solve this to implement and make the channel solution work. Yes. Before that - this audience needs to be in alignment.

## Biggest Issue

The biggest issue we need to resolve is to find a way to keep the “status”and “progress” of a transaction. (eg. how do we know how many rules are to be executed, and which rule are completed and what is still pending).  
A polling solution would be the easy solution, but not convinced it would be the best in a real-time application as it can be very expensive in terms of resources.  
Dynamic workflow could also work, but again that is so “old school” and will take seconds to complete at best.
