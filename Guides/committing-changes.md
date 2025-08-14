<!-- SPDX-License-Identifier: Apache-2.0 -->

# Committing Your Changes

When committing changes to your development branch you would be required to submit a commit message to describe the change. Depending on the mechanism that you are using to commit your changes, you may have access to a commit message as well as an extended description of your changes, but it is expected that you should complete at least the commit message.

Tazama aims to comply with the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification for adding human and machine-readable meaning to commit messages (subject to the commit types recommended below).

A commit message must be a short description of the change, prefaced with a commit type:

```
type: short description
```

The commit message should also include a scope:

```
type(scope): short description
```

If the change is a breaking change, the type should be following by an exclamation:

```
type!: short description
```

Recommended commit types for Tazama are based on the [Angular convention](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#type), summarized for ease of reference:

 - **build**: Changes that affect the build system or external dependencies
 - **ci**: Changes to our CI configuration files and scripts
 - **docs**: Documentation only changes
 - **feat**: A new feature
 - **fix**: A bug fix
 - **perf**: A code change that improves performance
 - **refactor**: A code change that neither fixes a bug nor adds a feature
 - **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semicolons, etc.)
 - **test**: Adding missing tests or correcting existing tests

Note: **chore** is not in the recommended list of commit types

Scope keywords are tailored to Tazama's specific requirements. Tazama's source code is spread across a number of repositories and as such even small changes often affect a number of separate repositories simultaneously. This complicates source control a bit, since a number of changes across different repositories may all be related to a single requirement. For the sake of proper governance, the requirement would be logged as an issue in each of the affected repositories to outline the acceptance criteria for the change in *that* repository and also to provide an anchor for the eventual Pull Request to implement the change in that repository. From this perspective, the scope is generally either confined to a single repository that represents a single Tazama processor, or a cluster of repositories representing a number of Tazama processors.

 - If your change is limited to a single repository, the scope should be the name of the repository, e.g. `typology-processor` or `rule-executer`.
 - If your change impacts multiple repositories, the scope should be `multi-repo`.

## Further reading

- Read the [CONTRIBUTING guide](https://github.com/tazama-lf/.github/blob/main/CONTRIBUTING.md) for more details on the contribution process.

Thank you for contributing to Tazama! Your efforts help make our platform smarter, safer, and more insightful for financial ecosystems everywhere. Need assistance? [Open a Discussion](https://github.com/tazama-lf/tazama-project/discussions) or [raise an Issue](https://github.com/tazama-lf/tazama-project/issues).