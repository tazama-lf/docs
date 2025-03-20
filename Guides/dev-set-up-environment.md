<!-- SPDX-License-Identifier: Apache-2.0 -->

<a id="top"></a>

# Setting up the development environment <!-- omit from toc -->

## Table of Contents <!-- omit from toc -->

- [1. Introduction](#1-introduction)
- [2. Requirements for setting up the Development Environment](#2-requirements-for-setting-up-the-development-environment)
- [3. Microprocessor setup instructions](#3-microprocessor-setup-instructions)
  - [3.1. Preparation](#31-preparation)
    - [3.1.1 Step 1: Setting up GitHub Token Locally](#311-step-1-setting-up-github-token-locally)
    - [3.1.2 Step 2: Set up core services](#312-step-2-set-up-core-services)
  - [3.2. Setting Up a Microservice Processor to Work On](#32-setting-up-a-microservice-processor-to-work-on)
- [4. Further reading](#4-further-reading)

## 1. Introduction

Hello and welcome! If you are reading this, we hope it's because you'd like to help.  This guide is to help set up the development environment. (with thanks to @cshezi)

## 2. Requirements for setting up the Development Environment

Before you begin working on an existing or new Tazama microservice processor, ensure that the following requirements are met on your system:

 - **Node.js and npm**:
    - Install Node.js and npm by visiting the official [Node.js website](https://nodejs.org).
    - Follow the installation instructions for your operating system.

 - **Git**:
    - Install Git by visiting the official [Git website](https://git-scm.com/).
    - Follow the installation instructions for your operating system.
    - Also install [GitHub Desktop](https://desktop.github.com/) or [GitHub CLI](https://cli.github.com/), though this guide is written specifically for Git.

 - **Code Editor**:
    - Install a code editor of your preference (e.g. [Visual Studio Code](https://code.visualstudio.com/), [Eclipse](https://www.eclipse.org/), [Sublime Text](https://www.sublimetext.com/), [Vim](https://www.vim.org/)/[Neovim](https://neovim.io/) (RIP [Atom](https://github.blog/2022-06-08-sunsetting-atom/))).

 - **Docker**:
    - Docker is useful if you do not have access to a persistent development environment that hosts the core system microservices that you need to test your integrations. With Docker, you can deploy containerized microservices on your local machine. Follow the instructions on the official Docker website to [install Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/). Remember that Docker Desktop on Windows also requires Linux on Windows that you can [install with WSL](https://docs.docker.com/desktop/install/windows-install/)

  - **Postman / Newman**
    - Install the Postman application by visiting the official [Postman website](https://www.postman.com/downloads/) - we use Postman collections to test our microservices, but also to set up our ArangoDB collections and data. 
    - (Optional) If you prefer a command-line alternative to the Postman application, you can also use Newman or the Postman CLI tool. Instructions for installing both are also on the official [Postman website](https://www.postman.com/downloads/).

<div style="text-align: right"><a href="#top">Top</a></div>

## 3. Microprocessor setup instructions
Follow these step-by-step instructions to get your local machine ready to work on a Tazama microservice processor. First we are going to set up the core services that all microservice processors rely on, and then we'll set up a specific microservice and get that ready for you to work on.

### 3.1. Preparation  

#### 3.1.1 Step 1: Setting up GitHub Token Locally
 - Generate a GitHub Personal Access Token to access the GitHub API:
   - Visit the GitHub Tokens page while logged into your GitHub account (Click your profile picture in the top right corner, then `Settings`, then `Developer settings`, then `Personal access tokens`, then `Tokens (classic)`)
   - Click on the `Generate new token` button and select `Generate new token (classic)`.
   - Provide a name for your token and select the scopes or permissions required. For this case, you will need at least the `write:packages` and `read:org` scope.
   - Scroll down and click on the `Generate token` button at the bottom.
   - Copy the generated token immediately (this token won't be visible again).

 - Set the Environment Variable on your local machine:
   - Open your terminal or command prompt.
   - Substitute `your-github-token` below with the token you copied.
   - On Unix/Linux/Mac:
      ```
      export GH_TOKEN=your-github-token
      ```
   - On Windows (Command Prompt - Run as Administrator):
      ```
      setx GH_TOKEN your-github-token /m
      ```
   - On Windows (PowerShell):
      ```
      $env:GH_TOKEN="your-github-token"
      ```
<div style="text-align: right"><a href="#top">Top</a></div>


#### 3.1.2 Step 2: Set up core services

 - **Set up a Docker network**:
   - Before you start creating Docker containers to host all the service containers, you will need to create a bridge network so that the containers will be able to talk to each other. To set up a bridge, open a Windows Command Prompt and execute the following command:

      ```
      docker network create --driver bridge tazama-net 
      ```
      This command will create a local user-defined bridge network called `tazama-net` that we can use to network our containers together.

 - **ArangoDB**:
   - Follow the installation instructions for ArangoDB from the official [ArangoDB website](https://docs.arangodb.com/stable/operations/installation/). We recommend that you install the official ArangoDB Docker image for `v3.11.7` via [Docker Hub](https://hub.docker.com/_/arangodb/).
     - Start the Docker Desktop in Windows
     - In a Windows Command Prompt:
      ```
      docker pull arangodb:3.11.7
      ```
   - Start the ArangoDB server in a Docker container:

      In a Windows Command Prompt:
      ```
      docker run -p 8529:8529 --network=tazama-net -e ARANGO_NO_AUTH=1 --name arangodb-instance -d arangodb:3.11.7
      ```
      **Note**: This command will start an ArangoDB instance that does not require any user authentication - this is useful for testing, but should never be used in a production setting. See [here](https://docs.arangodb.com/stable/deploy/single-instance/manual-start/#authentication) for alternative options.
   - The ArangoDB web interface can now be accessed at <http://localhost:8529>.
   - Set up ArangoDB with a Postman collection from the [Tazama Postman repository](https://github.com/tazama-lf/postman)
    - The specific collection you need for the database configuration is <https://github.com/tazama-lf/postman/blob/main/ArangoDB%20Setup.json> - we will only need the contents of the `/1-ArangoDB-setup` and `/3-ArangoDB-Default-Configuration` folders in this collection for now.
    - You will also need the environment file for interacting with a local instance of ArangoDB via Postman/Newman: <https://github.com/tazama-lf/postman/blob/main/environments/Tazama-LOCAL.postman_environment.json>
     - You can import these files (or the entire Postman repository) into your installed Postman application to run, or you can run the collection with Newman.

       Both methods assume that you have cloned the Postman repository onto your local machine. You can do that with the following command from the folder where you want the repository to be located:
       ```
       git clone https://github.com/tazama-lf/postman
       ```
     - The Newman method is a little more straightforward to configure your instance of ArangoDB in Docker - you can do so with the following commands in a Windows Command Prompt:
        ```
        newman run collection-file --folder "1-ArangoDB-setup" -e environment-file --timeout-request 10200
        ```
        to execute the contents of the `1-ArangoDB-setup` folder, and
        ```
        newman run collection-file --folder "3-ArangoDB-Default-Configuration" -e environment-file --timeout-request 10200
        ```
        to execute the contents of the `3-ArangoDB-Default-Configuration` folder.
        
         - Replace `collection-file` with the full location path and filename of the `ArangoDB Setup.json` file in your cloned Postman repository
         - Replace `environment-file` with the full location path and filename of the `environments/Tazama-LOCAL.postman_environment.json` file in your cloned Postman repository
         - If the path contains spaces, wrap the string in double-quotes.

 - **NATS**:
   - Follow the installation instructions for NATS from the official [NATS website](https://nats.io/download/). We recommend that you install the official NATS Docker image for the `latest` version via [Docker Hub](https://hub.docker.com/_/nats).
     - Start the Docker Desktop in Windows
     - In a Windows Command Prompt:
      ```
      docker pull nats
      ```
   - Start the NATS server in a Docker container:
     - In a Windows Command Prompt:
      ```
      docker run -p 4222:4222 -p 8222:8222 -p 6222:6222 --network=tazama-net --name nats-server -dti nats:latest
      ```

 - **redis**:
   - Follow the installation instructions for redis from the official [redis website](https://redis.io/docs/install/install-redis/). We recommend that you install the official redis Docker image for the `latest` version via [Docker Hub](https://hub.docker.com/_/redis).
     - Start the Docker Desktop in Windows
     - In a Windows Command Prompt:
      ```
      docker pull redis/redis-stack-server
      ```
   - Start the redis server in a Docker container:
     - In a Windows Command Prompt:
      ```
      docker run -p 6379:6379 --network=tazama-net --name redis-stack-server -d redis/redis-stack-server:latest
      ```

 - **Tazama NATS REST Proxy**:
    
    Tazama is composed out of a number of different processors that are chained together using a pub/sub framework facilitated by NATS. Only the front-most processor, the TMS API, is accessible directly via a traditional API: the remaining (down-stream) processors are only accessible via their respective NATS subscription subjects.
    
    The Tazama NATS REST Proxy provides an API that enabled access directly into the down-stream processors to assist in the development and testing process.

    If interaction with Tazama is expected to be solely through the TMS API, the proxy will not be required.

   - Install the Tazama NATS REST Proxy Docker image for the `latest` version via the GitHub Container Registry:
     - Start the Docker Desktop in Windows
     - In a Windows Command Prompt:
      ```
      docker pull ghcr.io/tazama-lf/nats-utilities:latest
      ```
   - Start the redis server in a Docker container:
     - In a Windows Command Prompt:
      ```
      docker run -p 3000:3000 --network=tazama-net -e NODE_ENV=dev -e SERVER_URL=nats-server:4222 -d --name nats-utilities ghcr.io/tazama-lf/nats-utilities:latest
      ```
<div style="text-align: right"><a href="#top">Top</a></div>

### 3.2. Setting Up a Microservice Processor to Work On  

Let's pick an easy microservice processor to use as an example. Tazama is designed to run a number of rule processors to evaluate incoming transactions. By default, the sample rule processor, `Rule 901`, is configured in this development environment through the ArangoDB Postman scripts above. All the rule processors run inside the `Rule Executer` wrapper function, which is itself configured to contain `Rule 901` by default. To run `Rule 901`, we need to run the `Rule Executer`.

Follow the steps below to get the `Rule Executer` on your operating table:

1. Clone the GitHub Repository

    - Open a Windows Command Prompt and navigate to the folder where you want to store your code.
    - The following `git` command will clone Rule 901's code to your local machine:

        ```
        git clone https://github.com/frmscoe/rule-executer
        ```
        As you can probably guess, this command will also let you clone any of the repositories in the `frmscoe` that you have access to by specifying their specific URL after the `git clone` command.

2. Navigate to the Repository Folder

    Using the Windows `cd` or `chgdir` command, navigate to the newly cloned repository folder:
    ```
    cd rule-executer
    ```

3. Install Dependencies

    Using `npm`, you can install all the dependencies for the processor as specified in the `package.json` file in the repository folder:
    ```
    npm install
    ```

4. Configure Environment Variables:

    Each microservice processor's configuration is specified as environment variables that are located in a dot env (`.env`) file. Your cloned repository does not have one yet: we'll have to create it from the `.env.template` file that is already in your folder. You can copy this file with from your Windows Command Prompt:
    ```
    copy .env.template .env
    ```
    The default settings in the `.env` will be fine if you followed the installation guidelines above without changes, so you won't have to update the `.env` file just yet.

    Don't over-write or make changes in the `.env.template` file or these changes might be unintentionally merged with the source code when your code is committed.

5. Build the Node.js Application

    Use the following `npm` command to build the application which will add a folder called lib or build to the repository folder. 
      ```
      npm run build
      ```
    This new build folder won't be included in a future code commit - it has been excluded via the `.gitignore` file.

6. Open the Folder in VS Code

    To start development you can open VS Code in the repository folder with the following command in a Windows Command Prompt from the repository folder:
    ```
    code .
    ```

7. Start the Node.js Application

    In your Windows Command Prompt, you can run the microservice processor with the following command:
    ```
    npm run start
    ```
    This command starts the Rule Executer application, with Rule 901 inside it, from the built code. Once the processor is up and running, you can start sending requests to the processor via the NATS REST Proxy.
    
    The `npm run start` command will keep on running until you exit the application by pressing `ctrl-c`.

8. Sending messages to the microservice processor via the NATS REST Proxy

    Let's try to send a test message to our locally running Event Director via the NATS REST Proxy using a pre-fabricated Postman test. If you previously cloned the Postman repository, the `Rule-901-Quick-Check.postman_collection.json` test will be located in the Postman repository folder.
    
    Because the application is running in our previous Windows Command Prompt, we'll need to open a new one and then, using the following Newman command in the new Command Prompt, we can execute the test on our running processor:

    ```
    newman run collection-file -e environment-file --timeout-request 10200
    ```
    
      - Replace `collection-file` with the full location path and filename of the `Rule-901-Quick-Check.postman_collection.json` file in your cloned Postman repository
      - Replace `environment-file` with the full location path and filename of the `environments/Tazama-LOCAL.postman_environment.json` file in your cloned Postman repository
      - If the path contains spaces, wrap the string in double-quotes.

9. Run the Built-In Jest Tests

    If you want to execute the accompanying Jest tests for the processor, you can also perform this task via `npm`. In your Windows Command Prompt, execute the following command from the repository folder:
    ```
    npm run test
    ```
<div style="text-align: right"><a href="#top">Top</a></div>

### Additional Configuration (if needed): <!-- omit from toc -->

Different microservice processors may need to be set up in slightly different ways. Refer to the project documentation or processor README for any additional configuration instructions.

Check for specific database setup, API keys, or other dependencies.

### Troubleshooting: <!-- omit from toc -->
 - If you encounter issues during the setup process, refer to the project's issue tracker on GitHub or the documentation for troubleshooting steps.
 - Ensure that your system meets the specified requirements
 - If a shell command fails at first, try running your shell in administrator mode.

### Conclusion: <!-- omit from toc -->
You have successfully set up a Tazama microservice processor on your local machine. If you encounter any difficulties or have questions, refer to the project's documentation or seek help from the project's community on GitHub or Slack. Happy coding!

<div style="text-align: right"><a href="#top">Top</a></div>

## 4. Further reading

- Read the [CONTRIBUTING guide](https://github.com/tazama-lf/.github/blob/main/CONTRIBUTING.md) for more details on the contribution process.

<div style="text-align: right"><a href="#top">Top</a></div>