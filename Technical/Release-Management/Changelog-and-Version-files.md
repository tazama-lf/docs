<!-- SPDX-License-Identifier: Apache-2.0 -->

CHANGELOG.MD File

What is a changelog?
A changelog is a file which contains a curated, chronologically ordered list of notable changes for each version of a project.

Why keep a changelog?
To make it easier for users and contributors to see precisely what notable changes have been made between each release (or version) of the project.

Who needs a changelog?
People do. Whether consumers or developers, the end users of software are human beings who care about what's in the software. When the software changes, people want to know why and how.

How do I make a good changelog?
Guiding Principles
- The latest version comes first.
- Changelogs are for humans, not machines.
- There should be a version entry for every single PR.
- The release date of each version is displayed.
- The latest release to be made should match the latest version in the changelog.md file at the time of the release.

![](././images/changelog-file.png)

VERSION File

What is a VERSION file?
A VERSION file contains a version number that was appended to the CHANGELOG.md file

How do I make a good changelog?
Guiding Principles
- The latest version should be the match the number in the VERSION file.
- After making changes to Changelogs, ensure you change the version in the VERSION file before making a PR.
- Both files must be changed. You can't chnage the version in one and leave the other, be major, minor or patch numbers.
- The release to be published in github should match the version in the VERSION file at the point of release. (Screenshots attached below)

![](./images/version-file.png)

![](././images/release-file.png)
