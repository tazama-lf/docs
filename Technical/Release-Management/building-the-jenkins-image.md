<!-- SPDX-License-Identifier: Apache-2.0 -->

To install and push the provided script to a container registry, follow these steps. This guide assumes you have Docker installed on your desktop and have access to a container registry where you can push images.

## 1. Preparing Your Environment

Before you begin, ensure you have Docker installed on your desktop. Docker will be used to build and push your Docker image. If you haven't installed Docker, visit the official Docker website for installation instructions for your operating system.

## 2. Creating the Script

1. Open your preferred text editor.
2. Copy and paste the provided Bash script into the editor. Or create a Dockerfile and run that.

```dockerfile
# Use a base Jenkins agent image
FROM jenkins/inbound-agent:latest as jnlp

USER root

# Update and install necessary packages for adding new repositories
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    gnupg2 \
    curl \
	sudo

# Add Kubernetes package key and set up the repository
#RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
#RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-bionic main" > /etc/apt/sources.list.d/kubernetes.list
RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

RUN apt-get update

# Update and install kubectl
RUN apt-get update -qq && apt-get install -qq -y kubectl

# Install Buildah
RUN apt-get install -y buildah

# Switch back to the jenkins user
USER jenkins
```

3. Save the file with a recognizable name, for example, build_and_push.sh. Ensure you have execution permission set on the script. You can set execute permission by running chmod +x build_and_push.sh in your terminal.

## 3. Running the Script

Before running the script, replace ${ImageRepository} with your actual container registry repository path. For example, if you are using Docker Hub, it might look like username/jenkins-inbound-agent.

To run the script:

1. Open a terminal or command prompt.
2. Navigate to the directory where you saved build_and_push.sh.
3. Execute the script by typing ./build_and_push.sh and press Enter.

This script performs the following actions:
 - Generates a Dockerfile that uses jenkins/inbound-agent:1.0.0as the base image.
 - Installs kubectl and buildah inside the Docker image.
 - Builds a new Docker image tagged as jenkins-inbound-agent:1.0.0in your specified image repository.
 - Pushes the newly built Docker image to the container registry.

## 4. Pushing to a Container Registry

The script automatically pushes the Docker image to the container registry specified in the ${ImageRepository} variable. Ensure you are logged in to your Docker or container registry account. You can log in to Docker Hub by running docker login and entering your credentials. For other registries, the login command might differ slightly, so refer to the registry's documentation for the exact command.

## 5. Verifying the Push

After the script completes, verify that the image has been successfully pushed to your container registry:

 - For Docker Hub, visit https://hub.docker.com/r/<your-username> and check if the jenkins-inbound-agent:1.0.0image is listed.
 - For other container registries, use the registry's web interface or CLI tools to verify the image is present.

## Troubleshooting

 - **Permission Denied**: If you encounter a permission denied error when running the script, ensure you've set the execute permission with chmod +x build_and_push.sh.
 - **Docker Not Running**: Ensure Docker is running on your desktop. If it's not, start Docker through your system's services interface.
 - **Login Required**: If the push to the container registry fails, make sure you're logged in to your container registry account.

By following these steps, you will have successfully installed the script locally and pushed the Docker image through to a container registry.
