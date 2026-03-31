# Hytale Server Installer

Automated installation script for running a **Hytale dedicated server**
on **Debian 13** OR **Ubuntu 24.04** using:

-   Java 25 (Temurin / Adoptium)
-   systemd service
-   tmux console session
-   UFW firewall configuration

Designed for **repeatable, clean installs** on fresh servers or VMs.

------------------------------------------------------------------------

# Features

## Core functionality

-   installs required dependencies
-   installs Java 25 from Adoptium repo
-   downloads the official Hytale dedicated server
-   installs server files into configurable directory
-   creates a systemd service
-   runs the server inside tmux for interactive console access
-   firewall configuration (UFW)
-   colored output for improved usability
-   automatic cleanup of temporary install files

------------------------------------------------------------------------

# Scripts included

## 1. Personal Installer (simple version)

Opinionated installer intended for personal use on fresh Debian 13
systems.

Characteristics:

-   installs to `/opt/hytale-server`
-   configures firewall automatically
-   performs system upgrade
-   minimal configuration required
-   easy to run once and forget

Recommended for:

-   home lab environments
-   personal VPS servers
-   quick deployments
-   single-server setups

------------------------------------------------------------------------

## 2. **FUTURE RELEASE** CLI Installer (portable version) **FUTURE RElEASE**

More flexible installer that supports command line flags.

Additional features:

-   configurable install directory
-   configurable service name
-   configurable tmux session name
-   configurable runtime user/group
-   optional firewall configuration
-   optional system upgrade
-   dry-run mode
-   uninstall mode

Recommended for:

-   sharing with others
-   scripted deployments
-   multiple server instances
-   reproducible environments
-   testing setups

------------------------------------------------------------------------
# Requirements

-   Debian 13 (Trixie) or Ubuntu 24.04 Server
-   sudo privileges
-   internet access
-   2 or more CPU cores
-   4 to 8 GB of RAM

Tested on:

-   fresh Debian 13 VM
-   fresh Ubuntu 24.04 server VM
-   minimal Debian & Ubuntu installs

------------------------------------------------------------------------

# Quick Start

Clone repository:

``` bash
git clone https://github.com/mcsco/hytale-server-installer.git
cd hytale-server-installer
```

Make script executable:

``` bash
chmod +x hytale-install.sh
```

Run installer:

``` bash
./hytale-install.sh
```

------------------------------------------------------------------------
# First-time Server Authentication

After installation completes:

Attach to console:

``` bash
tmux attach -t hytale
```

Authenticate:

``` text
/auth login device
/auth persistence Encrypted
```

Detach without stopping server:

``` text
Ctrl + b then d
```

------------------------------------------------------------------------

# Default Install Location

``` text
/opt/hytale-server
```

Contents:

``` text
/opt/hytale-server
├── Server/
├── Assets.zip
├── start.sh
├── jvm.options
```

------------------------------------------------------------------------

# Managing the Service

Check status:

``` bash
sudo systemctl status hytale
```

Restart server:

``` bash
sudo systemctl restart hytale
```

Stop server:

``` bash
sudo systemctl stop hytale
```

Attach console:

``` bash
tmux attach -t hytale
```

List tmux sessions:

``` bash
tmux ls
```

------------------------------------------------------------------------
# Notes

-   After Server Reboot, Hytale re-authentication might be required
-   Java 25 is required for current Hytale server builds
-   tmux allows interactive command execution without stopping the
    service
-   systemd ensures server starts automatically on boot
-   installer cleans temporary files automatically
-   script designed for fresh Debian or Ubuntu installs but works on existing
    systems

------------------------------------------------------------------------

# Disclaimer

This project is not affiliated with Hypixel or Hytale.

Use at your own risk. Always review scripts before running on production
systems.