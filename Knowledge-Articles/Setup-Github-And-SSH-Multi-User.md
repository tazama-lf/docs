<!-- SPDX-License-Identifier: Apache-2.0 -->

# Setup GitHub and SSH - multi user

This instruction guide is to allow people who have more than one GitHub user account to switch from one to the other, and still be able to work with Git.

- [Setup GitHub and SSH - multi user](#setup-github-and-ssh---multi-user)
  - [Instructions](#instructions)
    - [Generating the SSH keys](#generating-the-ssh-keys)
    - [Adding the new SSH key to the corresponding GitHub account](#adding-the-new-ssh-key-to-the-corresponding-github-account)
    - [Registering the new SSH Keys with the ssh-agent](#registering-the-new-ssh-keys-with-the-ssh-agent)
    - [Creating the SSH config File](#creating-the-ssh-config-file)
    - [One active SSH key in the ssh-agent at a time](#one-active-ssh-key-in-the-ssh-agent-at-a-time)
    - [Setting the git remote Url for the local repositories](#setting-the-git-remote-url-for-the-local-repositories)
    - [While Cloning Repositories](#while-cloning-repositories)
    - [For Locally Existing Repositories](#for-locally-existing-repositories)

## Instructions

The instructions are taken from [here](https://www.freecodecamp.org/news/manage-multiple-github-accounts-the-ssh-way-2dadc30ccaca/)

### Generating the SSH keys

Before generating an SSH key, we can check to see if we have any existing SSH keys: `ls -al ~/.ssh` This will list out all existing public and private key pairs, if any.

If `~/.ssh/id_rsa` is available, we can reuse it, or else we can first generate a key to the default `~/.ssh/id_rsa` by running:

```bash
ssh-keygen -t rsa
```

When asked for the location to save the keys, accept the default location by pressing enter. A private key and public key `~/.ssh/id_rsa.pub` will be created at the default ssh location `~/.ssh/`.

Let’s use this default key pair for our personal account.

For the work accounts, we will create different SSH keys. The below code will generate the SSH keys, and saves the public key with the tag *“rob@LexTego.com”* to `~/.ssh/id_rsa_LexTego_rob.pub`

make sure you change the examples below to use your email instead of [rob@lextego.com](mailto:rob@lextego.com), your id instead of id_rsa_LexTego_rob and your home path ~ in absolute form /users/rob

```bash
ssh-keygen -t rsa -C "rob@LexTego.com" -f "~/.ssh/id_rsa_LexTego_rob"
```

* * *

If you got the following error

`*Saving key "~/.ssh/id_rsa_lextego.pub" failed: No such file or directory*`

You need to use an absolute path instead of a relative one.

```bash
ssh-keygen -t rsa -C "rob@LexTego.com" -f "/Users/rob/.ssh/id_rsa_LexTego_rob"
```

* * *

We now have two different keys created:

```bash
~/.ssh/id_rsa
~/.ssh/id_rsa_LexTego_rob
```

Create as many SSH keys as you have identities :stuck_out_tongue_winking_eye:

### Adding the new SSH key to the corresponding GitHub account

We already have the SSH public keys ready, and we will ask our GitHub accounts to trust the keys we have created. This is to get rid of the need for typing in the username and password every time you make a Git push.

If you do not have a Mac - check out this [tutorial](https://garywoodfine.com/use-pbcopy-on-ubuntu/) to add pbcopy to ubuntu

Copy the LexTego key `pbcopy < ~/.ssh/id_rsa_LexTego_rob.pub` and then log in to your work GitHub account:

(If you are on windows, you have to Pipe the file using the Cat command `cat ~/.ssh/id_rsa_LexTego_rob.pub | clip.exe` )

1. Go to `Settings`
2. Select `SSH and GPG keys` from the menu to the left.
3. Click on `New SSH key`, provide a suitable title, and paste the key in the box below
4. Click `Add key` — and you’re done!

For the personal accounts, use the corresponding public keys `*pbcopy < ~/.ssh/id_rsa.pub*` and repeat the above steps in your GitHub accounts.

### Registering the new SSH Keys with the ssh-agent

To use the keys, we have to register them with the **ssh-agent** on our machine. Ensure ssh-agent is running using the command `eval "$(ssh-agent -s)"`.  
Add the keys to the ssh-agent like so:

```bash
ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa_LexTego_rob
```

Make the ssh-agent use the respective SSH keys for the different SSH Hosts.

This is the crucial part, and we have two different approaches:

- Using the [SSH configuration file](https://lextego.atlassian.net/wiki/spaces/ACTIO/pages/546734195/Setup+GitHub+and+SSH+-+multi+user#Creating-the-SSH-config-File)
- having only [one active SSH key in the ssh-agent at a time](https://lextego.atlassian.net/wiki/spaces/ACTIO/pages/546734195/Setup+GitHub+and+SSH+-+multi+user#One-active-SSH-key-in-the-ssh-agent-at-a-time)

### Creating the SSH config File

Here we are actually adding the SSH configuration rules for different hosts, stating which identity file to use for which domain.

The SSH config file will be available at **~/.ssh/config**. Edit it if it exists, or else we can just create it.

```bash
$ cd ~/.ssh/
$ touch config           // Creates the file if does not exist
$ code config            // Opens the file in VS code, use any editor
```

Make configuration entries for the relevant GitHub accounts similar to the one below in your `~/.ssh/config` file:

```bash
# Personal account, - the default config
Host github.com
   HostName github.com
   User git
   IdentityFile ~/.ssh/id_rsa
   
# Work account-1
Host RobReeveLexTego.github.com
   HostName github.com
   User git
   IdentityFile ~/.ssh/id_rsa_LexTego_rob
```

“**RobReeveLexTego.github.com**” is the GitHub user id for the work account.

“**RobReeveLexTego.github.com**” is a notation used to differentiate the multiple Git accounts. You can also use “***github.com-RobReeveLexTego”*** notation as well. Make sure you’re consistent with what hostname notation you use. This is relevant when you clone a repository or when you set the remote origin for a local repository

The above configuration asks ssh-agent to:

- Use **id_rsa** as the key for any Git URL that uses **@github.com**
- Use the **id_rsa_LexTego_rob** key for any Git URL that uses **@RobReeveLexTego.github.com**

![](../../../images/CleanShot 2021-08-06 at 21.14.57@2x.png)

**Testing SSH connections and response**

***Personal Account***

```bash
ssh -T git@github.com
```

*Hi* `Rob`*! You've successfully authenticated, but GitHub does not provide shell access.*

***Work Account***

```bash
ssh -T git@RobReeveLexTego.github.com
```

*Hi* `RobReeveLexTego`*! You've successfully authenticated, but GitHub does not provide shell access.*

If you get the following error

“The authenticity of host '[github.com](http://github.com) (140.82.121.4)' can't be established.”

You need to add [github.com](http://github.com) to known hosts

```bash
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

* * *

### One active SSH key in the ssh-agent at a time

This approach doesn’t require the SSH config rules. Rather we manually ensure that the ssh-agent has only the relevant key attached at the time of any Git operation. It can be a little more convoluted - you should have set a passphrase for your Private key, you will need this every time you change key.

`ssh-add -l` will list all the SSH keys attached to the ssh-agent. Remove all of them and add the one key you are about to use.

If it’s to a personal Git account that you are about to push:

```bash
$ ssh-add -D            //removes all ssh entries from the ssh-agent
$ ssh-add ~/.ssh/id_rsa                 // Adds the relevant ssh key
```

The ssh-agent now has the key mapped with the personal GitHub account, and we can do a Git push to the personal repository.

To push to your work GitHub account, change the SSH key mapped with the ssh-agent by removing the existing key and adding the SSH key mapped with the GitHub work account.

```bash
$ ssh-add -D
$ ssh-add ~/.ssh/id_rsa_LexTego_rob
```

The ssh-agent at present has the key mapped with the work Github account, and you can do a Git push to the work repository. This requires a bit of manual effort, though.

### Setting the git remote Url for the local repositories

Once we have local Git repositories cloned /created, ensure the Git config user name and email is exactly what you want. GitHub identifies the author of any commit from the email id attached with the commit description.

To list the config name and email in the local Git directory, do `git config user.name` and `git config user.email`. If it’s not found, update accordingly.

```bash
git config user.name "RobReeveLexTego"   // Updates git config user name
git config user.email "Rob@LexTego.com"
```

### While Cloning Repositories

Note: step 7 will help, if we have the repository already available on local.

Now that the configurations are in place, we can go ahead and clone the corresponding repositories. On cloning, make a note that we use the host names that we used in the SSH config.

Repositories can be cloned using the clone command Git provides:

```bash
git clone git@github.com:personal_account_name/repo_name.git
```

The work repository will require a change to be made with this command:

```bash
git clone git@RobReeveLexTego.github.com:RobReeveLexTego/repo_name.git
```

This change is made depending on the host name defined in the SSH config. The string between @ and : should match what we have given in the SSH config file.

### For Locally Existing Repositories

**If we have the repository already cloned:**

List the Git remote of the repository, `git remote -v`

Check whether the URL matches our GitHub host to be used, or else update the remote origin URL.

```bash
git remote set-url origin git@RobReeveLexTego.github.com:RobReeveLexTego/repo_name.git
```

Ensure the string between @ and : matches the Host we have given in the SSH config.

**If you are creating a new repository on local:**

Initialize Git in the project folder `git init`.

Create the new repository in the GitHub account and then add it as the Git remote to the local repository.

```bash
git remote add origin git@RobReeveLexTego.github.com:RobReeveLexTego/repo_name.git 
```

Ensure the string between @ and : matches the Host we have given in the SSH config.

Push the initial commit to the GitHub repository:

```bash
git add .
git commit -m "Initial commit"
git push -u origin master
```

We are done!
