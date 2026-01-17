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
```

Or with curl:
```bash
curl -O https://raw.githubusercontent.com/c44738708-sys/hytale-server-setup/main/setup_hytale.sh
chmod +x setup_hytale.sh
./setup_hytale.sh
```

### One-liner (auto-run):
```bash
bash <(curl -s https://raw.githubusercontent.com/c44738708-sys/hytale-server-setup/main/setup_hytale.sh)
```

## 📖 Installation Modes

### 🔴 Root Mode (System-wide)
```bash
sudo ./setup_hytale.sh
```
- Installs to `/opt/hytale-server` (default)
- Creates dedicated `hytale` service user
- Installs Java system-wide
- Creates systemd service
- Installs required dependencies

### 🔵 User Mode (Local)
```bash
./setup_hytale.sh
```
- Installs to `~/hytale-server` (default)
- Uses current user
- Installs Java locally
- No root privileges required

## 🎯 Installation Options

During installation, you'll be prompted to configure:

1. **Server Installation Directory**
   - Default: `/opt/hytale-server` (root) or `~/hytale-server` (user)
   - Current directory: `$(pwd)/hytale-server`
   - Custom path: Specify your own

2. **Java Installation Directory**
   - Default: `/opt/java` (root) or `~/java` (user)
   - Custom path: Specify your own

3. **Server Configuration**
   - RAM allocation (default: 4G)
   - Server port (default: 5520 UDP)

## 🎮 Usage

### Root Installation (Systemd Service)

```bash
# Start server
sudo systemctl start hytale

# Stop server
sudo systemctl stop hytale

# Restart server
sudo systemctl restart hytale

# Enable on boot
sudo systemctl enable hytale

# Check status
sudo systemctl status hytale

# View logs (live)
sudo journalctl -u hytale -f
```

### User Installation

```bash
cd ~/hytale-server  # or your custom path

# Normal start
./start.sh

# Start with AOT cache (faster)
./start-aot.sh

# Start with auto-restart
./restart-loop.sh

# Run in background (screen)
screen -S hytale
./start.sh
# Press Ctrl+A, then D to detach
# screen -r hytale to reattach
```

## 🔐 First-Time Authentication

1. Start the server
2. In the console, type: `/auth login device`
3. You'll receive a code (e.g., `ABCD-1234`)
4. Open: https://accounts.hytale.com/device
5. Enter the code
6. Make yourself admin: `/op add YourUsername`

## 🛠️ Included Scripts

All scripts are created in the server directory:

| Script | Description |
|--------|-------------|
| `start.sh` | Start server normally |
| `start-aot.sh` | Start with AOT cache (performance) |
| `restart-loop.sh` | Auto-restart on crash |
| `update.sh` | Update server files |
| `backup.sh` | Backup world and config |
| `version.sh` | Check versions |
| `auth.sh` | Authentication help |

## 🎛️ Server Commands

### Console Commands
```
/auth login device    # Authenticate server (first time)
/op add USERNAME      # Add admin
/op self              # Make yourself admin
/stop                 # Stop server
/kick PLAYER          # Kick player
/who                  # List online players
/tp PLAYER            # Teleport to player
/time set VALUE       # Change time
/weather set VALUE    # Change weather
```

## 🌐 Networking

### Port Configuration
- **Protocol:** UDP (QUIC)
- **Default Port:** 5520
- **Port Forwarding:** Required for external access

### Firewall Configuration

**Root:**
```bash
sudo ufw allow 5520/udp
# or
sudo iptables -A INPUT -p udp --dport 5520 -j ACCEPT
```

**User:**
```bash
sudo ufw allow 5520/udp
```

### Find Public IP
```bash
curl ifconfig.me
```

Players connect to: `<YOUR_PUBLIC_IP>:5520`

## 🔧 Configuration

### Change RAM Allocation
Edit `start.sh` and modify:
```bash
java -Xmx4G -Xms4G ...
```
Change `4G` to your desired amount (e.g., `8G`, `16G`)

### Change Port
Port configuration is in: `Server/config/server.properties`

### Server Files Location
- **Server files:** `<install_dir>/Server/`
- **Config:** `<install_dir>/Server/config/`
- **World:** `<install_dir>/world/`
- **Logs:** `<install_dir>/Server/logs/`

## 🐛 Troubleshooting

### Java not found
```bash
# User mode
source ~/.bashrc

# Root mode
source /etc/profile.d/java.sh
```

### Check Java version
```bash
java -version  # Must be 25
```

### Re-authenticate
```bash
rm -rf ~/.config/hytale-downloader/
./hytale-downloader
```

### View logs
```bash
# Root mode
sudo journalctl -u hytale -f

# User mode
tail -f Server/logs/latest.log
```

### Server won't start
1. Verify Assets.zip exists in server root
2. Check Java version is 25
3. Verify HytaleServer.jar exists in Server/
4. Check logs for errors

## 📁 Directory Structure

```
hytale-server/
├── hytale-downloader       # CLI tool for download/update
├── Server/                 # Hytale server files
│   ├── HytaleServer.jar
│   ├── config/
│   └── logs/
├── Assets.zip              # Game assets (required)
├── world/                  # World save files
├── start.sh                # Normal start script
├── start-aot.sh            # AOT cache start
├── restart-loop.sh         # Auto-restart script
├── auth.sh                 # Authentication helper
├── update.sh               # Update script
├── backup.sh               # Backup script
├── version.sh              # Version checker
└── README.txt              # Server documentation
```

## 🔄 Updating

### Auto-update
```bash
cd /path/to/hytale-server
./update.sh
```

### Manual update
```bash
./hytale-downloader
```

### Script update
```bash
wget -O setup_hytale.sh https://raw.githubusercontent.com/c44738708-sys/hytale-server-setup/main/setup_hytale.sh
chmod +x setup_hytale.sh
```

## 🗑️ Uninstallation

### Root Installation
```bash
# Stop and disable service
sudo systemctl stop hytale
sudo systemctl disable hytale

# Remove files
sudo rm -rf /opt/hytale-server
sudo rm -rf /opt/java
sudo rm /etc/systemd/system/hytale.service
sudo systemctl daemon-reload

# Remove service user (optional)
sudo userdel -r hytale
```

### User Installation
```bash
rm -rf ~/hytale-server
rm -rf ~/java

# Remove from .bashrc
sed -i '/Java 25 Setup for Hytale/,+2d' ~/.bashrc
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This is an unofficial installation script for Hytale Dedicated Server. Hytale and all related assets are property of Hypixel Studios. This script simply automates the installation process using official Hytale tools.

## 🔗 Links

- [Hytale Official Website](https://hytale.com)
- [Hytale Support](https://support.hytale.com)
- [Hytale Server Manual](https://support.hytale.com/hc/en-us/articles/45326769420827-Hytale-Server-Manual)
- [Adoptium Java Downloads](https://adoptium.net/)

## 📞 Support

If you encounter issues:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review server logs
3. Open an [Issue](https://github.com/c44738708-sys/hytale-server-setup/issues)
4. Check [Hytale Support](https://support.hytale.com)

## ⭐ Star History

If this script helped you, please consider giving it a star!

---

**Made with ❤️ for the Hytale community**
