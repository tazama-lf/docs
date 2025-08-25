<!-- SPDX-License-Identifier: Apache-2.0 -->

## Table of Contents <!-- omit in toc -->

- [Introduction](#introduction)
- [Pre-requisites:](#pre-requisites)
    - [1. Create a virtual machine running ubuntu](#1-create-a-virtual-machine-running-ubuntu)
    - [2. Install Docker Compose](#2-install-docker-compose)
    - [3. Install Git](#3-install-git)
    - [4. Install Newman](#4-install-newman)
    - [5. Set Personal Github Access Token](#5-set-personal-github-access-token)
- [Installation steps](#installation-steps)
    - [1. Clone the Full-Stack-Docker-Tazama Repository to Your Local Machine](#1-clone-the-full-stack-docker-tazama-repository-to-your-local-machine)
    - [2. Deploy the Core Services via script](#2-deploy-the-core-services-via-script)
    - [3. Configure Tazama](#3-configure-tazama)
    - [4. Restart core processors](#4-restart-core-processors)
- [Test the end-to-end deployment](#test-the-end-to-end-deployment)
- [Demo UI](#demo-ui)

## Introduction

This guide will take you through the steps to deploy Tazama on a single instance machine running Ubuntu via Docker Compose. The machine can be created on any cloud provider (EC2, Azure, DigitalOcean, GCE etc) or on-prem server

Tazama is composed of a number of third party and custom-built open source components. While all our Tazama components are open source software, the rules and specific Tazama typology configurations that we have built to detect fraud and money laundering behaviour are hidden from public (and nefarious) view in private repositories on GitHub.

The guide in the [Full-Stack-Docker-Tazama repository](https://github.com/tazama-lf/Full-Stack-Docker-Tazama) will show you how to install the system using only the publicly available open source software components. This guide will show you how to install the private rule and typology configurations, if you have access to them.

## Pre-requisites:

The pre-requisites that are essential to be able to follow this guide to the letter are:

#### 1. Create a virtual machine running ubuntu

- Create a Virtual Machine running ubuntu on any platform of choice.
- Ensure the machine has about 8gb RAM and about 30 gb storage volume.
- While creating the VM, enable ssh, http and https connections (ports `22`, `443` and `80`)
- Navigate to the security groups and open TCP connections on the following ports (`5000` for TMS, `14222` fo nats, `3001` for the UI and `18529` for Arango DB)
- ssh to the VM. This can be done either through a remote conection with ssh keys or in the platform UI. Please note all commands in the following sections are to be run in this ssh session.
- Update your system by running the following command.

  ```
  sudo apt update && sudo apt upgrade -y
  ```

#### 2. Install Docker Compose

- Install Docker 

  ```
  sudo apt install -y docker.io
  ```

- Download Docker Compose

  ```
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  ```

- Give Execute Permissions 

  ```
  sudo chmod +x /usr/local/bin/docker-compose
  ```

- Verify the Installation

  ```
  docker-compose --version
  ```

- Enable Docker & Start It on Boot 

  ```
  sudo systemctl enable --now docker
  ```

- Add your user to the docker group to avoid using sudo every time

  ```
  sudo usermod -aG docker $USER
  ```

- Apply the changes (log out and back in, or run)

  ```
  newgrp docker
  ```

#### 3. Install Git

- Git is available in Ubuntu’s default repositories. Install it with;

  ```
  sudo apt install -y git
  ```

- Verify the installtion with the following command

  ```
  git --version
  ```

#### 4. Install Newman

- Newman requires Node.js and npm. Install them first:

  ```
  sudo apt install -y nodejs npm
  ```

- Now, install Newman globally using npm: 

    ```
    sudo npm install -g newman
    ```

- Verify the installation:

    ```
    newman --version
    ```

#### 5. Set Personal Github Access Token

- A GitHub personal access token with `packages:write` and `read:org` permissions
- Ensure that your GitHub Personal Access Token is added as a Windows Environment Variable called "`GH_TOKEN`".
- Instructions for creating the GH_TOKEN environment variable can be found in the [instructions for setting up a GitHub token locally)](https://github.com/tazama-lf/docs/blob/dev/Guides/dev-set-up-environment.md#311-step-1-setting-up-github-token-locally)

- Note that your token needs to be exported everytime you ssh to the server in a new session

  ```
  export GH_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxsOxxxx
  ```

[Top](#introduction)

## Installation steps

#### 1. Clone the Full-Stack-Docker-Tazama Repository to Your Local Machine

In the ssh session from the above steps, create a folder where you want to store a copy of the source code or just use the dfault location. Once in your desired source code root folder, clone (copy) the repository with the following command:

```
git clone https://github.com/tazama-lf/Full-Stack-Docker-Tazama -b main
```

If you would like to deploy the system from the `dev` branch, replace `main` above with `dev`. The `main` branch is the most recent official release of the system, while `dev` will include new features not yet released to the main branch.

**Output:**

![clone-the-repo](../images/full-stack-docker-tazama-clone-repo.png)

#### 2. Deploy the Core Services via script

With Docker compose installed: from your ssh window and from inside the `Full-Stack-Docker-Tazama` folder, execute the following command and follow the prompts:

**Unix (Linux/MacOS)** <!-- omit in toc -->
Any terminal: `./start.sh`

> [!IMPORTANT]  
> Ensure the script has the correct permissions to run. You may need to run `chmod +x start.sh` beforehand.


The one docker-compose command that is equivalent to running the start.sh script without any prompts is;

```
docker compose -p tazama -f docker-compose.yaml -f docker-compose.override.yaml -f docker-compose.db.yaml -f docker-compose.full.yaml -f docker-compose.relay.yaml -f docker-compose.dev.ui.yaml up -d
```

**Output:**

![start-services-1](/images/full-stack-docker-tazama-start-bat-1.png)

Select `2` from the start.sh docker deployment menu option

![start-services-4](/images/full-stack-docker-tazama-start-bat-4.png)

For option 2 (Full service DockerHub deployment) the output will be as follows:

![full-service-deployed](/images/full-stack-docker-tazama-full-service-option.png)


[Top](#introduction)

#### 3. Configure Tazama

Tazama is configured by loading the network map, rules and typology configurations required to evaluate a transaction via the ArangoDB API. The configuration information is hidden in a private repository and if you are a member of the Tazama `frmscoe` Organization on GitHub, you'll be able to clone this repository onto your virtual machine with the following command:

Change the current folder back to your root source code folder:

```
cd ..
```

Clone the `tms-configuration` repository:

```
git clone https://github.com/frmscoe/tms-configuration -b main
```

In addition to cloning the configuration repository, we also need to clone the Tazama `Postman` repository so that we can utilize the Postman environment file that is hosted there:

```
git clone https://github.com/tazama-lf/postman -b main
```

**Output:**

![clone-config](../images/full-stack-docker-tazama-clone-config.png)

Now that these two repositories are cloned, we can perform the following Newman command to load the configuration into the ArangoDB databases and collections:

```
newman run collection-file -e environment-file --timeout-request 10200
```

 - The `collection-file` is the full path to the location on your local machine where the `tms-configuration/default/tms-config.postman_collection.json` file is located.
 - The `environment-file` is the full path to the location on your local machine where the `postman/environments/Tazama-Docker-Compose-LOCAL.postman_environment.json` file is located.
 - If the path contains spaces, wrap the string in double-quotes.

**Output:**

![execute-config](../images/full-stack-docker-tazama-execute-config.png)

[Top](#introduction)

#### 4. Restart core processors

Now that the system is configured with the private rules and configuration, we need to restart our core processors in order to load the updated configuration. The main reason the configuration needs to preceed the deployment of the processors is that the processors read the network map at startup to set up the NATS pub/sub routes for the evaluation flow.  

Navigate back to the `full-stack-docker-tazama` folder:
```
cd Full-Stack-Docker-Tazama
```

Execute the following command to restart the core processors:

```
docker restart tazama-ed-1 tazama-tp-1 tazama-tadp-1
```

**Output:**

![processors-restart](../images/demo-processors-restart.png)

[Top](#introduction)

## Test the end-to-end deployment

You should be able to submit a test transaction to the Transaction Monitoring Service API and then be able to see the result of a complete end-to-end evaluation in the database. We can run the following Postman test via Newman to see if our deployment was successful:

```
newman run collection-file -e environment-file --timeout-request 10200 --delay-request 500
```

 - The `collection-file` is the full path to the location on your local machine where the `tms-configuration/default/tms-config-test.postman_collection.json` file is located.
 - The `environment-file` is the full path to the location on your local machine where the `postman/environments/Tazama-Docker-Compose-LOCAL.postman_environment.json` file is located.
 - If the path contains spaces, wrap the string in double-quotes.
 - We add the `--delay-request` option to delay each individual test by 500 milliseconds to give them evaluation time to complete before we look for the result in the database.

**Output:**

![to be fixed great-success](../images/full-stack-docker-tazama-great-success.png)

## Demo UI

Navigate to http://vm-ip-address:5000 to test functionality of the TMS URL. You must get a `STATUS :UP` response in the browser.

Navigate to http://vm-ip-address:18529 to arango db dashboard.

Navigate to http://vm-ip-address:3001 to access the demo UI. You'll need to configure env-vars for Arango url, Nats url, TMS url and websocket API for the demo UI to be funtional settings.
