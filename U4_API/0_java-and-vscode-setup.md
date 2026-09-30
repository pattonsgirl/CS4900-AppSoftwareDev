# Java and Visual Studio Code Setup

## Windows

### Install WSL

- From Windows, open Powershell **in admin mode**.

    - Type wsl --update.
        - Enter a username / password.  It can be the same as your system username / password
        - You will likely need to reboot after successful install

    - Type wsl --status and verify:
        Default Distribution: Ubuntu-24.04
        Default Version: 2

    - Type wsl --install -d Ubuntu-24.04.

- Add Ubuntu-24.04 to taskbar.

- Open Ubuntu-24.04

    - At prompt, hit any key to continue…

    - Add default user (just pick a simple username that you will remember).

    - Set/verify password (keep it short, the system is protected by the Windows password).

### Configuring WSL + Ubuntu Environment

- Update System

    - `sudo apt update`

    - `sudo apt upgrade`

    - `sudo apt install curl jq`

- Install **Java JDK 17**

    - `sudo apt install -y openjdk-17-jdk-headless`

    - Verify that JAVA_HOME (which is set in bashrc) is set to the displayed path (minus the bin/javac)
        - `echo $JAVA_HOME`

    > The JAVA_HOME environment variable should look similar to `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`

## Mac

- Install [Homebrew](https://brew.sh/)
    - Ensure that the recommended environment configurations are set for terminal use. The following should be defined in your .zshrc and .zprofile (both are located in your home directory): `eval "$(/opt/homebrew/bin/brew shellenv)"`

- Install necessary tools using: `brew install git jq openjdk@17 wget`

### Setup jEnv (Java Environment Manager)

Since MacOS comes with Java installed by default, you will need to either manually change your Java version or use a tool to help. jEnv is the recommended tool for handling it for you.

- Install the tool using: `brew install jenv` and verify that the following is defined in your .zshrc anc .zprofile.

```sh
export PATH="${HOME}/.jenv/bin:${PATH}"
eval "$(jenv init -)"
```

- Restart your terminal session and then run the following commands:

```sh
jenv add $(/usr/libexec/java_home -v 17)
jenv global 17
jenv enable-plugin export
```

This will set your default java version to 17 and configure the JAVA_HOME environment variable for you. If you need to switch it in the future you can use the jenv global command with a known version.

- Verify that the setup has completed successfully by using the `jenv doctor` command and checking the java version using `java -version`.

## Visual Studio Code configurations

Extension list:
- WSL (if you are running WSL)
- Extension Pack for Java (relative to WSL if needed)
- Spotless Gradle (by Richard Willis)

## *Recommended by Winsupply Magicians* Update Your .gitconfig

> Kayleigh Duncan says this is weird magic.  Just configure `git` in WSL+Ubuntu and authenticate to GitHub with SSH keys.

### WSL Setup

- Create or edit the following file ~/.gitconfig (`nano ~./gitconfig`)

- While editing the file in nano, replace the contents with the following if you have Git configured in Windows:
```
[user]
    name = YOUR_NAME
    email = YOUR_EMAIL
[credential]
    helper = /mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe
[push]
    autoSetupRemote = true
```

If you don't have Git configured in Windows, adjust the credential > helper to be `cache --timeout=31449600`

### Mac Setup

- Create or edit the following file ~/.gitconfig (`nano ~./gitconfig`)

- While editing the file in nano, replace the contents with the following if you have Git configured in Windows:
```
[user]
	name = YOUR_NAME
	email = YOUR_EMAIL
[push]
	autoSetupRemote = true
```

### Use Visual Studio Code Instead of Your Terminal

You can adjust your configuration to use Visual Studio Code instead of the terminal.

- Add the following to your .gitconfig

```
[color]
	ui = true
[core]
	editor = code --wait
[diff]
	tool = default-difftool
[difftool "default-difftool"]
	cmd = code --wait --diff $LOCAL $REMOTE
[merge]
	tool = code
[mergetool "code"]
	cmd = code --wait --merge $REMOTE $LOCAL $BASE $MERGED
```

## Troubleshooting

Java 25+ will not work with codebase.  Need to downgrade to Java 17
