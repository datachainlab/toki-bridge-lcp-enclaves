#!/usr/bin/env bash

set -eux

MATERIAL_DIR=$1
OUTPUT_DIR=$2

mkdir -p $OUTPUT_DIR

openssl genrsa -out $OUTPUT_DIR/private_key.pem -3 3072

/opt/sgxsdk/bin/x64/sgx_sign sign -key $OUTPUT_DIR/private_key.pem -enclave $MATERIAL_DIR/enclave.so -config $MATERIAL_DIR/Enclave.config.xml -out $OUTPUT_DIR/enclave_signed.so
/opt/sgxsdk/bin/x64/sgx_sign dump -enclave $OUTPUT_DIR/enclave_signed.so -dumpfile $OUTPUT_DIR/metadata_info.txt

output=$(cat $OUTPUT_DIR/metadata_info.txt | awk '/enclave_css.body.enclave_hash.m:/ {f=1; next} f && /^0x/ {gsub(/0x| /,""); printf $0; next} f && !/^0x/ {exit}')
if [ -n "$output" ]; then
  if [[ $output =~ ^[0-9a-fA-F]{64}$ ]]; then
      echo "0x$output" > $OUTPUT_DIR/mrenclave.txt
  else
      echo "Invalid format: ${output}" >&2
      exit 1
  fi
else
  echo "Failed to get mrenclave value" >&2
  exit 1
fi
