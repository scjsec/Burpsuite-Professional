#!/bin/bash
set -e

INSTALL_DIR="/home/kali/tools/git_tools/burpsuitepro"

echo "[*] Installing dependencies..."
sudo apt update -y
sudo apt install -y curl openjdk-21-jre unzip

echo "[*] Fetching latest Burp Suite version..."

VERSION=$(curl -s https://portswigger.net/burp/releases \
| grep -oP 'professional-community-\K[0-9-]+' \
| head -n1 \
| tr '-' '.')

if [ -z "$VERSION" ]; then
  echo "[!] Failed to determine the latest version"
  exit 1
fi

echo "[*] Latest version detected: $VERSION"

JAR="burpsuite_desktop_v${VERSION}.jar"
URL="https://portswigger.net/burp/releases/startdownload?product=desktop&type=jar&version=${VERSION}"

echo "[*] Preparing install directory..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "[*] Cleaning old versions..."
rm -f burpsuite_pro_*.jar
sudo rm -f /usr/local/bin/burpsuitepro

echo "[*] Downloading Burp Suite ${VERSION}..."
curl -L -o "$JAR" "$URL"

echo "[*] Validating download..."
if ! unzip -tq "$JAR" >/dev/null 2>&1; then
  echo "[!] Download is not a valid JAR/ZIP file"
  exit 1
fi

echo "[*] Starting Key loader..."
(java -jar loader.jar) &

echo "[*] Creating launcher..."

cat <<EOF > burpsuitepro
#!/bin/bash
java --add-opens=java.desktop/javax.swing=ALL-UNNAMED \
--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED \
-javaagent:$INSTALL_DIR/loader.jar \
-noverify \
-jar $INSTALL_DIR/$JAR
EOF

chmod +x burpsuitepro
sudo cp burpsuitepro /usr/local/bin/burpsuitepro

echo "[*] Launching Burp Suite..."
./burpsuitepro
