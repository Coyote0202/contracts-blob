#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050";
# export RPC_URL="https://api.cartridge.gg/x/rr-demo/katana";
# export RPC_URL="https://starknet-sepolia.public.blastapi.io/rpc/v0_6";

export WORLD_ADDRESS="0x3a0394af68d1727a0019949a94fa584e8bc132903d49bb545888eb1bd427cf4"

export BLOBERT_ACTIONS="0x3e2408ea9affd43d731fcb31e67f7c2c6899cef4c1279dc597dc5d14b240d12"

export KNOCKOUT_ACTIONS="0x66821c7071e66a727918207afb0255e5dac1677b1732a95104c7672fc98d51e"

echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS 
echo " "
echo game actions : $BLOBERT_ACTIONS
echo " "
echo world event actions : $KNOCKOUT_ACTIONS
echo "---------------------------------------------------------------------------"

# enable system -> models authorizations
sozo auth grant --world $WORLD_ADDRESS --wait writer \
    Blobert,$BLOBERT_ACTIONS \
    Knockout,$BLOBERT_ACTIONS \
    TwoHashes,$BLOBERT_ACTIONS \
    TwoMoves,$BLOBERT_ACTIONS \
    Healths,$BLOBERT_ACTIONS \
    LastRound,$BLOBERT_ACTIONS \
    Blobert,$KNOCKOUT_ACTIONS \
    Knockout,$KNOCKOUT_ACTIONS \
    TwoHashes,$KNOCKOUT_ACTIONS \
    TwoMoves,$KNOCKOUT_ACTIONS \
    Healths,$KNOCKOUT_ACTIONS \
    LastRound,$KNOCKOUT_ACTIONS \
 > /dev/null
 
echo "Default authorizations have been successfully set."