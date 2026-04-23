#!/bin/bash
set -e

INSTALL_DIR="/home/kali/tools/git_tools/burpsuitepro"
VERSION="2026.3.3"
JAR="burpsuite_pro_${VERSION}.jar"
URL="https://portswigger.net/burp/releases/download?product=pro&version=${VERSION}&type=Jar"

echo "[*] Installing dependencies..."
sudo apt update -y
sudo apt install -y curl openjdk-21-jre unzip

echo "[*] Preparing install directory..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "[*] Cleaning old versions..."
rm -f burpsuite_pro_*.jar
sudo rm -f /usr/local/bin/burpsuitepro

echo "[*] Downloading Burp Suite Professional ${VERSION}..."
curl -L -o "$JAR" "$URL"

echo "[*] Validating download..."

# Correcte validatie (JAR = ZIP)
if ! unzip -tq "$JAR" >/dev/null 2>&1; then
  echo "[!] Download is geen geldig JAR/ZIP bestand"
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
