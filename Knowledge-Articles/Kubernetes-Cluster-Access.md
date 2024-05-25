<!-- SPDX-License-Identifier: Apache-2.0 -->

# Kubernetes Cluster Access

This article will guide you through getting access to the FRM cluster from your local machine.

## Prerequisites

In order to follow this guide in it’s fullest please ensure you have the following applications installed and ready:

1. kubectl ( [Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) | [Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) | [MacOS](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/) )
2. Azure CLI ( [Windows](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli) | [Linux](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt) | [MacOS](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos) )
3. Lens ( [Home Page](https://k8slens.dev/) | [Github Releases](https://github.com/lensapp/lens/releases/tag/v4.1.4) ) *Please ensure you have the latest version installed (4.1.4)*

## Instructions

Open a terminal of your choice and execute the following commands (screenshots added for reference where relevant):

1.

```bash
az login
```

2.

```bash
az account set --subscription 8ba9b414-35d4-4a1e-adf7-a9df2ae0324d
```

3.

```bash
az aks get-credentials --resource-group ACTIO-FRM --name AKS-ACTIO
```

![](../../images/image-20210311-073550.png)

4.

```bash
az login --use-device-code
```

5. Open the highlighted URL and copy your unique code:

![](../../images/image-20210311-073918.png)

6. Paste the code you copied into the text box on the URL you browsed to:

![](../../images/image-20210311-074047.png)

7. Select the account you have bound to the cluster

![](../../images/image-20210311-074158.png)

8. This popup means the sign in was successful and you can close your browser window

![](../../images/image-20210311-074233.png)

9. Once you close the browser you will see your terminal update with the following output:

![](../../images/image-20210311-074417.png)

10.

```bash
kubectl get pods --namespace frm
```

11. If successful you will see a list of pods as seen here

![](../../images/image-20210311-083823.png)

12. Launch the Lens application we installed earlier

13. Click on the “Add Cluster” Button

14. In the “select contexts” dropdown please select “AKS-FRM”

![](../../images/image-20210311-084023.png)

15. Once the cluster is added expand “Workloads” and click on “Pods” you should see a result set of the pods we have running in the dev namespace

![](../../images/image-20210311-084122.png)

## Logging

All events are logged so we can always backtrack what happened.

![](../../images/image-20210311-084506.png)

Remember

![](../../images/image-20210311-084545.png)
