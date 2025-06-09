#!/usr/bin/env bash

MATERIAL_DIR=$1

TEST_DIR='/tests/mrenclave'
mkdir -p $TEST_DIR

openssl genrsa -out $TEST_DIR/private_key.pem -3 3072
sgx_sign sign -key $TEST_DIR/private_key.pem -enclave $MATERIAL_DIR/enclave.so -config $MATERIAL_DIR/Enclave.config.xml -out $TEST_DIR/enclave_signed.so
sgx_sign dump -enclave $TEST_DIR/enclave_signed.so -dumpfile $TEST_DIR/metadata_info.txt

output=$(cat $TEST_DIR/metadata_info.txt | awk '/enclave_css.body.enclave_hash.m:/ {f=1; next} f && /^0x/ {gsub(/0x| /,""); printf $0; next} f && !/^0x/ {exit}')
if [ -n "$output" ]; then
  echo "0x$output" > $TEST_DIR/mrenclave.txt
else
  echo "Failed to get mrenclave value"
  exit 1
fi
