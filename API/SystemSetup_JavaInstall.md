## WSL2 Setup / Java Install

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

## Configuring WSL+Ubuntu Environment / Linux system

- Update System

    - `sudo apt update`

    - `sudo apt upgrade`

    - `sudo apt install curl jq`
        - `jq` is a command-line JSON processor.  Mac can get download here: [https://jqlang.org/download/ ](https://jqlang.org/download/)

- Install **Java JDK 17**

    - `sudo apt install -y openjdk-17-jdk-headless`
        - MacOS can try top answer here for homebrew instructions: [https://stackoverflow.com/questions/69875335/macos-how-to-install-java-17](https://stackoverflow.com/questions/69875335/macos-how-to-install-java-17)

    - Verify that JAVA_HOME (which is set in bashrc) is set to the displayed path (minus the bin/javac)
        - `echo $JAVA_HOME`

    > The JAVA_HOME environment variable should look similar to `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`

## VSCode configurations

Extension list:
- WSL (if you are running WSL)
- Extension Pack for Java (relative to WSL if needed)

## *Recommended by Winsupply Magicians* Use Windows git credentials in WSL2

> Kayleigh Duncan says this is weird magic.  Just configure `git` in WSL+Ubuntu and authenticate to GitHub with SSH keys.

- Adjust Home Directory .gitconfig (Inside WSL)

    - Create the following file ~/.gitconfig (`nano ~./gitconfig`)

    - While editing the file in nano, replace the contents with the following if you have Git configured in Windows:
    ```
    [user]
        name = <Name>
        email = <Email>
    [color]
        ui = true
    [core]
        editor = code --wait
    [credential]
        helper = /mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe
    [diff]
        tool = default-difftool
    [difftool "default-difftool"]
        cmd = code --wait --diff $LOCAL $REMOTE
    [merge]
        tool = code
    [mergetool "code"]
        cmd = code --wait --merge $REMOTE $LOCAL $BASE $MERGED

    ```

    If you don't have Git configured in Windows, adjust the credential > helper to be `cache --timeout=31449600`

## Troubleshooting

Java 25+ will not work with codebase.  Need to downgrade to Java 17
