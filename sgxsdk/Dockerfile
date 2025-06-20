FROM ubuntu:noble-20250529

ARG INTEL_SGX_SDK_VERSION=2.25.100.3
LABEL com.intel.sgx.sdk.version=$INTEL_SGX_SDK_VERSION

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /sgxsdk

# ref: https://github.com/intel/linux-sgx/blob/sgx_2.25/README.md#install-the-intelr-sgx-sdk
RUN apt update && apt install -y \
    build-essential=12.10ubuntu1 \
    curl file python-is-python3 && \
    rm -rf /var/lib/apt/lists/*

ENV INTEL_SGX_SDK_VERSION=$INTEL_SGX_SDK_VERSION

ADD ./scripts ./scripts
RUN bash ./scripts/install_sgx_sdk.sh
