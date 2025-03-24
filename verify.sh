#!/bin/sh

forge verify-contract "$1" "$2" --etherscan-api-key $(cat ../etherscan.key) --rpc-url https://mainnet.zircuit.com --constructor-args "$3"  --via-ir --flatten --optimizer-runs 100
