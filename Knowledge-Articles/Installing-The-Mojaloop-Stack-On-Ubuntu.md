<!-- SPDX-License-Identifier: Apache-2.0 -->

# Installing the Mojaloop Stack on Ubuntu

- [Installing the Mojaloop Stack on Ubuntu](#installing-the-mojaloop-stack-on-ubuntu)
  - [Snap](#snap)
  - [Microk8s](#microk8s)
    - [Uninstall - if previously installed](#uninstall---if-previously-installed)
  - [Creating Aliases](#creating-aliases)
    - [Removing Aliases](#removing-aliases)
  - [Configure Contexts](#configure-contexts)
  - [Docker](#docker)
  - [Helm](#helm)
  - [Install Mojaloop](#install-mojaloop)

This document details clear instructions to easily get a Mojaloop environment up and running. Mojaloop’s own documentation is not very clear and has some flaws that are not indicated clearly. If this document is followed correctly we believe that you would have a Mojaloop environment running quickly and with little to no hassle.

Please note that this document is only for the installation on a Ubuntu environment and other operating systems are not yet covered. We are also assuming that the environment is “clean” and does not have docker or Kubernetes installed on it at all.

This document will guide you through the installation of the following on your environment, as needed by the Mojaloop documentation:

- Snap
- Microk8s
- Docker (Through microk8s)
- Helm

## Snap

Snap should be preinstalled on your environment if you are using Ubuntu 16.04 LTS or above snap should already be installed.

For versions of Ubuntu between [14.04 LTS (Trusty Tahr)](https://wiki.ubuntu.com/TrustyTahr/ReleaseNotes) and [15.10 (Wily Werewolf)](https://wiki.ubuntu.com/WilyWerewolf/ReleaseNotes), as well as Ubuntu flavors that don’t include *snap* by default, *snap* can be installed from the Ubuntu Software Centre by searching for `snapd`.

## Microk8s

Microk8s dropped support for docker as part of their package since version 1.14, Mojaloop clearly stipulates that docker is needed thus we will be installing 1.13 which is the last version supporting docker.

```bash
sudo snap install microk8s --classic --channel=1.13/stable
```

This should install microk8s and confirm that the installation was successful by running the following:

```bash
sudo microk8s.status
```

### Uninstall - if previously installed

If you have already installed microK8s or docker - you might wish to uninstall them

Microk8s

```bash
sudo snap remove microk8s
```

Docker

```bash
sudo snap remove docker
```

## Creating Aliases

To make your life a little easier we recommend that we create aliases for the kubectl and docker commands.

Please note that this is completely optional and not needed to get the Mojaloop environment up. We will be running commands later on in this guide that would assume that the aliases were setup. If you chose not to create the aliases then just replace the commands using “kubectl” with “microk8s.kubectl” and “docker” with “microk8s.docker”

To create the aliases run the following:

```bash
sudo snap alias microk8s.kubectl kubectl
```

and

```bash
sudo snap alias microk8s.docker docker
```

The above aliases could easily be removed, if you wish to revert them, by running:

### Removing Aliases

```bash
sudo snap unalias kubectl
```

and

```bash
sudo snap unalias docker
```

## Configure Contexts

Now we need to ensure that the context was setup correctly by running:

```bash
kubectl config get-contexts
```

This should display the following:

| **CURRENT** | **NAME** | **CLUSTER**      | **AUTHINFO** | **NAMESPACE** |
| ----------- | -------- | ---------------- | ------------ | ------------- |
| *           | microk8s | microk8s-cluster | admin        |               |

We now have to select the Microk8s cluster as the current context:

```bash
sudo kubectl config use-context microk8s
```

After the context is selected we need to enable features of microk8s like the DNS and ingress:

```bash
sudo microk8s.enable dns
```

and

```bash
sudo microk8s.enable ingress
```

Now, microk8s should be running smoothly.

## Docker

With docker, there is not much to set up but we do recommend that you log in using your docker hub account to ensure that we do not get any problems relating to Docker Image pull rate limitations, you can read more about this [here](https://lextego.atlassian.net/wiki/spaces/ACTIO/pages/181698886/How+to+address+Docker+Pull+Rate+Limit).

If you do not have an account on docker hub, we recommend creating one [here](https://hub.docker.com/).

You can log in by running the following and replacing “foo” with your username and “bar” with your password:

```bash
sudo docker login --username foo --password bar
```

You might get a security warning about using your password - this can be addressed by using \[FIXME\]

You can get more help logging in with docker [here](https://docs.docker.com/engine/reference/commandline/login/).

## Helm

Due to issues with the newer versions of helm with Mojaloop [Aarón Reynoza (Unlicensed)](https://frmscoe.atlassian.net/wiki/people/5fa064ac048052006b1f270a?ref=confluence) has recommended that we use Helm 2.16. So to install helm run:

```bash
sudo snap install helm --classic --channel=2.16/stable
```

After the installation is successful we need to initialize helm, because the older version is still using an incorrect repo URL we need to specify that in initialization:

```bash
sudo helm init --stable-repo-url "https://charts.helm.sh/stable"
```

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.  
To prevent this, run `helm init` with the --tiller-tls-verify flag.  
For more information on securing your installation see: [https://v2.helm.sh/docs/securing\_installation/](https://v2.helm.sh/docs/securing_installation/)

We can ensure that helm is running by executing the following command:

```bash
helm version
```

Now we are going to add the Mojaloop repo as well as its dependencies, run all of the commands listed:

```bash
sudo helm repo add mojaloop https://docs.mojaloop.io/helm/repo
sudo helm repo add incubator https://charts.helm.sh/incubator
sudo helm repo add kiwigrid https://kiwigrid.github.io
sudo helm repo add elastic https://helm.elastic.co
sudo helm repo add bitnami https://charts.bitnami.com/bitnami
```

We should now update helm’s repositories:

```bash
sudo helm repo update
```

## Install Mojaloop

Now we install Mojaloop:

```bash
sudo helm install --namespace mojaloop --name demo mojaloop/mojaloop
```

The above command takes a while to install the Mojaloop stack and will start spinning up pods and containers as soon as we execute this.  
We can monitor the pod statuses by running:

```bash
kubectl get pods --namespace=mojaloop
```
