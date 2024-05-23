<!-- SPDX-License-Identifier: Apache-2.0 -->

# Continuous Integration tooling

Add your comments directly to the page. Include links to any relevant research, data, or feedback.

|     |     |
| --- | --- |
| Status | FINISHED |
| Impact | HIGH |
| Driver | Joey Goksu |
| Approver | Jaco Bornman Aarón Reynoza Johan Foley Jonty Esterhuizen Joey Goksu Sandro Lourenco |
| Contributors | Jonty Esterhuizen Jaco Bornman |
| Informed |     |
| Due date | 05 Feb 2021 |
| Outcome | Jenkins |

## Background

Basically, CI is the practice of regularly merging all working copies of a code to a shared mainline, multiple times a day. The CI collects all the code changes in one place, prepares their publication, and tests and prepares the code release. All this helps minimize human error in code review (which grows as the team grows), saves time, and improves the quality of the code.

Links:

[https://travis-ci.org/](https://travis-ci.org/)

[https://circleci.com/](https://circleci.com/)

[https://www.jenkins.io/](https://www.jenkins.io/)

## Options considered

|     | Option 1: | Option 2: | Option 3: | Option 4 |
| --- | --- | --- | --- | --- |
| Name | Jenkins | CircleCI | TravisCI | Gitlab |
| Description | Jenkins is the leading open-source continuous integration tool | CircleCI is a cloud-based tool for continuous integration and deployment. | Travis CI is a tool created for open-source projects and focused on CI | GitLab is a software development platform |
| Pros and cons | ![(plus)](../../images/plus_32.png) A fully open-source codebase<br><br>![(plus)](../../images/plus_32.png) Supported OS: All (no limitations)<br><br>![(minus)](../../images/minus_32.png) Configuration via Jenkinsfile - which does cause a lock in, and if a need to move away, will require a re-write of our whole CI process.<br><br>![(plus)](../../images/plus_32.png) Custom cloud / private server solution: Custom cloud / private server solution<br><br>![(minus)](../../images/minus_32.png) Paid plan details: Free to use, requires a dedicated administrator.<br><br>![(plus)](../../images/plus_32.png) Runs on your own private server or a 3rd-party cloud hosting option<br><br>![(plus)](../../images/plus_32.png) Compatible with any type of version control system<br><br>![(plus)](../../images/plus_32.png) Powerful Pipeline syntaxis generating script that helps automate many processes, including testing<br><br>![(plus)](../../images/plus_32.png) Price depends on the hardware needed.<br><br>![(minus)](../../images/minus_32.png) Not used in Mowali<br><br>![(minus)](../../images/minus_32.png) GROOVY<br><br>![(minus)](../../images/minus_32.png) Looks like a 20yo software<br><br>![(plus)](../../images/plus_32.png) No build minute limits<br><br>![(plus)](../../images/plus_32.png) Parallel build are allowed | ![(minus)](../../images/minus_32.png) Mostly private (some open source)<br><br>![(plus)](../../images/plus_32.png) Supported OS: Linux or MacOS<br><br>![(plus)](../../images/plus_32.png) Custom cloud / private server solution:<br><br>Yes (including a free plan)<br><br>![(plus)](../../images/plus_32.png) Paid plan details: Based on containers and concurrent jobs (unlimited hours, users, minutes)<br><br>![(plus)](../../images/plus_32.png) Offers both a private server and hosted cloud options<br><br>![(plus)](../../images/plus_32.png) Workflows and automated testing on virtual machines<br><br>![(plus)](../../images/plus_32.png) VCS: Supports projects using Bitbucket, GitHub in the cloud plan<br><br>![(plus)](../../images/plus_32.png) Quality documentation of lightweight yml configuration settings, fast set-up for projects<br><br>![(minus)](../../images/minus_32.png) 1,000 build minutes per month and unlimited repos in a free plan<br><br>![(minus)](../../images/minus_32.png) Regarding MonoRepo all the Typologies would need to be built every time.<br><br>![(minus)](../../images/minus_32.png) Prices will go up rapidly when build minutes increase.<br><br>![(minus)](../../images/minus_32.png) Builds can not run in parallel<br><br>![(plus)](../../images/plus_32.png) Shiny looks. Intuitive UI<br><br>![(minus)](../../images/minus_32.png) Only a single yaml file per repo | ![(minus)](../../images/minus_32.png) Some private (some open source).<br><br>![(plus)](../../images/plus_32.png) Supported OS: Linux, macOS, Windows<br><br>![(plus)](../../images/plus_32.png) Configuration via yml file<br><br>![(minus)](../../images/minus_32.png) Custom cloud / private server solution:<br><br>Yes (no free version)<br><br>![(plus)](../../images/plus_32.png) Paid plan details: Based on concurrent jobs (unlimited hours, users, minutes)<br><br>![(plus)](../../images/plus_32.png) Well-documented lightweight yml configuration settings<br><br>![(plus)](../../images/plus_32.png) VCS is GitHub<br><br>![(minus)](../../images/minus_32.png) No free plan<br><br>![(minus)](../../images/minus_32.png) Not used in Mowali | ![(minus)](../../images/minus_32.png) Mostly free (selfhosted) with paid options<br><br>![(plus)](../../images/plus_32.png) Supported OS: All (no limitations)<br><br>![(plus)](../../images/plus_32.png) Configuration via yml file<br><br>![(plus)](../../images/plus_32.png) Custom cloud / private server solution: Custom cloud / private server solution<br><br>![(plus)](../../images/plus_32.png) built-in version control, issue tracking, code review,<br><br>![(plus)](../../images/plus_32.png) Workflows and automated testing on virtual machines<br><br>![(plus)](../../images/plus_32.png) Quality documentation of lightweight yml configuration settings, fast set-up for projects<br><br>![(minus)](../../images/minus_32.png) 400 build minutes per month and unlimited repos in a free plan<br><br>![(minus)](../../images/minus_32.png) Regarding MonoRepo all the Typologies would need to be built every time unless we swap to polyrepo.<br><br>![(minus)](../../images/minus_32.png) connection to GitHub only in PAID VERSION |
| Estimated cost | HIGH | MEDIUM | MEDIUM | HIGH |

## Action items

- Review all options
- Agree on an approach

## Outcome

The teams decided to use `Jenkins`.
