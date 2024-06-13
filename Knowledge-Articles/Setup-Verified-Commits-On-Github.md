<!-- SPDX-License-Identifier: Apache-2.0 -->

# Setup Verified Commits on Github

This instruction guide is to walk you through the process of configuring git to sign commits with a generated key.
Maintaining the integrity and authenticity of code is important and one effective way to enhance this security is through verified commits using GPG (GNU Privacy Guard).

Verified commits are particularly valuable for open-source projects and collaborations where multiple contributors are involved. By leveraging GPG, developers can cryptographically sign their commits, establishing a clear chain of trust and safeguarding against unauthorized changes.

To configure Git to sign commits with SSH keys, follow these essential steps:

### Pre-reqs

- Git version 2.34 or later 
`git --version`

- Note: GPG does not come installed by default on macOS or Windows. To install GPG command line tools, see [GnuPG's Download page](https://www.gnupg.org/download/)
 - Scroll under `GnuPG binary releases`
 - Get the right binary for your operating system. If you're on Windows Select and Install `Gpg4win`. Select and Install through the defaults until you reach `Finish` step.
 - After installation, set the correct path by running `SET PATH=%PATH%;C:\Program Files (x86)\GNU\GnuPG`

- Make sure git is configured to use the correct email
 - git config --list
 - git config --global user.email youremailhere


### Instructions

The instructions are taken from Github Official Docs. They specify different commands for different OS E.g. Linux, Windows, Mac.

1. Check for existing GPG keys
Before you generate a GPG key, you can check to see if you have any existing GPG keys. To check if you have any existing GPG keys on your operating system platform, follow the steps in this official [Github doc link](https://docs.github.com/en/authentication/managing-commit-signature-verification/checking-for-existing-gpg-keys?platform=windows)

2. Generating a new GPG key
If you don't have any GPG keys, you can have new ones generated that you'll use for signing commits and tags.

Leave the defaults values selected for you until the process is done. Remember to note down the `passphrase` for your key

Follow the steps to generate a new GPG key for your laptop OS platform in this official [Github doc link](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key?platform=windows)

3. Add the GPG key to your Github account
Adding the gpg key you created in the previous step will configure your account on github.com to use it. Whenever a commit is made and pushed to github, it will show as verified as long as it has been signed by a corresponding private key. 

Follow these steps to add your key on github

- In the upper-right corner of any page, click your profile photo, then click Settings.
- In the "Access" section of the sidebar, click  SSH and GPG keys.
- Next to the "GPG keys" header, click New GPG key.
- In the "Title" field, type a name for your GPG key E.g. "Verifying Commits Key"
- In the "Key" field, paste the GPG key you copied when you had it generated
- Click Add GPG key.
- To confirm the action, authenticate to your GitHub account again (log out and in again).

4. Configuring Git to use your GPG key
To sign commits locally, you need to inform Git that there's a GPG, SSH, or X.509 key you'd like to use. If you have multiple GPG keys, you need to tell Git which one to use.

Follow the steps to tell git about your gpg key in this official [Github doc link](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key?platform=windows)


5. Manually Sign Commits

- To sign a commit, use the -S flag with the git commit command
`git commit -S -m "Your commit message"`

- If you're using GPG, after you create your commit above, provide the passphrase you set up.

- After committing, push it to github, create a pull request and check the commits under the PR to ensure they show `Verified`


6.  Automatically Sign Commits:

- If you prefer not to use the sign flag every time, you can configure Git to automatically sign your commits
`git config --global commit.gpgsign true`

- You'll have to store your GPG key passphrase so you don't have to enter it every time you sign a commit. 
For Mac users, the [GPG Suite](https://gpgtools.org/) allows you to store your GPG key passphrase in the macOS Keychain.
For Windows users, the [Gpg4win](https://www.gpg4win.org/) integrates with other Windows tools.

7. Troubleshoot verified commits not working

- Configure user to sign using the generated gpg key `git config user.signingkey gpg-key`

- Declare key to be global if you want to use the same key for every repository. `git config --global user.signingkey gpg-key`

- Add the absolute path of gpg `git config --global gpg.program "C:\Program Files (x86)\GnuPG\bin\gpg.exe"`

- Set and use the same email for generating and signing the commit `git config --global user.email youremailhere`
