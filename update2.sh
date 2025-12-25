#!/bin/bash
set -e

INSTALL_DIR="/home/kali/tools/git_tools/burpsuitepro"

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y wget openjdk-21-jre curl

echo "[*] Preparing install directory..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "[*] Removing old Burp versions..."
sudo rm -f "$INSTALL_DIR"/burpsuite_pro_*.jar
sudo rm -f /usr/local/bin/burpsuitepro

# Installing Dependencies
echo "Installing Dependencies..."

sudo apt update
sudo apt install git wget openjdk-21-jre -y

# Cloning (alleen nodig als je opnieuw alles wilt binnenhalen) - KIJKEN OF IK MIJN EIGEN FORK BINNEN KAN HALEN!!!!
#git clone https://github.com/xiv3r/Burpsuite-Professional.git

#cd /home/kali/tools/git_tools/burpsuitepro

echo "[*] Detecting latest Burp Suite Professional version..."

VERSION=$(curl -s https://portswigger.net/burp/releases \
  | grep -oP 'Professional / Community \K[0-9]+\.[0-9]+\.[0-9]+' \
  | sort -V \
  | tail -n1)

if [[ -z "$VERSION" ]]; then
  echo "[!] Could not determine latest version"
  exit 1
fi

echo "[*] Latest version found: $VERSION"

URL="https://portswigger-cdn.net/burp/releases/download?product=pro&version=${VERSION}&type=Jar"
JAR="burpsuite_pro_${VERSION}.jar"

echo "[*] Downloading Burp Suite Professional ${VERSION}..."
wget "$URL" -O "$JAR" --show-progress

# Execute Key Generator.
echo "Starting Key loader.jar..."

(java -jar loader.jar) &

# Execute Burp Suite Professional
echo "Executing Burpsuite Professional..."

echo "java --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$(pwd)/loader.jar -noverify -jar $(pwd)/burpsuite_pro_${VERSION}.jar &" > burpsuitepro
chmod +x burpsuitepro
sudo cp burpsuitepro /usr/local/bin/burpsuitepro
(./burpsuitepro)
