#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Platinumwrist/go-ethereum.git"
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLONE_DIR="${DEPLOY_DIR}/go-ethereum-src"

echo "=============================================="
echo "  Platinumwrist/go-ethereum"
echo "  Ethereum Mainnet Full Node Deployment"
echo "=============================================="

echo "[1/6] Pre-flight checks..."
command -v docker >/dev/null 2>&1 || { echo "ERROR: Docker not installed."; exit 1; }
command -v docker compose >/dev/null 2>&1 || { echo "ERROR: Docker Compose not installed."; exit 1; }
echo "   Docker detected."

AVAIL_GB=$(df -BG "${DEPLOY_DIR}" | awk 'NR==2 {gsub(/G/,"","$4"); print $4}')
echo "   Available disk: ${AVAIL_GB}GB"
if [ "${AVAIL_GB}" -lt 500 ]; then
    echo "   WARNING: 2TB+ recommended for mainnet full node."
        read -rp "  Continue? [y/N]: " CONFIRM
            [[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 1
            fi

            echo "[2/6] Cloning repository..."
            if [ -d "${CLONE_DIR}" ]; then
                cd "${CLONE_DIR}" && git pull origin master
                else
                    git clone "${REPO_URL}" "${CLONE_DIR}"
                    fi

                    echo "[3/6] Staging deployment files..."
                    cp "${DEPLOY_DIR}/Dockerfile" "${CLONE_DIR}/Dockerfile"
                    cp "${DEPLOY_DIR}/docker-compose.yml" "${CLONE_DIR}/docker-compose.yml"
                    cp "${DEPLOY_DIR}/.env" "${CLONE_DIR}/.env"

                    echo "[4/6] Initializing JWT secret..."
                    cd "${CLONE_DIR}" && docker compose run --rm jwt-init

                    echo "[5/6] Building Geth image..."
                    docker compose build --no-cache geth

                    echo "[6/6] Launching stack..."
                    docker compose up -d

                    echo ""
                    echo "   DEPLOYMENT COMPLETE"
                    echo "  Geth RPC:        http://localhost:8545"
                    echo "  Geth WebSocket:  ws://localhost:8546"
                    echo "  Lighthouse API:  http://localhost:5052"
                    echo "  Geth Metrics:    http://localhost:6060"
                    echo ""
                    echo "   Full sync takes 2-7 days."
