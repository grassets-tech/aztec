#!/bin/bash

# Check for keystore file argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 <keystore-json-file>"
  exit 1
fi

KEYSTORES_FILE="$1"

# CONFIGURATION -- edit these as needed
STAKING_REGISTRY_ADDRESS="0x042dF8f42790d6943F41C25C2132400fd727f452"
YOUR_PROVIDER_IDENTIFIER="" # your provider ID
RPC_URL="" # configure correct ETH network
ADMIN_PRIVATE_KEY="" # Admin private key, specified in provider register

keys_array_str="["
first=1

json_entries=$(jq -c '.[]' "$KEYSTORES_FILE")

while IFS= read -r entry; do
  attester=$(jq -r '.attester'<<<"$entry")

  pkG1_x=$(jq -r '.publicKeyG1.x'<<<"$entry")
  pkG1_y=$(jq -r '.publicKeyG1.y'<<<"$entry")

  pkG2_x0=$(jq -r '.publicKeyG2.x0'<<<"$entry")
  pkG2_x1=$(jq -r '.publicKeyG2.x1'<<<"$entry")
  pkG2_y0=$(jq -r '.publicKeyG2.y0'<<<"$entry")
  pkG2_y1=$(jq -r '.publicKeyG2.y1'<<<"$entry")

  pop_x=$(jq -r '.proofOfPossession.x'<<<"$entry")
  pop_y=$(jq -r '.proofOfPossession.y'<<<"$entry")

  strip0x() {
    echo "$1" | sed 's/^0x//'
  }

  attester_str=$attester
  pkG1_x_str="0x$(strip0x $pkG1_x)"
  pkG1_y_str="0x$(strip0x $pkG1_y)"
  pkG2_x0_str="0x$(strip0x $pkG2_x0)"
  pkG2_x1_str="0x$(strip0x $pkG2_x1)"
  pkG2_y0_str="0x$(strip0x $pkG2_y0)"
  pkG2_y1_str="0x$(strip0x $pkG2_y1)"
  pop_x_str="0x$(strip0x $pop_x)"
  pop_y_str="0x$(strip0x $pop_y)"

  tuple="($attester_str,($pkG1_x_str,$pkG1_y_str),($pkG2_x0_str,$pkG2_x1_str,$pkG2_y0_str,$pkG2_y1_str),($pop_x_str,$pop_y_str))"

  if [ $first -eq 1 ]; then
    keys_array_str+="$tuple"
    first=0
  else
    keys_array_str+=",$tuple"
  fi
done <<< "$json_entries"

keys_array_str+="]"

echo "cast send $STAKING_REGISTRY_ADDRESS \
\"addKeysToProvider(uint256,(address,(uint256,uint256),(uint256,uint256,uint256,uint256),(uint256,uint256))[])\" \
$YOUR_PROVIDER_IDENTIFIER \
\"$keys_array_str\" \
--rpc-url $RPC_URL \
--private-key $ADMIN_PRIVATE_KEY"
