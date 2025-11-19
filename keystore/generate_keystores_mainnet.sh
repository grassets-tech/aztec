#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <count of keys>"
  exit 1
fi

COUNT="$1"

# Directory to store keystores
DATA_DIR=""
URL_RPC=""
GSE="0xa92ecFD0E70c9cd5E5cd76c50Af0F7Da93567a4f"
# Current date
date=$(date +%F)
time=$(date +%H-%M)

# Loop to create N keystores
for i in $(seq 1 "$COUNT"); do
  echo "Creating keystore $i for date $date..."

  # Define keystore filename
  KEYSTORE_FILE="keystore-$date-$time-$i.json"

  # Run aztec command and capture output
  OUTPUT=$(aztec validator-keys new \
    --fee-recipient 0x0000000000000000000000000000000000000000000000000000000000000000 \
    --data-dir "$DATA_DIR" \
    --staker-output \
    --gse-address "$GSE" \
    --l1-rpc-urls "$URL_RPC" \
    --file "$KEYSTORE_FILE" 2>&1)

  echo "$OUTPUT"

  # Extract ETH and BLS addresses using grep/sed
  ETH=$(echo "$OUTPUT" | grep "eth:" | sed -E 's/.*eth:\s*([0-9a-zA-Zx]+).*/\1/')
  BLS=$(echo "$OUTPUT" | grep "bls:" | sed -E 's/.*bls:\s*([0-9a-zA-Zx]+).*/\1/')
  #MNEMONIC=$(echo "$OUTPUT" | awk '/Using new mnemonic:/ {flag=1; next} flag && NF {print; exit}')
  MNEMONIC=$(echo "$OUTPUT" | grep -A 2 "Using new mnemonic" | tail -n 1)

  echo mnemonic...
  echo $MNEMONIC

  # Check extraction succeeded
  if [[ -z "$ETH" || -z "$BLS" ]]; then
    echo "⚠️ Failed to extract keys for keystore $i"
    continue
  fi

  # Clean ETH address for filename (remove 0x and make lowercase)
  ETH_CLEAN=$(echo "$ETH" | tr '[:upper:]' '[:lower:]' | sed 's/^0x//')

  MNEMONIC_CLEAN=$(echo "$MNEMONIC" | tr -d '\r' | xargs)

  # Create mapping JSON file
  MAP_FILE="$DATA_DIR/keystore-$date-$time-$i-$ETH_CLEAN-map.json"
#  cat > "$MAP_FILE" <<EOF
#{
#  "keystore": "$KEYSTORE_FILE",
#  "eth": "$ETH",
#  "bls": "$BLS",
#  "mnemonic": "$MNEMONIC_CLEAN"
#}
#EOF
#
jq -n \
  --arg keystore "$KEYSTORE_FILE" \
  --arg eth "$ETH_CLEAN" \
  --arg bls "$BLS" \
  --arg mnemonic "$MNEMONIC_CLEAN" \
  '{
    keystore: $keystore,
    eth: $eth,
    bls: $bls,
    mnemonic: $mnemonic
  }' > "$MAP_FILE"

  echo "✅ Created map file: $MAP_FILE"
done

echo "🎉 All done!"

