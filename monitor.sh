#!/usr/bin/env bash
set -euo pipefail

RPC_URL="${GETH_RPC_URL:-http://localhost:8545}"
BEACON_URL="${BEACON_API_URL:-http://localhost:5052}"

echo "── Execution Layer (Geth) ──"
SYNC=$(curl -sf "${RPC_URL}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')

if echo "${SYNC}" | grep -q '"result":false'; then
    echo "  Status: ✓ FULLY SYNCED"
else
    echo "  Status: ⟳ SYNCING"
    echo "${SYNC}" | jq '.result'
fi

PEERS=$(curl -sf "${RPC_URL}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' | jq -r '.result')
echo "  Peers: $((PEERS))"

echo ""
echo "── Consensus Layer (Lighthouse) ──"
curl -sf "${BEACON_URL}/eth/v1/node/syncing" | jq '.data'
