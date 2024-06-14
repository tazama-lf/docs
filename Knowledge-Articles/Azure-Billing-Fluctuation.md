<!-- SPDX-License-Identifier: Apache-2.0 -->

# Azure Billing Fluctuation

## Problem Statement

The Azure hosting costs had a large fluctuation last month. Investigate why there was an increase in costs and alleviate the problem.

## Why is it happening

Azure costs have gone up by a significant amount, upon investigation it was found that the Azure ATP ([Advanced Threat Protection](https://docs.microsoft.com/en-us/azure/security/fundamentals/threat-detection)) was at a point where it was costing more than the storage it was assigned to. The scaling of this Advanced Threat Protection was rapid and in the Azure portal it is an on or off feature, there is no way to scale it.

During the investigation, we found that as storage usage increases the ATP cost will increase exponentially. Furthermore, we also found some lingering costs on the cluster due to a lag in our cluster clean-up time.

## How we solved it

After a discussion on the risks and rewards, we agreed on disabling the ATP functionality. This could not be done through the Azure portal and needed to be completed through the Azure CLI. In order to complete this in the Azure CLI, there was some dependency hell we needed to resolve before being able to change this functionality. ATP is applied at the Subscription level and will need to be changed from the subscription level on a per resource basis.

![](../../images/image-20210713-122804.png)

As additional clean-up, we are also cleaning up any dangling resources such as assigned IPs or Storage mounts that are no longer being used. We are also reducing the cluster clean up lag time.

## How we will prevent it

In order to prevent any more costs surprises, we have set up a Grafana dashboard and report to show the storage usage of the previous 7 days. Note that this dashboard seems a little rough on the eyes, however, it shows everything we need to see storage wise. This Dashboard is shared as a report daily.  

![](../..//images/image-20210713-123634.png)