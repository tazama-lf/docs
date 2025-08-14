<!-- SPDX-License-Identifier: Apache-2.0 -->

<a id="top"></a>


## Table of Contents <!-- omit in toc -->

- [Introduction](#introduction)
- [Pre-requisites:](#pre-requisites)
- [Installation steps](#installation-steps)
    - [1. Clone the Full-Stack-Docker-Tazama Repository to Your Local Machine](#1-clone-the-full-stack-docker-tazama-repository-to-your-local-machine)
    - [2. Deploy the Core Services via script](#2-deploy-the-core-services-via-script)
    - [3. Configure Tazama](#3-configure-tazama)
    - [4. Restart core processors](#4-restart-core-processors)
- [Test the end-to-end deployment](#test-the-end-to-end-deployment)

## Introduction

This guide will take you through the steps to deploy Tazama in a Docker container on a single local Windows machine via Docker Compose.

Tazama is composed of a number of third party and custom-built open source components. While all our Tazama components are open source software, the rules and specific Tazama typology configurations that we have built to detect fraud and money laundering behaviour are hidden from public (and nefarious) view in private repositories on GitHub.

The guide in the [Full-Stack-Docker-Tazama repository](https://github.com/tazama-lf/Full-Stack-Docker-Tazama) will show you how to install the system using only the publicly available open source software components. This guide will show you how to install the private rule and typology configurations, if you have access to them.

## Pre-requisites:

Set up your development environment as recommended in the [Setting up the development environment guide](../Guides/dev-set-up-environment.md)

The pre-requisites that are essential to be able to follow this guide to the letter are:

 - Docker Desktop for Windows (and WSL)
 - Git
 - Newman
 - A code editor (this guide will assume you are using VS Code)
 - A GitHub personal access token with `packages:write` and `read:org` permissions
   - Ensure that your GitHub Personal Access Token is added as a Windows Environment Variable called "`GH_TOKEN`".
   - Instructions for creating the GH_TOKEN environment variable can be found in the [Setting up GitHub Token Locally](../Guides/dev-set-up-environment.md)

     - We will be referencing your GitHub Personal Access Token throughout the installation process as your `GH_TOKEN`. It is not possible to retrieve the token from GitHub after you initially created it, but if the token had been set in Windows as an environment variable, you can retrieve it with the following command from a Windows Command Prompt:

        ```
        set GH_TOKEN
        ```

<div style="text-align: right"><a href="#top">Top</a></div>

## Installation steps

#### 1. Clone the Full-Stack-Docker-Tazama Repository to Your Local Machine

In a Windows Command Prompt, navigate to the folder where you want to store a copy of the source code. For example, the source code root folder path I have been using to compile this guide is C:\Tazama\GitHub. Once in your source code root folder, clone (copy) the repository with the following command:

```
git clone https://github.com/tazama-lf/Full-Stack-Docker-Tazama -b main
```

If you would like to deploy the system from the `dev` branch, replace `main` above with `dev`. The `main` branch is the most recent official release of the system, while `dev` will include new features not yet released to the main branch.

**Output:**

![clone-the-repo](../images/full-stack-docker-tazama-clone-repo.png)

#### 2. Deploy the Core Services via script

First, start the Docker Desktop for Windows application.

With Docker Desktop running: from your Windows Command Prompt and from inside the `Full-Stack-Docker-Tazama` folder, execute the following command and follow the prompts:

**Windows**  
Command Prompt: `start.bat` 
Powershell: `.\start.bat`

**Unix (Linux/MacOS)** <!-- omit in toc -->
Any terminal: `./start.sh`

> [!IMPORTANT]  
> Ensure the script has the correct permissions to run. You may need to run `chmod +x start.sh` beforehand.

**Output:**

![start-services-1](/images/full-stack-docker-tazama-start-bat-1.png)

Select `2` from the start.bat docker deployment menu option

![start-services-4](/images/full-stack-docker-tazama-start-bat-4.png)

For option 2 (Full service DockerHub deployment) the output will be as follows:

![full-service-deployed](/images/full-stack-docker-tazama-full-service-option.png)


<div style="text-align: right"><a href="#top">Top</a></div>

#### 3. Configure Tazama

Tazama is configured by loading the network map, rules and typology configurations required to evaluate a transaction via the ArangoDB API. The configuration information is hidden in a private repository and if you are a member of the Tazama `frmscoe` Organization on GitHub, you'll be able to clone this repository onto your local machine with the following command:

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

 - The `collection-file` is the full path to the location on your local machine where the `tms-configuration\default\tms-config.postman_collection.json` file is located.
 - The `environment-file` is the full path to the location on your local machine where the `postman\environments\Tazama-Docker-Compose-LOCAL.postman_environment.json` file is located.
 - If the path contains spaces, wrap the string in double-quotes.

**Output:**

![execute-config](../images/full-stack-docker-tazama-execute-config.png)

<div style="text-align: right"><a href="#top">Top</a></div>

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

<div style="text-align: right"><a href="#top">Top</a></div>

## Test the end-to-end deployment

You should be able to submit a test transaction to the Transaction Monitoring Service API and then be able to see the result of a complete end-to-end evaluation in the database. We can run the following Postman test via Newman to see if our deployment was successful:

```
newman run collection-file -e environment-file --timeout-request 10200 --delay-request 500
```

 - The `collection-file` is the full path to the location on your local machine where the `tms-configuration\default\tms-config-test.postman_collection.json` file is located.
 - The `environment-file` is the full path to the location on your local machine where the `postman\environments\Tazama-Docker-Compose-LOCAL.postman_environment.json` file is located.
 - If the path contains spaces, wrap the string in double-quotes.
 - We add the `--delay-request` option to delay each individual test by 500 milliseconds to give them evaluation time to complete before we look for the result in the database.

**Output:**

![to be fixed great-success](../images/full-stack-docker-tazama-great-success.png)

<div style="text-align: right"><a href="#top">Top</a></div>
