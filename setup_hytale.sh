#!/bin/bash

# Hytale Server Setup Script - Auto-detect root/user mode with custom directory
# Automatically detects permissions and installs accordingly
# Author: AI
# Date: 2026-01-17

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Hytale Server Setup Script - v1.0           ║${NC}"
echo -e "${GREEN}║   Auto-detect Root/User Mode                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Detect if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${BLUE}[*] Running as ROOT - System-wide installation available${NC}"
    IS_ROOT=true
    DEFAULT_HYTALE_DIR="/opt/hytale-server"
    DEFAULT_JAVA_DIR="/opt/java"
    SERVICE_USER="hytale"
else
    echo -e "${BLUE}[*] Running as USER - User-mode installation${NC}"
    IS_ROOT=false
    DEFAULT_HYTALE_DIR="$HOME/hytale-server"
    DEFAULT_JAVA_DIR="$HOME/java"
    SERVICE_USER="$USER"
fi

CURRENT_DIR="$(pwd)"

echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Installation Directory Configuration${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
echo "Choose installation directory:"
echo ""
echo -e "  ${GREEN}1)${NC} Default directory:  ${YELLOW}$DEFAULT_HYTALE_DIR${NC}"
echo -e "  ${GREEN}2)${NC} Current directory:  ${YELLOW}$CURRENT_DIR/hytale-server${NC}"
echo -e "  ${GREEN}3)${NC} Custom directory:   ${YELLOW}(specify your own path)${NC}"
echo ""
read -p "Enter your choice [1-3] (press ENTER for default): " DIR_CHOICE

case $DIR_CHOICE in
    2)
        HYTALE_DIR="$CURRENT_DIR/hytale-server"
        echo -e "${GREEN}[✓] Using current directory: $HYTALE_DIR${NC}"
        ;;
    3)
        echo ""
        read -p "Enter custom installation path: " CUSTOM_PATH
        if [ -z "$CUSTOM_PATH" ]; then
            HYTALE_DIR="$DEFAULT_HYTALE_DIR"
            echo -e "${YELLOW}[!] No path specified, using default: $HYTALE_DIR${NC}"
        else
            # Expand ~ to home directory
            HYTALE_DIR="${CUSTOM_PATH/#\~/$HOME}"
            echo -e "${GREEN}[✓] Using custom directory: $HYTALE_DIR${NC}"
        fi
        ;;
    1|"")
        HYTALE_DIR="$DEFAULT_HYTALE_DIR"
        echo -e "${GREEN}[✓] Using default directory: $HYTALE_DIR${NC}"
        ;;
    *)
        echo -e "${YELLOW}[!] Invalid choice, using default: $DEFAULT_HYTALE_DIR${NC}"
        HYTALE_DIR="$DEFAULT_HYTALE_DIR"
        ;;
esac

echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Java Installation Configuration${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
echo "Choose Java installation directory:"
echo ""
echo -e "  ${GREEN}1)${NC} Default directory:  ${YELLOW}$DEFAULT_JAVA_DIR${NC}"
echo -e "  ${GREEN}2)${NC} Custom directory:   ${YELLOW}(specify your own path)${NC}"
echo ""
read -p "Enter your choice [1-2] (press ENTER for default): " JAVA_DIR_CHOICE

case $JAVA_DIR_CHOICE in
    2)
        echo ""
        read -p "Enter custom Java installation path: " CUSTOM_JAVA_PATH
        if [ -z "$CUSTOM_JAVA_PATH" ]; then
            JAVA_INSTALL_DIR="$DEFAULT_JAVA_DIR"
            echo -e "${YELLOW}[!] No path specified, using default: $JAVA_INSTALL_DIR${NC}"
        else
            JAVA_INSTALL_DIR="${CUSTOM_JAVA_PATH/#\~/$HOME}"
            echo -e "${GREEN}[✓] Using custom directory: $JAVA_INSTALL_DIR${NC}"
        fi
        ;;
    1|"")
        JAVA_INSTALL_DIR="$DEFAULT_JAVA_DIR"
        echo -e "${GREEN}[✓] Using default directory: $JAVA_INSTALL_DIR${NC}"
        ;;
    *)
        echo -e "${YELLOW}[!] Invalid choice, using default: $DEFAULT_JAVA_DIR${NC}"
        JAVA_INSTALL_DIR="$DEFAULT_JAVA_DIR"
        ;;
esac

# Set profile file based on mode
if [ "$IS_ROOT" = true ]; then
    PROFILE_FILE="/etc/profile.d/java.sh"
else
    PROFILE_FILE="$HOME/.bashrc"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Server Configuration${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
echo "Configure server settings:"
echo ""
read -p "Server RAM allocation (default: 4G): " RAM_INPUT
SERVER_RAM="${RAM_INPUT:-4G}"
echo -e "${GREEN}[✓] RAM allocation set to: $SERVER_RAM${NC}"

echo ""
read -p "Server port (default: 5520): " PORT_INPUT
SERVER_PORT="${PORT_INPUT:-5520}"
echo -e "${GREEN}[✓] Server port set to: $SERVER_PORT${NC}"

# Configuration
JAVA_VERSION="25"
DOWNLOADER_URL="https://downloader.hytale.com/hytale-downloader.zip"

echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Installation Summary${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Installation mode:   ${BLUE}$([ "$IS_ROOT" = true ] && echo "ROOT (system-wide)" || echo "USER (local)")${NC}"
echo -e "  Server directory:    ${YELLOW}$HYTALE_DIR${NC}"
echo -e "  Java directory:      ${YELLOW}$JAVA_INSTALL_DIR${NC}"
echo -e "  Service user:        ${YELLOW}$SERVICE_USER${NC}"
echo -e "  Server RAM:          ${YELLOW}$SERVER_RAM${NC}"
echo -e "  Server port:         ${YELLOW}UDP $SERVER_PORT${NC}"
echo ""
read -p "Proceed with installation? [Y/n]: " CONFIRM

if [[ $CONFIRM =~ ^[Nn]$ ]]; then
    echo -e "${RED}[!] Installation cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}[+] Starting installation...${NC}"
echo ""

# Function to check Java 25
check_java() {
    if command -v java &> /dev/null; then
        JAVA_VER=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | cut -d'.' -f1)
        if [ "$JAVA_VER" = "25" ]; then
            echo -e "${GREEN}[✓] Java 25 detected!${NC}"
            JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
            export JAVA_HOME
            export PATH="$JAVA_HOME/bin:$PATH"
            return 0
        else
            echo -e "${YELLOW}[!] Java $JAVA_VER found, but Hytale requires Java 25${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}[!] Java is not installed${NC}"
        return 1
    fi
}

# Function to install Java 25
install_java25() {
    echo -e "${GREEN}[+] Installing Java 25...${NC}"
    
    # Detect architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            ARCH_TYPE="x64"
            ;;
        aarch64)
            ARCH_TYPE="aarch64"
            ;;
        *)
            echo -e "${RED}[!] Unsupported architecture: $ARCH${NC}"
            exit 1
            ;;
    esac
    
    # Create installation directory
    mkdir -p "$JAVA_INSTALL_DIR"
    cd "$JAVA_INSTALL_DIR"
    
    # Download JDK 25 from Adoptium
    echo "[+] Downloading JDK 25 for ${ARCH_TYPE}..."
    JDK_URL="https://api.adoptium.net/v3/binary/latest/${JAVA_VERSION}/ga/linux/${ARCH_TYPE}/jdk/hotspot/normal/eclipse"
    
    if command -v wget &> /dev/null; then
        wget -q --show-progress -O jdk25.tar.gz "$JDK_URL" || {
            echo -e "${RED}[!] Error downloading JDK${NC}"
            exit 1
        }
    elif command -v curl &> /dev/null; then
        curl -L --progress-bar -o jdk25.tar.gz "$JDK_URL" || {
            echo -e "${RED}[!] Error downloading JDK${NC}"
            exit 1
        }
    else
        echo -e "${RED}[!] wget or curl not installed!${NC}"
        if [ "$IS_ROOT" = true ]; then
            echo "[+] Installing wget..."
            apt-get update && apt-get install -y wget
            wget -q --show-progress -O jdk25.tar.gz "$JDK_URL"
        else
            exit 1
        fi
    fi
    
    # Extract archive
    echo "[+] Extracting JDK 25..."
    tar -xzf jdk25.tar.gz
    rm jdk25.tar.gz
    
    # Find JDK directory
    JDK_DIR=$(find "$JAVA_INSTALL_DIR" -maxdepth 1 -type d -name "jdk*" | head -n 1)
    if [ -z "$JDK_DIR" ]; then
        echo -e "${RED}[!] JDK directory not found!${NC}"
        exit 1
    fi
    
    JAVA_HOME="$JDK_DIR"
    
    # Configure environment variables based on mode
    if [ "$IS_ROOT" = true ]; then
        # System-wide installation
        echo "[+] Configuring system-wide Java environment..."
        cat > "$PROFILE_FILE" << EOF
# Java 25 Setup for Hytale
export JAVA_HOME="$JAVA_HOME"
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF
        chmod +x "$PROFILE_FILE"
        
        # Also set for current session
        export JAVA_HOME="$JAVA_HOME"
        export PATH="$JAVA_HOME/bin:$PATH"
        
        # Create symlinks in /usr/local/bin for convenience
        ln -sf "$JAVA_HOME/bin/java" /usr/local/bin/java
        ln -sf "$JAVA_HOME/bin/javac" /usr/local/bin/javac
        
    else
        # User-mode installation
        echo "[+] Configuring user Java environment..."
        if ! grep -q "export JAVA_HOME=" "$PROFILE_FILE" 2>/dev/null; then
            echo "" >> "$PROFILE_FILE"
            echo "# Java 25 Setup for Hytale" >> "$PROFILE_FILE"
            echo "export JAVA_HOME=\"$JAVA_HOME\"" >> "$PROFILE_FILE"
            echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> "$PROFILE_FILE"
        else
            sed -i "s|export JAVA_HOME=.*|export JAVA_HOME=\"$JAVA_HOME\"|g" "$PROFILE_FILE"
        fi
        
        # Export for current session
        export JAVA_HOME="$JAVA_HOME"
        export PATH="$JAVA_HOME/bin:$PATH"
    fi
    
    echo -e "${GREEN}[✓] Java 25 installed successfully!${NC}"
    java -version
}

# Check and install Java if needed
if ! check_java; then
    install_java25
fi

echo ""
echo "================================================"
echo -e "${GREEN}[+] Setting up Hytale Server${NC}"
echo "================================================"

# Install dependencies if root
if [ "$IS_ROOT" = true ]; then
    echo "[+] Installing required packages..."
    apt-get update
    apt-get install -y unzip curl wget screen
    
    # Create service user if doesn't exist
    if ! id "$SERVICE_USER" &>/dev/null; then
        echo "[+] Creating service user: $SERVICE_USER"
        useradd -r -m -d /home/hytale -s /bin/bash "$SERVICE_USER"
    fi
else
    # Check for unzip
    if ! command -v unzip &> /dev/null; then
        echo -e "${RED}[!] unzip is not installed!${NC}"
        echo -e "${YELLOW}[!] Please install with: sudo apt install unzip${NC}"
        exit 1
    fi
fi

# Create server directory
mkdir -p "$HYTALE_DIR"
cd "$HYTALE_DIR"

# Set ownership if root
if [ "$IS_ROOT" = true ]; then
    chown -R "$SERVICE_USER:$SERVICE_USER" "$HYTALE_DIR"
fi

# Download Hytale Downloader
echo "[+] Downloading Hytale Downloader from downloader.hytale.com..."

if command -v wget &> /dev/null; then
    wget -q --show-progress -O hytale-downloader.zip "$DOWNLOADER_URL" || {
        echo -e "${RED}[!] Error downloading Hytale Downloader${NC}"
        exit 1
    }
elif command -v curl &> /dev/null; then
    curl -L --progress-bar -o hytale-downloader.zip "$DOWNLOADER_URL" || {
        echo -e "${RED}[!] Error downloading Hytale Downloader${NC}"
        exit 1
    }
fi

# Extract zip
echo "[+] Extracting hytale-downloader.zip..."
unzip -q hytale-downloader.zip
rm hytale-downloader.zip

# Detect executable
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        DOWNLOADER_BIN="hytale-downloader-linux-amd64"
        ;;
    aarch64)
        DOWNLOADER_BIN="hytale-downloader-linux-arm64"
        ;;
    *)
        echo -e "${RED}[!] Unsupported architecture for Hytale${NC}"
        exit 1
        ;;
esac

# Check if executable exists
if [ ! -f "$DOWNLOADER_BIN" ]; then
    echo -e "${YELLOW}[!] Executable $DOWNLOADER_BIN not found${NC}"
    echo "[+] Available files in archive:"
    ls -la
    echo -e "${YELLOW}[!] Manually select the executable and rename it to 'hytale-downloader'${NC}"
    exit 1
fi

# Rename for convenience
mv "$DOWNLOADER_BIN" hytale-downloader
chmod +x hytale-downloader

# Set ownership if root
if [ "$IS_ROOT" = true ]; then
    chown -R "$SERVICE_USER:$SERVICE_USER" "$HYTALE_DIR"
fi

echo -e "${GREEN}[✓] Hytale Downloader installed${NC}"
echo ""
echo -e "${YELLOW}[!] ATTENTION: You will need to authenticate with your Hytale account${NC}"
echo -e "${YELLOW}[!] Follow the instructions for OAuth2 device authentication${NC}"
echo ""

if [ "$IS_ROOT" = true ]; then
    echo -e "${BLUE}[*] Running as service user: $SERVICE_USER${NC}"
    echo "[+] Downloading server files as $SERVICE_USER..."
    su - "$SERVICE_USER" -c "cd $HYTALE_DIR && ./hytale-downloader" || {
        echo -e "${RED}[!] Error downloading server files${NC}"
        echo -e "${YELLOW}[!] If you have authentication issues, run manually:${NC}"
        echo -e "${YELLOW}    sudo su - $SERVICE_USER${NC}"
        echo -e "${YELLOW}    cd $HYTALE_DIR && ./hytale-downloader${NC}"
    }
else
    read -p "Press ENTER to continue with server files download..."
    # Download server files
    echo "[+] Downloading Hytale server files..."
    ./hytale-downloader || {
        echo -e "${RED}[!] Error downloading server files${NC}"
        echo -e "${YELLOW}[!] If you have authentication issues, run manually:${NC}"
        echo -e "${YELLOW}    cd $HYTALE_DIR && ./hytale-downloader${NC}"
    }
fi

# Verify download success
if [ ! -d "Server" ] && [ ! -f "Assets.zip" ]; then
    echo -e "${YELLOW}[!] Verifying file structure...${NC}"
    echo "[+] Continuing with setup, but verify files manually!"
fi

echo -e "${GREEN}[✓] Server files downloaded${NC}"

# Create start script with custom RAM
echo "[+] Creating start script..."
cat > start.sh << EOF
#!/bin/bash

# Hytale Server Start Script
# RAM allocation: $SERVER_RAM

cd "\$(dirname "\$0")"

# Check Java
if ! command -v java &> /dev/null; then
    echo "[!] Java not found in PATH!"
    echo "[!] Run: source ~/.bashrc (or source /etc/profile.d/java.sh for root install)"
    exit 1
fi

# Check Java version
JAVA_VER=\$(java -version 2>&1 | head -n 1 | awk -F '"' '{print \$2}' | cut -d'.' -f1)
if [ "\$JAVA_VER" != "25" ]; then
    echo "[!] Hytale requires Java 25, you have Java \$JAVA_VER"
    exit 1
fi

# Check server files
if [ ! -f "Server/HytaleServer.jar" ]; then
    echo "[!] HytaleServer.jar not found in Server/"
    echo "[!] Run: ./hytale-downloader to download files"
    exit 1
fi

if [ ! -f "Assets.zip" ]; then
    echo "[!] Assets.zip not found!"
    echo "[!] Run: ./hytale-downloader to download files"
    exit 1
fi

# Launch CORRECT command for Hytale server with --assets argument
java -Xmx$SERVER_RAM -Xms$SERVER_RAM -jar Server/HytaleServer.jar --assets Assets.zip

EOF

chmod +x start.sh

# Create AOT cache script (optional, for performance)
cat > start-aot.sh << EOF
#!/bin/bash

# Hytale Server Start Script with AOT Cache
# RAM allocation: $SERVER_RAM

cd "\$(dirname "\$0")"

# Check Java
if ! command -v java &> /dev/null; then
    echo "[!] Java not found in PATH!"
    exit 1
fi

# Launch with AOT cache for improved performance
java -XX:AOTCache=HytaleServer.aot -Xmx$SERVER_RAM -Xms$SERVER_RAM -jar Server/HytaleServer.jar --assets Assets.zip

EOF

chmod +x start-aot.sh

# Create auto-restart script
cat > restart-loop.sh << 'EOF'
#!/bin/bash

# Auto-restart script for Hytale Server

while true; do
    echo "[+] Starting Hytale Server..."
    ./start.sh
    
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo "[!] Server stopped normally"
        break
    else
        echo "[!] Server crashed with code: $EXIT_CODE"
        echo "[+] Restarting in 10 seconds..."
        sleep 10
    fi
done

EOF

chmod +x restart-loop.sh

# Create authentication helper script
cat > auth.sh << 'EOF'
#!/bin/bash

# Authentication helper script

echo "================================================"
echo "Hytale Server Authentication"
echo "================================================"
echo ""
echo "1. Start the server with: ./start.sh"
echo "2. Wait for it to fully load"
echo "3. In the server console, type: /auth login device"
echo "4. You will receive a code (e.g., ABCD-1234)"
echo "5. Open: https://accounts.hytale.com/device"
echo "6. Enter the received code"
echo "7. After authentication, the server will be functional"
echo ""
echo "Command to stop server: /stop"
echo "Command to add admin: /op add USERNAME"
echo ""
echo "================================================"

EOF

chmod +x auth.sh

# Create update script
cat > update.sh << 'EOF'
#!/bin/bash

# Update script for Hytale Server

echo "[+] Checking for available updates..."
./hytale-downloader -check-update

echo ""
read -p "Do you want to update the server? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "[+] Updating server files..."
    ./hytale-downloader
    echo "[+] Update complete!"
else
    echo "[!] Update cancelled"
fi

EOF

chmod +x update.sh

# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash

# Backup script for Hytale Server

BACKUP_DIR="$HOME/hytale-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SERVER_DIR="$(dirname "$0")"

mkdir -p "$BACKUP_DIR"

echo "[+] Creating backup: hytale-backup-${TIMESTAMP}.tar.gz"

tar -czf "$BACKUP_DIR/hytale-backup-${TIMESTAMP}.tar.gz" \
    --exclude='*.log' \
    --exclude='hytale-downloader*' \
    --exclude='*.zip' \
    -C "$SERVER_DIR" \
    Server world saves config 2>/dev/null

echo "[+] Backup completed: $BACKUP_DIR/hytale-backup-${TIMESTAMP}.tar.gz"

# Cleanup - keep only last 7 backups
cd "$BACKUP_DIR"
ls -t hytale-backup-*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm

echo "[+] Old backups cleaned (kept last 7)"

EOF

chmod +x backup.sh

# Create version check script
cat > version.sh << 'EOF'
#!/bin/bash

echo "================================================"
echo "Hytale Server - Version Info"
echo "================================================"
echo ""
echo "Game Version:"
./hytale-downloader -print-version
echo ""
echo "Downloader Version:"
./hytale-downloader -version
echo ""
echo "Java Version:"
java -version 2>&1 | head -n 3
echo ""
echo "================================================"

EOF

chmod +x version.sh

# Create systemd service if root
if [ "$IS_ROOT" = true ]; then
    echo "[+] Creating systemd service..."
    cat > /etc/systemd/system/hytale.service << EOF
[Unit]
Description=Hytale Dedicated Server
After=network.target

[Service]
Type=simple
User=$SERVICE_USER
Group=$SERVICE_USER
WorkingDirectory=$HYTALE_DIR
ExecStart=$HYTALE_DIR/start.sh
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

# Security settings
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    
    echo -e "${GREEN}[✓] Systemd service created${NC}"
fi

# Set final ownership if root
if [ "$IS_ROOT" = true ]; then
    chown -R "$SERVICE_USER:$SERVICE_USER" "$HYTALE_DIR"
    chmod -R 755 "$HYTALE_DIR"
fi

# Create README file with configuration info
cat > README.txt << EOF
=================================================
Hytale Server - Complete Setup
=================================================

INSTALLATION CONFIGURATION:
---------------------------
Installation Mode: $([ "$IS_ROOT" = true ] && echo "ROOT (system-wide)" || echo "USER (local)")
Server Directory: $HYTALE_DIR
Java Directory: $JAVA_INSTALL_DIR
Service User: $SERVICE_USER
Java Version: Java 25
Server RAM: $SERVER_RAM
Server Port: UDP $SERVER_PORT (QUIC over UDP)
Downloader: $DOWNLOADER_URL

QUICK START:
------------
EOF

if [ "$IS_ROOT" = true ]; then
    cat >> README.txt << 'EOF'

SYSTEMD SERVICE (ROOT INSTALLATION):
------------------------------------
sudo systemctl start hytale     # Start server
sudo systemctl stop hytale      # Stop server
sudo systemctl restart hytale   # Restart server
sudo systemctl enable hytale    # Enable on boot
sudo systemctl status hytale    # Check status
sudo journalctl -u hytale -f    # View logs (live)

FIRST TIME AUTHENTICATION:
--------------------------
1. sudo systemctl start hytale
2. sudo journalctl -u hytale -f
3. Look for authentication prompt
4. In server console: /auth login device
5. Open: https://accounts.hytale.com/device
6. Enter displayed code

EOF
else
    cat >> README.txt << EOF

USER MODE INSTALLATION:
-----------------------
cd $HYTALE_DIR
./start.sh

FIRST TIME AUTHENTICATION:
--------------------------
1. ./start.sh
2. In console: /auth login device
3. Open: https://accounts.hytale.com/device
4. Enter displayed code

RUN IN BACKGROUND:
------------------
screen -S hytale
./start.sh
# Ctrl+A, then D to detach
# screen -r hytale to reattach

EOF
fi

cat >> README.txt << EOF

COMMON COMMANDS:
----------------
cd $HYTALE_DIR
./start.sh       # Normal start
./start-aot.sh   # Start with AOT cache (faster)
./restart-loop.sh # Auto-restart on crash
./update.sh      # Update server files
./backup.sh      # Backup world and config
./version.sh     # Check versions
./auth.sh        # Authentication help

LAUNCH COMMAND:
---------------
java -Xmx$SERVER_RAM -Xms$SERVER_RAM -jar Server/HytaleServer.jar --assets Assets.zip

IN-GAME COMMANDS:
-----------------
/auth login device   # Authenticate (first time)
/op add USERNAME     # Add admin
/stop                # Stop server
/who                 # List players
/tp PLAYER           # Teleport

NETWORKING:
-----------
Port: UDP $SERVER_PORT (QUIC protocol, NOT TCP!)
Public IP: curl ifconfig.me
Connect to: <IP>:$SERVER_PORT

Port forwarding required on router!
$([ "$IS_ROOT" = true ] && echo "Firewall: ufw allow $SERVER_PORT/udp" || echo "Firewall: sudo ufw allow $SERVER_PORT/udp")

MODIFY SETTINGS:
----------------
RAM: Edit start.sh, change -Xmx$SERVER_RAM -Xms$SERVER_RAM
Port: Edit server config in Server/config/

TROUBLESHOOTING:
----------------
$([ "$IS_ROOT" = true ] && echo "Logs: sudo journalctl -u hytale -f" || echo "Logs: $HYTALE_DIR/Server/logs/latest.log")
Java check: java -version (must be 25)
$([ "$IS_ROOT" = false ] && echo "If Java not found: source ~/.bashrc")
Assets.zip must be in server root!

=================================================
EOF

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete!                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Installation Summary${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BLUE}Installation Mode:${NC}   $([ "$IS_ROOT" = true ] && echo "ROOT (system-wide)" || echo "USER (local)")"
echo -e "  ${BLUE}Java Version:${NC}        $(java -version 2>&1 | head -n 1)"
echo -e "  ${BLUE}JAVA_HOME:${NC}           $JAVA_HOME"
echo -e "  ${BLUE}Server Directory:${NC}    $HYTALE_DIR"
echo -e "  ${BLUE}Service User:${NC}        $SERVICE_USER"
echo -e "  ${BLUE}Server RAM:${NC}          $SERVER_RAM"
echo -e "  ${BLUE}Server Port:${NC}         UDP $SERVER_PORT"
echo ""

if [ "$IS_ROOT" = true ]; then
    echo -e "${GREEN}SYSTEMD SERVICE COMMANDS:${NC}"
    echo "  sudo systemctl start hytale"
    echo "  sudo systemctl enable hytale"
    echo "  sudo journalctl -u hytale -f"
    echo ""
    echo -e "${YELLOW}FIRST START:${NC}"
    echo "  1. sudo systemctl start hytale"
    echo "  2. sudo journalctl -u hytale -f"
    echo "  3. Follow authentication prompts"
else
    echo -e "${GREEN}QUICK START:${NC}"
    echo "  cd $HYTALE_DIR"
    echo "  ./start.sh"
    echo ""
    echo -e "${YELLOW}FOR BACKGROUND:${NC}"
    echo "  screen -S hytale"
    echo "  cd $HYTALE_DIR && ./start.sh"
    echo "  # Ctrl+A, D to detach"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
echo "See README.txt in $HYTALE_DIR for complete details!"
echo ""
