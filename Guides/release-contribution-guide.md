# DevOps / Release Engineering Contribution Guide for Tazama

Welcome to the **Tazama-LF** open-source community! This guide equips new contributors with everything needed to navigate and contribute to our infrastructure specifications. From github actions to Helm charts to Terraform scripts, CI/CD pipelines to release workflows, this document ensures you can confidently build, test, and deploy multi-cloud Kubernetes infrastructure.

Let’s create automated, scalable and reliable systems together! 🚀

---

## Table of Contents

1. [Overview](#overview)
2. [Main Tools](#main-tools)
3. [Code Repositories](#code-repositories)
4. [Cloud Infrastructure](#cloud-infrastructure)
5. [CI/CD Pipelines](#cicd-pipelines)
6. [Artifacts](#artifacts)
7. [Branching Strategy](#branching-strategy)
8. [Release Process](#release-process)
9. [Roles & Permissions](#roles--permissions)
10. [Licensing & Compliance](#licensing--compliance)
11. [Troubleshooting](#troubleshooting)
12. [Community & Contributions](#community--contributions)

---

## Overview

> **🎯 Goal:** Make it easy to understand where to contribute, what to do, and how to test and release changes.

**Tazama-LF** is an open-source project delivering multi-cloud Kubernetes infrastructure using Helm, Terraform, and GitHub Actions. We support cloud deployments on Amazon EKS, Azure AKS, and Google GKE.

### Key Objectives

* Deliver consistent, reproducible infrastructure across AWS, Azure, and GCP.
* Automate releases via GitHub Actions pipelines.
* Foster a collaborative, transparent open-source community.

**Audience:** DevOps engineers, Developers and contributors interested in automation, cloud, release management and infrastructure-as-code (IaC), Kubernetes.

---

## Main Tools

These are the major tools that we use in our infrastructure setup.

| Tool           | Purpose                                    | Documentation                                                    |
| -------------- | ------------------------------------------ | ---------------------------------------------------------------- |
| GitHub Actions | CI/CD pipelines for testing and deploying  | [GitHub Actions Docs](https://docs.github.com/actions)           |
| Helm           | Package and deploy Kubernetes applications | [Helm Docs](https://helm.sh/docs/)                               |
| Terraform     | Provision cloud infrastructure             | [Terraform Docs](https://developer.hashicorp.com/terraform/docs) |
| Docker         | Build and publish container images         | [Docker Docs](https://docs.docker.com/)                          |
| Kubernetes     | Orchestrate containerized applications     | [Kubernetes Docs](https://kubernetes.io/docs/)                   |

**Setup:** Install these tools locally (`helm`, `docker`, `kubectl`, `git`, `terraform`).

---

## Code Repositories

All code is hosted in the [tazama-lf](https://github.com/tazama-lf) GitHub organization.

| Repository        | Description                                | Repository Link                          |
| ----------------- | ------------------------------------------ | ---------------------------------------- |
| EKS-helm      | Helm charts for Kubernetes deployments     | [EKS](https://github.com/tazama-lf/EKS-helm) |
| AKS-helm      | Helm charts for Kubernetes deployments     | [AKS](https://github.com/frmscoe/AKS-helm) |
| GKE-helm      | Helm charts for Kubernetes deployments     | [GKE](https://github.com/tazama-lf/GKE-helm) |
| infra-terraform | Terraform modules for cloud infrastructure | [EKS TF](https://github.com/tazama-lf/EKS-helm/tree/dev/eks-terraform)        |
| infra-ci        | GitHub Actions workflows for CI/CD         | [GitHub Actions](https://github.com/tazama-lf/workflows)                     |
| infra-docs      | Documentation for infrastructure specs     | [DevOps Docs](https://github.com/tazama-lf/docs/tree/dev/Technical/Release-Management)              |

**Tips:**

* Start with helm and terraform to understand the k8s cluster provisioning setup. There's a terraform folder with setup instructions
* The workflows repo is centralized with all workflows and a docs folder that explains all workflows we use.

---

## Cloud Infrastructure

We support multi-cloud Kubernetes deployments:

| Cloud Provider | Cluster Type       | Terraform Module | Helm Chart   |
| -------------- | ------------------ | ---------------- | ------------ |
| Amazon EKS     | Managed Kubernetes | aws/eks        | Tazama |
| Azure AKS      | Managed Kubernetes | azure/aks      | Tazama |
| Google GKE     | Managed Kubernetes | gcp/gke        | Tazama |

---

## CI/CD Pipelines

Defined in [.github/workflows](https://github.com/tazama-lf/workflows):

| Workflow      | Trigger          | Purpose                                  |
| ------------- | ---------------- | ---------------------------------------- |
| `codacy.yml `   | Push/PR | Security scan            |
| `codeql.yml`    | Push/PR      | Scanning code for vulnerabilities      |
| `conventional-commits.yml`   | Push/PR   | Checks whether each commit in a pull request (PR) has a "Signed-off-by" line, ensuring compliance with the Developer Certificate of Origin (DCO) |
| `dco-check.yml` | Merge to main  | Deploys infra, publishes, tags release   |
| `dependency-review.yml` | Push/PR  | Reviews the dependencies of a project   |
| `dockerfile-linter.yml` | Merge to main  | Automates the linting of Dockerfiles using Hadolint and uploads the results to GitHub in SARIF format for further analysis   |
| `dockerhub-image-build.yml` | Push/PR  | Automates the process of building, tagging, and pushing Docker images to Docker Hub whenever a new release is published.   |
| `gpg-verify.yml` | Push/PR  | verifies the GPG signatures of commits in a pull request   |
| `milestone.yml` | Manually  | Closes a specific milestone on GitHub and trigger a release workflow.   |
| `njsscan.yml` | Push/PR  | Designed to run the njsscan code scanning tool and upload the results as a SARIF   |
| `node.js.yml` | Push/PR  | Builds the project, checks the code style, and runs tests.   |
| `release.yml` | mileston.yml  | Automates the process of creating a new release   |
| `sync-workflows.yml` | PR to dev in this repo  | Automates the process of synchronizing workflow files across multiple repositories whenever a pull request (PR) is merged into the dev branch.   |

**Tips:**

* A `workflow-docs` folder exists in the workflows repo with details explanations about each workflow.

* Secrets: Managed via GitHub Secrets. Contact the DevOps team for access.

**Local Testing:**

```
act -j lint.yml
terraform validate
helm lint
```

---

## Artifacts

| Artifact Type | Destination     | Trigger         | Access     |
| ------------- | --------------- | --------------- | ---------- |
| 🚢 Docker Images | [Docker Hub](https://hub.docker.com/orgs/tazamaorg/repositories)      | Merge to main | Public     |
| NPM Packages  | [GitHub Packages](https://github.com/tazama-lf/auth-lib/pkgs/npm/auth-lib) | Merge to dev/main | GitHub PAT |

* Docker Usage

```
docker pull tazamaorg/rule-091
```

* NPM Usage

```
npm install @tazama-lf/auth-lib@1.0.0
```

**Tips:**

* Speak to to the Tazama team if you need any access regarding the above.
  
---

## Branching Strategy

| Branch   | Purpose                     | Access                          |
| -------- | --------------------------- | ------------------------------- |
| `main`   | Production-ready code       | Protected; PR + review required |
| `dev`    | Feature and fix integration | Protected; PR + review required |
| `feat/*` | New features                | Contributor created → dev     |
| `fix/*`  | Bug fixes                   | Contributor created → dev     |
| `chore/*`  | Bug fixes                 | Contributor created → dev     |

**Typical Workflow:**

```
git checkout -b feat/my-feature dev
git commit -s -m "Add autoscaling config"
git push origin feat/my-feature
```

**Tips:**

* Rules: No direct pushes to dev or main. Signed commits required.

## ✅ Good to Know

* Use signed commits: `git commit -s`
* No direct pushes to `main` or `dev`
* Use PR templates and fill out acceptance criteria

---

## Release Process

### Prepare

* Create PRs from dev to main
* Create milestones manually in each repository that's to have a release inluding the private rules repos. Note th milestone ID

### Submit

* Review and merge PRs from dev to main
* Trigger off the milestone workflow by using the milestone ID
* The milestone ID will automatically trigger the release workflow

### Post-release

* Release workflow will run and create the release
* Check that a new release version will be establoshed on each repository
* The dockerhub publish workflow will tag build and tag a new image with the release version number and push it to dockerhub. Check they exist
* Slack notifiations alerting the new release will be sent in the slack channel `tazama-project-notifications`

---

## Roles & Permissions

| Role        | Description                      |
| ----------- | -------------------------------- |
| `Contributor` | Fork, pull to push              |
| `DevOps Team` | Manages CI/CD, secrets, releases |
| `Maintaniers` | Admins over Github Operations |

**Permissions:**

* `Read` for all
* `Write` via PR request and approval

---

## Licensing & Compliance

* **License:** [Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0)

  
* **SPDX Header:**

Every file with infrastructure configuration must have this header.

  ```
  <!-- SPDX-License-Identifier: Apache-2.0 -->
  ```

* **DCO Sign-off:**
  
  ```
  git commit -s -m "Signed-off-by: Your Name <email>"
  ```
---

## Troubleshooting

| Issue                 | Solution                                               |
| --------------------- | ------------------------------------------------------ |
| CI pipeline fails     | Check logs in the Github Actions page      |
| NPM package error     | Verify PAT scope (read:packages)                     |
| Terraform apply fails | `Validate creds`; then check `terraform validate` and `terraform validate` again |
| Helm chart errors     | Run helm lint                        |
| Permission denied     | Reach out to Tazama Team                |

**Local Testing:** Use kind or k3s.

---

## Community & Contributions

* Start with `good first issues`
* Bi-weekly CICD working group calls
* Updates via PRs to infra related repositories
* There are `deployment` and `welcome` channels in slack that you can make use of incase you have any questions.

--- 


## 🤝 Need Help?

* Start a [GitHub Discussion](https://github.com/tazama-lf/tazama-project/discussions)
* Join our [Slack](https://slack.tazama.org/)
* Email engineering@tazama.org directly if you need to inquire about anything from the team.

❤️ Thank you for joining Tazama-LF and for helping build **Tazama-LF** infrastructure! 🚀! Your contributions drive our mission.