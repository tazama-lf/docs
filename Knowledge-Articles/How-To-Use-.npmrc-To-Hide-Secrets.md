<!-- SPDX-License-Identifier: Apache-2.0 -->

# How To: Use .npmrc to hide secrets

- [How To: Use .npmrc to hide secrets](#how-to-use-npmrc-to-hide-secrets)
  - [Installing](#installing)
  - [Setting up the environment](#setting-up-the-environment)
  - [Setting the environment variable](#setting-the-environment-variable)
    - [On Linux (and Unix-like systems)](#on-linux-and-unix-like-systems)
    - [Using a shell variable instead](#using-a-shell-variable-instead)

Some projects need authorisation (for installation), an example - [frms-coe-lib](https://github.com/frmscoe/frms-coe-lib) requires a valid GitHub personal access token before you can install it. There are a couple of options available to you to keep that token a secret. We’ll be taking advantage of environment variables and config files.

We’ll use a [.npmrc](https://docs.npmjs.com/cli/v9/configuring-npm/npmrc) file (`rc` suffixed and or `.` [dot prefixed] files are sometimes used as configuration files). In this case, an `npm` config file. There are a couple of places you can place the config files, but for the sake of simplicity, we have one at each project’s root:  

```bash
  - my-node-project
  - .npmrc
  - package.json
```

We have a project `my-node-project` that contains a `.npmrc` file and a `package.json` file that has our `frms-coe-lib` as a dependency.

If we inspect our `.npmrc` file:

```bash
@frmscoe:registry=https://npm.pkg.github.com
/npm.pkg.github.com/:_authToken=${GH_TOKEN}
```

To break this down, we specify the registry (i.e where to find the package(s) we want to install) as well as the `authToken` to ensure that only clients with valid authentication tokens can read from it.

For our convenience, `.npmrc` also supports reading environment variables which allows us to be able to keep our personal access tokens secret. In the example above, the access token is saved to a `GH_TOKEN` environment variable.

## Installing

If you try to run `npm install` without that personal access token, you should see something like:

```bash
npm ERR! code E401
npm ERR! 401 Unauthorized - GET https://npm.pkg.github.com/@frmscoe%2ffrms-coe-lib - unauthenticated: User cannot be authenticated with the token provided.

npm ERR! A complete log of this run can be found in:
npm ERR!     /some/npm/logfile/directory
npm ERR! code E401 npm ERR! 401 Unauthorized - GET https://npm.pkg.github.com/@frmscoe%2ffrms-coe-lib - unauthenticated: User cannot be authenticated with the token provided.  npm ERR! A complete log of this run can be found in: npm ERR!     /some/npm/logfile/directory \`\`\` 
```

## Setting up the environment

Create a GitHub [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with [read:packages](https://docs.github.com/en/packages/learn-github-packages/about-permissions-for-github-packages#about-scopes-and-permissions-for-package-registries) scope.

## Setting the environment variable

### On Linux (and Unix-like systems)

This process should be similar for other Unix-like operating systems, but because there are many different types of shells, this process may differ. You first want to check which shell your system is using. Verify with the command below:

```bash
echo $SHELL
```

In most cases, it would be `/bin/bash` or `/usr/bin/bash` depending on your system and where the particular executable, in this case, `bash` is located. Some systems have their current shell as `zsh`, others could have `fish`, in that case, you will want to consult your shell's manual on setting environment variables.

If you're here, you're probably using `bash` or `zsh`. What you would want to do is:

```bash
cd ~/
```

The command above takes you to your home directory - that means **the current user’s home directory**. Keep in mind that should you change the user from here on, all the changes we’re applying won’t be available to them.

In your home directory, you want to look for a file called `.bashrc` or `.zshrc` depending on the shell you're using. Notice the leading `.` in the file name, it means the file is hidden in the Linux file system. Notice the `rc` in the file name, meaning it's a configuration file (as our `.npmrc`).

Create the file if it does not exist and open it in your favourite text editor. You will then want to append:

```bash
export GH_TOKEN=accessToken
```

Where `accessToken` is the personal access token you created in GitHub.

A quick one-liner that achieves the same result:

```bash
echo 'export GH_TOKEN=accessToken' >> .bashrc
```

(*basically says append* `export GH_TOKEN=accessToken` *to my .bashrc file). Remember to use* `.zshrc` *if your shell is* `zsh`

You can then restart your shell or run `source ~/.bashrc` to reload the configuration (without restarting).

Check to see if your shell does actually read the variable with:

```bash
echo $GH_TOKEN
```

You should then see the token you saved there. Success! You should be able to run `npm install` on projects that expect `GH_TOKEN` to be available in the environment. Likewise, you are free to rename the variable to whatever you desire so long as you make the same change in your `.npmrc` file. So you can rename `GH_TOKEN` to `AUTH_TOKEN` so long as that variable exists in your shell’s configuration `.bashrc` or `.zshrc`

### Using a shell variable instead

The overall idea is still the same, but instead of persisting the variable (`GH_TOKEN`) across shells, it’s only active for the current shell you have running.

```bash
export GH_TOKEN=accessToken
```

This sets the variable, but if you restart your shell, it’s unavailable. Our first method, basically does the same thing, but because we put that line in the shell’s `rc` file, which gets checked on start up, the variable is auto populated for us.

You can also limit the scope of the variable by passing it directly to a command, which is `npm install` in this case.

```bash
GH_TOKEN=accessToken npm install
```

With this option, you’ll need to set `GH_TOKEN` every time you run `npm install` which may not be desired.
