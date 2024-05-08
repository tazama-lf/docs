# Network Routing and Subscription Management For NATS

## Overview

This document provides a comprehensive guide on the implementation of a network routing and subscription management system. The solution addresses the requirements outlined in the ticket issue, focusing on the CRSP, rule processors, typology processor, and TADProc. The implementation ensures dynamic subject creation, subscription setup, and efficient communication between the components based on the network map.

## Table of Contents

- [Network Routing and Subscription Management For NATS](#network-routing-and-subscription-management-for-nats)
  - [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [1. CRSP](#1-crsp)
    - [1.1 Subscription Subjects for Rule Processors](#11-subscription-subjects-for-rule-processors)
    - [1.2 CRSP's Own Subscription Subject](#12-crsps-own-subscription-subject)
    - [1.3 Deployment/Restart](#13-deploymentrestart)
  - [2. Rule Processors](#2-rule-processors)
    - [2.1 Subscriber and Publisher Subjects](#21-subscriber-and-publisher-subjects)
    - [2.2 CRSP Subscription and Typology Processor Publishing](#22-crsp-subscription-and-typology-processor-publishing)
    - [2.3 Deployment/Restart](#23-deploymentrestart)
  - [3. Typology Processor](#3-typology-processor)
    - [3.1 Subscription to Rule Publisher Subjects](#31-subscription-to-rule-publisher-subjects)
    - [3.2 Typology-Specific Publishing Subjects](#32-typology-specific-publishing-subjects)
    - [3.3 Subscription to Rule Subjects](#33-subscription-to-rule-subjects)
    - [3.4 Deployment/Restart](#34-deploymentrestart)
    - [3.5 Interdiction](#35-interdiction)
  - [4. TADProc](#4-tadproc)
    - [4.1 Subscription to Typology Subjects](#41-subscription-to-typology-subjects)
    - [4.2 Typology Identifier as Subject](#42-typology-identifier-as-subject)
    - [4.3 Publishing Subject for CMS Integration](#43-publishing-subject-for-cms-integration)
    - [4.4 Deployment/Restart](#44-deploymentrestart)
  - [5. General Note on Channels](#5-general-note-on-channels)


## 1. CRSP

### 1.1 Subscription Subjects for Rule Processors

- Use the id attribute for each rule processor with a "sub-" prefix, e.g., sub-001@1.0.0.
- Retrieval at runtime from the network map.

### 1.2 CRSP's Own Subscription Subject

- Set up its own subscription subject (crsp) for TMS API publishing.

### 1.3 Deployment/Restart

- When CRSP is deployed/started/restarted, perform the necessary setup for the subscription subjects.

## 2. Rule Processors

### 2.1 Subscriber and Publisher Subjects

- Use the id attribute for subscribers (with "sub-" prefix) and publishers (with "pub-" prefix), e.g., sub-001@1.0.0 and pub-001@1.0.0.

### 2.2 CRSP Subscription and Typology Processor Publishing

- Set up subscription subjects for CRSP to publish.
- Set up publishing subjects for Typology Processor to subscribe.

### 2.3 Deployment/Restart

- When the rule processor is deployed/started/restarted, perform the necessary setup for subscription and publishing subjects.

## 3. Typology Processor

### 3.1 Subscription to Rule Publisher Subjects

- Subscribe to rule publisher subjects using the current active network map.

### 3.2 Typology-Specific Publishing Subjects

- For each typology, publish to a subject with "typology-" prefix, e.g., typology-001@1.0.0.

### 3.3 Subscription to Rule Subjects

- Subscribe to all rule subjects based on the current active network map.

### 3.4 Deployment/Restart

- When the typology processor is deployed/started/restarted, perform the necessary setup for subscription and publishing subjects.

### 3.5 Interdiction

- Publish typology results to the cms subject when interdiction is required.

## 4. TADProc

### 4.1 Subscription to Typology Subjects

- Subscribe to all typology subjects based on the current active network map.

### 4.2 Typology Identifier as Subject

- For each typology, use the typology identifier (cfg attribute) with a "typology-" prefix, e.g., typology-001@1.0.0.

### 4.3 Publishing Subject for CMS Integration

- Set up the publishing subject for Case Management Integration (cms) to which TADProc will publish and CMS will subscribe.

### 4.4 Deployment/Restart

- When the TADProc is deployed/started/restarted, perform the necessary setup for subscription and publishing subjects.

## 5. General Note on Channels

- Channel resolution occurs in TADProc.
- Typology results are published to individual typology subjects and collected by TADProc.
- Organize typology results into channels defined in the network map.

This documentation serves as a comprehensive guide for implementing and maintaining the network routing and subscription management system, ensuring seamless communication among the components based on the network map.
