#!/bin/sh

PROD_URL="https://mainnet.zircuit.com"
TEST_URL="http://localhost:8545"

deploy_url=""
if [ "$2" = "prod" ]; then
  deploy_url=$PROD_URL
elif [ "$2" = "test" ]; then
  deploy_url=$TEST_URL
else
  echo "Usage: $0 <script path> [prod|test]"
  exit 1
fi

forge script "$1" --fork-url "$deploy_url" --private-key $(cat ../priv.key) --broadcast -vvvv --verify --etherscan-api-key $(cat ../etherscan.key) --via-ir --optimize --optimizer-runs 100
