# Central and Caller Release Flow

This guide explains how Tazama / FRMS releases work with **central** and **caller** workflows.

It is written for product, project, and delivery readers. You do not need deep GitHub Actions knowledge. Technical detail is included only where it helps you understand *who does what*, and *what happens next*.

---

## In one minute

Releasing many repositories used to mean repeating the same steps in every repo. That is slow, easy to get wrong, and hard to keep consistent.

The new model works like this:

1. **One central place** holds the full release instructions (`workflows` repo).
2. Each product repository gets a **thin caller workflow** that invokes that shared instruction.
3. Release helpers open **pull requests** for humans to review.
4. After those PRs are merged, packages, Docker images, and GitHub releases are created automatically where needed.

**Important:** Putting new workflows into the central `workflows` repo does **not** release products by itself. It only installs the shared instructions. The actual release wave comes later.

---

## Why we needed this

We release across two organisations (`tazama-lf` and `frmscoe`) and many repository types:

| Kind of repository | Simple example | What a release usually needs |
|--------------------|----------------|------------------------------|
| Shared libraries | core libraries used by other services | Update version, publish the package |
| Rule processors | `rule-021` | Update version, publish package, build Docker image |
| Services / apps | product services | Align versions, merge, create a GitHub release |
| Non-code repos | docs, config | Merge ready work from the working branch into the release branch (often `dev` -> `main`) |

Without a shared system, every team would invent their own steps. With the central/caller model, the **process is shared**, while each repo only opts into the parts it needs.

---

## Two simple ideas: Central and Caller

Think of it like a **shared library and a thin wrapper**:

| Concept | Technical analogy | In GitHub |
|---------|-------------------|-----------|
| **Central workflow** | Shared library / reusable service that holds the real implementation | Lives in `{org}/workflows` and contains the full release logic |
| **Caller workflow** | Thin wrapper that imports that library and calls one function | A small file in each product repo that points at the central workflow with `uses:` |

In GitHub Actions terms:

- The **central** file is a reusable workflow (`workflow_call`).
- The **caller** file is a short entry point that triggers it and passes inputs (version, branches, and so on).

### Central workflows

- Stored in:
  - `tazama-lf/workflows`
  - `frmscoe/workflows` (mirror for the FRMS rule org)
- Contain the full logic: version checks, dependency updates, opening PRs, publishing packages, creating GitHub releases, building Docker images.
- Updated once. When pinned correctly, every connected repo uses the improved process.

### Caller workflows

- Stored in each product repository under `.github/workflows/`.
- Usually short.
- Decide **when** something runs, and **which** central workflow to call.
- Do **not** contain the long release procedure themselves.

### What changes where

| If we need to... | We change... | How many places? |
|------------------|--------------|------------------|
| Fix a bug in "how we open a release PR" | Central `workflows` repo | Once |
| Include a new library in the next release wave | That library's caller + release list | That repo |
| Treat a docs repo differently from a package repo | Use a different caller type | That repo |

---

## Picture of the full system

```text
                 +----------------------------------+
                 |  Central workflows repo          |
                 |  (shared reusable workflows)     |
                 |                                  |
                 |  release-train                   |
                 |  dev-to-main-pr                  |
                 |  publish                         |
                 |  release                         |
                 |  package-rule / package-rule-rc  |
                 +----------------+-----------------+
                                  |
                     caller uses:
                     org/workflows/...@v1
                                  |
                                  v
     +----------------+   +----------------+   +----------------+
     | Library repo   |   | Rule repo      |   | Docs repo      |
     | caller files   |   | caller files   |   | caller files   |
     +-------+--------+   +-------+--------+   +-------+--------+
             |                    |                    |
             v                    v                    v
        release PR           release PR            merge PR
             |                    |                    |
             v                    v                    v
        publish npm          publish + Docker     GitHub release
        + GitHub release     + GitHub release     (if configured)
```

---

## The building blocks

### 1. Release train (`release-train`)

**Used by:** libraries, services, and rules that have a package version file.

**What it does:**

1. Starts from the working branch (usually `dev`).
2. Prepares the version and dependencies for a stable release.
3. Opens a pull request into the release branch (usually `main`).

**What people see:** a PR titled something like `release: v4.0.0`.

**What it does *not* do:** publish packages by itself, or create the final GitHub tag by itself.

---

### 2. Dev to main PR (`dev-to-main-pr`)

**Used by:** non-code repositories (docs, config, and similar) that do **not** need package version changes.

**What it does:**

1. Opens a pull request from the working branch to the release branch.
2. Optionally uses the platform version in the PR title.
3. If that PR already exists, it does nothing harmful (safe to re-run).

**Why it exists:** the release train expects a package version file. Docs repos do not have one, but they still need to participate in the release wave.

---

### 3. Publish (`publish`)

**Used by:** repositories that publish npm packages to GitHub Packages.

**What it does:**

- Publishes the package after the release PR is merged.
- Uses an `rc` channel for prerelease versions.
- Uses a `latest` channel for clean stable versions.

**Usual trigger:** automatic, when the release branch receives package file changes (typically after merge). Can also be started manually if needed.

---

### 4. Release (`release`)

**Used by:** repositories that should get a GitHub Release / tag for the platform version.

**What it does:**

- Creates the platform GitHub tag/release (for example `v4.0.0`).
- Builds release notes from recent changes.
- Can include an optional milestone description.

**What it does *not* do:** publish npm or build Docker images.

---

### 5. Package rule / Package rule RC

**Used by:** rule processor repositories.

**What they do:**

| Workflow | Typical branch | Docker tags |
|----------|----------------|-------------|
| `package-rule-rc` | working branch (`dev`) | versioned RC tag + moving `:rc` |
| `package-rule` | release branch (`main`) | versioned stable tag + `:latest` |

These are the workflows that build and push Docker images for rules.

---

### 6. Version check (`version-check`)

**What it does:** a safety gate on pull requests into `main`.

If the package version still looks like a prerelease (for example `1.2.3-rc.1`), the check fails. That helps prevent accidental `latest` releases/images from unstable versions.

---

### 7. Sync workflows (`sync-workflows`)

**What it does:** distributes day-to-day CI helpers (security checks, commit checks, and similar) to the FRMS rule repositories.

**What it deliberately does *not* do:** copy the full release workflows into every rule repo.

Release workflows stay central. Rule repos receive thin callers for Docker builds. Platform release callers for libraries/docs are installed in a controlled way through the release setup process.

---

## What triggers what?

Use this as a quick map.

| Step | What starts it | What you see | Human action needed? |
|------|----------------|--------------|----------------------|
| Prepare package release | Release automation / manual "run release train" from `dev` | PR `release: vX.Y.Z` | Yes - review and approve |
| Prepare non-code release | Release automation / manual "run dev-to-main" from `dev` | PR to merge `dev` -> `main` | Yes - review and approve |
| Publish npm package | Merge of release PR (package files changed on `main`) | Package appears in GitHub Packages | Usually no |
| Build stable rule Docker image | Push/merge to `main` in a rule repo | Image tags `:X.Y.Z` and `:latest` | Usually no |
| Build RC rule Docker image | Push to `dev` in a rule repo | Image tags RC version and `:rc` | Usually no |
| Create GitHub release/tag | Release automation / manual "run release" from `main` | GitHub Release `vX.Y.Z` | Usually no after start |
| Sync day-to-day CI to rule repos | Changes merged to `dev` in `frmscoe/workflows` | Sync PRs in rule repos | Yes - merge sync PRs |

---

## End-to-end release journey (start to finish)

This is the practical path from "we want a platform release" to "packages, images, and tags exist".

### Phase 0 - Decide the release wave

Someone (usually release/project ownership) decides:

- which version number we are aiming for (example: `4.0.0`)
- which repositories are in this wave
- in what order dependent libraries should go first

That list is the release checklist for the wave.

---

### Phase 1 - Prepare the shared workflows (central)

1. Update the shared workflows in the central `workflows` repository.
2. Review and merge that PR into the workflows `dev` branch.
3. Tag a stable reference (for example `@v1`) so product repos use a known-good workflow version.

**Result:** the central reusable workflows are ready.  
**Not yet:** product repos releasing.

---

### Phase 2 - Install the caller workflows

For each repository in the wave:

1. Add/update the small caller files that point at the central workflows.
2. Open a PR into that repository's working branch (usually `dev`).
3. Team reviews and merges those caller PRs.

**Result:** each repo can invoke the right central workflow when asked.  
**Still not a product release** - only readiness.

Useful mental model:

- Phase 1 = update the shared reusable workflows
- Phase 2 = install the thin callers that invoke them

---

### Phase 3 - Prepare release pull requests

For the release wave:

1. Run a readiness check (are branches present? are callers in place? do versions look sensible?).
2. Start **release train** for package repositories.
3. Start **dev-to-main** for non-code repositories.

**Result:** open pull requests ready for human review.

Dependency tip:

- Publish shared libraries first.
- Only then release things that depend on those libraries.

---

### Phase 4 - Humans review and merge

Reviewers check:

- version and dependency changes look correct
- release notes / PR description make sense
- dependent packages are ready upstream

Merge in the agreed order.

**Result:** release-branch (`main`) now contains the stable content.

---

### Phase 5 - Automatic publish and images

After merge:

- **Publish** runs for package repos and uploads to GitHub Packages.
- **Package-rule** runs for rule repos and pushes stable Docker images.
- Teams get notifications where Slack is configured.

If something was already published, the publish step can skip the duplicate safely.

---

### Phase 6 - GitHub releases / tags

Finally, the release step creates the platform GitHub tag/release (for example `v4.0.0`) and attaches generated notes.

**Result:** the release wave is visible on GitHub, not only as packages/images.

---

## Day-to-day development vs release day

These are easy to mix up.

| Situation | What usually happens |
|-----------|----------------------|
| Normal feature work on `dev` | Day-to-day CI checks run; RC Docker images may build for rules |
| Updating shared CI helpers | Sync opens PRs in rule repos |
| Updating release workflows | Central `workflows` PR; callers may later pin a new tag |
| Actual platform release | Release train / dev-to-main PRs -> merge -> publish/images -> GitHub release |

---

## What people need to do (by role)

### Product / project / release owners

- Confirm the release version and repo list
- Confirm merge order for dependent packages
- Track which release PRs still need review
- Confirm the wave is complete once packages/images/tags exist

### Engineers / reviewers

- Merge caller-installation PRs during setup (Phase 2)
- Review release PRs carefully (Phase 4)
- Merge sync PRs when day-to-day CI is updated
- Do not merge a release PR that still has an `-rc` version onto `main`

### Platform / DevOps

- Maintain central workflows
- Keep org secrets/settings in place (token for packaging/PRs, Docker credentials, Slack webhook, reusable-workflow permissions)
- Run orchestration helpers for readiness, prepare, and final tagging
- Pin callers to a stable workflows tag for production waves

---

## Common questions

### Does merging the central workflows PR release everything?

No. It only updates shared reusable workflows. Product release happens later through Phases 2-6.

### Why do we need both central and caller files?

So we can fix one reusable workflow once, instead of editing dozens of repositories every time the process improves.

### Why is there a special workflow for docs?

Because docs do not have package versions to bump. They only need a clean merge from the working branch into the release branch.

### Will every rule repo suddenly get the new release workflows?

No. Sync continues for day-to-day CI and Docker caller stubs. Full release callers are installed only where the release list says they are needed.

### Is human approval still required?

Yes for release PRs (unless a team later enables auto-merge policies). Automation prepares and publishes; people still approve the content going onto `main`.

### What if a release PR already exists and we run the step again?

The prepare steps are designed to be safe to re-run. They reuse an existing open PR instead of creating duplicates.

---

## Quick glossary

| Term | Meaning |
|------|---------|
| Working branch | Where active work lands (usually `dev`) |
| Release branch | Where stable releases come from (usually `main`) |
| Platform version | The shared release number for the wave (example `4.0.0`) |
| Caller | Thin workflow in a product repo that invokes a central reusable workflow |
| Central workflow | Shared reusable workflow with the real release logic |
| Release train | Prepares package release PRs |
| Dev-to-main PR | Prepares merge-only release PRs for non-code repos |
| Publish | Uploads npm packages |
| GitHub release | Creates the tagged release page/notes on GitHub |
| Sync | Copies/updates day-to-day CI into rule repos |

---

## Related technical docs

If you need deeper workflow file details, see the `workflow-docs` folder in each org's `workflows` repository:

- [`tazama-lf/workflows`](https://github.com/tazama-lf/workflows)
- [`frmscoe/workflows`](https://github.com/frmscoe/workflows)

Older historical release notes for GitHub/Jenkins still live in this folder (`Github-Release.md`, `Jenkins-Release-Builds.md`). This page describes the newer central/caller platform release model.

---

## Summary

1. Central workflows = shared reusable workflows.  
2. Caller workflows = thin per-repo entry points.  
3. Prepare steps open PRs for humans.  
4. Merge unlocks publish / Docker / release tagging.  
5. Setup is separate from the actual release wave - and that separation is intentional.
