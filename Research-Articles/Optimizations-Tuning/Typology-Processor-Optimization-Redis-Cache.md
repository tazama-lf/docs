# Typology Processor Optimization Redis Cache

* * *

## Overview

This document outlines the solution devised to optimize the caching process for rule results within the Typology Processor (TP). The initiative addresses the redundant caching of rule results across multiple typologies, reducing unnecessary Redis requests and enhancing overall system efficiency.

### Objective

The primary goal is to introduce an optimized caching mechanism that ensures each rule result is cached only once in Redis, thereby minimizing redundant caching and improving resource utilization.

## Problem Statement

Previously, the TP sent individual rule results to each configured typology, leading to multiple instances of the same rule being cached in Redis across various typologies. This approach resulted in inefficiency, generating excessive Redis requests and impacting system performance.

## Proposed Solution

The solution involves implementing the following changes in the rule processing and caching mechanism:

### 1. Rule List Publication

Upon receiving a rule result from the Rule Processor (RP), the TP will immediately publish a Rule List to Redis. This list will serve as a consolidated repository of rule results.

### 2. Aggregation of Rules for Typologies

Instead of transmitting individual rule results, the TP will send an aggregated list of rules for processing to each configured typology. This aggregated list ensures that each typology receives a comprehensive set of rules for processing.

### 3. Garbage Collection of Redis Cache

After a full evaluation of the typologies for a currently evaluated transaction Typology processor is expected to clean up Redis as the list of rules is only valid for the transaction that is being evaluated.

## Expected Outcomes

The implementation of this solution is expected to yield the following improvements:

- **Reduction in Redundant Redis Requests**: Each rule result will be cached only once in Redis despite multiple typologies being configured, reducing the number of unnecessary Redis requests.
- **Enhanced System Efficiency**: Optimized resource utilization and improved system performance due to minimized redundancy in caching.

## Acceptance Criteria

To ensure the successful implementation of the solution, the following criteria will be met:

- Rule Processor (RP) transmits rule results to the Typology Processor (TP) as usual.
- Typology Processor (TP) immediately publishes a Rule List to Redis upon receiving a rule result.
- The TP sends aggregated lists of rules for processing to each configured typology instead of individual rule results.
- Clean up of Redis cache after completion of the transaction evaluation

## Impact Analysis

### Positive Impact

- **Reduction in Redis Requests**: Significant decrease in the number of Redis requests, optimizing system performance.
- **Optimized Resource Utilization**: Efficient utilization of resources due to minimized redundancy in caching.

### No Negative Impact

There are no anticipated negative impacts on system operations or functionalities.

## Implementation Considerations

- **Concurrency and Real-Time Updates**: Ensure concurrent updates to the Rule List in Redis are handled effectively to prevent data inconsistencies.
- **Error Handling and Recovery**: Implement robust error-handling mechanisms to manage failures during the caching process.

## Conclusion

This documentation outlines the planned solution to optimize rule result caching within the Typology Processor. By introducing a Rule List publication and aggregating rules for typologies, the aim is to significantly reduce redundant Redis requests, enhance system efficiency, and improve resource utilization.
