# Hytale Server Setup Script

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-5.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Java](https://img.shields.io/badge/Java-25-orange.svg)](https://adoptium.net/)

Automated installation script for Hytale Dedicated Server with auto-detection of root/user privileges and fully configurable installation paths.

## ✨ Features

- 🔄 **Auto-detect root/user mode** - Automatically configures system-wide or user-local installation
- 📁 **Flexible installation paths** - Choose default, current directory, or custom path
- ☕ **Java 25 auto-installation** - Downloads and configures Java 25 if not present
- 🎮 **Complete server setup** - Downloads and configures Hytale server files
- 🔧 **Systemd service** (root mode) - Automatic service creation with systemctl support
- 💾 **Backup & update scripts** - Built-in maintenance tools
- 🚀 **AOT cache support** - Optional performance optimization
- 📊 **Resource configuration** - Customizable RAM allocation and port settings
- 🔐 **OAuth2 authentication** - Guided Hytale account authentication

## 📋 Requirements

### Minimum
- Linux-based OS (Ubuntu, Debian, CentOS, etc.)
- `bash` 5.0+
- `curl` or `wget`
- `unzip`
- 4GB RAM (8GB+ recommended)
- ~10GB disk space

### Auto-installed (if root)
- Java 25 (Adoptium/Eclipse Temurin)
- `unzip`, `curl`, `wget`, `screen`

## 🚀 Quick Start

### Download and run:
```bash
wget https://raw.githubusercontent.com/c44738708-sys/hytale-server-setup/main/setup_hytale.sh
chmod +x setup_hytale.sh
./setup_hytale.sh
