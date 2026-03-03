#!/usr/bin/env bash
set -euo pipefail

APP_USER="${APP_USER:-appuser}"
REPO_URL="${REPO_URL:?REPO_URL is required}"
PROJECT_SUBDIR="${PROJECT_SUBDIR:-.}"

DB_HOST="${DB_HOST:-192.168.56.10}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-petclinic}"
DB_USER="${DB_USER:-petuser}"
DB_PASS="${DB_PASS:-petpass123}"

APP_HOME="/home/${APP_USER}"
PROJECT_DIR="${APP_HOME}/project"
APP_DIR="${APP_HOME}/app"

export DEBIAN_FRONTEND=noninteractive

echo "[1/8] Install packages"
apt-get update -y
apt-get install -y git ca-certificates curl openjdk-17-jdk

echo "[2/8] Ensure APP_USER exists"
id -u "${APP_USER}" &>/dev/null || useradd -m -s /bin/bash "${APP_USER}"

echo "[3/8] Clone/update repo"
if [ ! -d "${PROJECT_DIR}/.git" ]; then
  rm -rf "${PROJECT_DIR}"
  sudo -u "${APP_USER}" git clone -b petclinic-setup "${REPO_URL}" "${PROJECT_DIR}"
else
  sudo -u "${APP_USER}" git -C "${PROJECT_DIR}" pull
fi

echo "[4/8] Find folder with pom.xml"
PC_DIR="${PROJECT_DIR}/${PROJECT_SUBDIR}"
if [ ! -f "${PC_DIR}/pom.xml" ]; then
  echo "ERROR: pom.xml not found in ${PC_DIR}"
  echo "Fix PROJECT_SUBDIR in Vagrantfile to point to folder with pom.xml"
  exit 1
fi

echo "[5/8] Build with Maven Wrapper (mvnw)"
cd "${PC_DIR}"
chmod +x mvnw
sudo -u "${APP_USER}" ./mvnw -q test
sudo -u "${APP_USER}" ./mvnw -q package -DskipTests

JAR_PATH="$(ls -1 ${PC_DIR}/target/*.jar | head -n 1)"
test -f "${JAR_PATH}" || (echo "ERROR: jar not found in target/" && exit 1)

echo "[6/8] Copy jar to APP_DIR"
mkdir -p "${APP_DIR}"
cp "${JAR_PATH}" "${APP_DIR}/petclinic.jar"
chown -R "${APP_USER}:${APP_USER}" "${APP_DIR}"

echo "[7/8] systemd service"
cat >/etc/systemd/system/petclinic.service <<EOF
[Unit]
Description=Spring PetClinic
After=network.target

[Service]
User=${APP_USER}
WorkingDirectory=${APP_DIR}

Environment=DB_HOST=${DB_HOST}
Environment=DB_PORT=${DB_PORT}
Environment=DB_NAME=${DB_NAME}
Environment=DB_USER=${DB_USER}
Environment=DB_PASS=${DB_PASS}

Environment=SPRING_DATASOURCE_URL=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
Environment=SPRING_DATASOURCE_USERNAME=${DB_USER}
Environment=SPRING_DATASOURCE_PASSWORD=${DB_PASS}

ExecStart=/usr/bin/java -jar ${APP_DIR}/petclinic.jar
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[8/8] Start service"
systemctl daemon-reload
systemctl enable --now petclinic.service
systemctl --no-pager status petclinic.service || true

echo "OK: PetClinic доступний: http://localhost:8080"