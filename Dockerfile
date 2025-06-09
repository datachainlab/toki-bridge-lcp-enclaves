FROM ubuntu:noble-20250529

ARG INTEL_SGX_SDK_VERSION=2.25.100.3
LABEL com.intel.sgx.sdk.version=$INTEL_SGX_SDK_VERSION

ARG RUST_TOOLCHAIN_VERSION=nightly-2024-09-05
LABEL org.rust-lang.org.toolchain.version=$RUST_TOOLCHAIN_VERSION

ARG LCP_ELC_TYPE
LABEL finance.toki.lcp.enclave.elc=$LCP_ELC_TYPE

ARG DEPLOYMENT_NETWORK=localnet
LABEL finance.toki.lcp.enclave.network=$DEPLOYMENT_NETWORK

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# ref: https://github.com/intel/linux-sgx/blob/sgx_2.25/README.md#install-the-intelr-sgx-sdk
RUN apt update && apt install -y \
    build-essential=12.10ubuntu1 \
    curl file python-is-python3 && \
    rm -rf /var/lib/apt/lists/*

ENV INTEL_SGX_SDK_VERSION=$INTEL_SGX_SDK_VERSION

ADD ./scripts ./scripts
RUN bash ./scripts/install_build_dependencies.sh

ENV rust_toolchain=$RUST_TOOLCHAIN_VERSION
RUN bash ./scripts/install_rust.sh

SHELL ["/bin/bash", "-c", "-l"]

ADD ./buildenv.mk ./buildenv.mk
ADD ./enclaves/$LCP_ELC_TYPE ./enclaves/$LCP_ELC_TYPE

ARG SGX_MODE=HW
ENV SGX_MODE=$SGX_MODE
ENV LCP_ELC_TYPE=$LCP_ELC_TYPE
ENV DEPLOYMENT_NETWORK=$DEPLOYMENT_NETWORK

RUN make -C enclaves/$LCP_ELC_TYPE enclave/enclave_sig.dat

ENV OUTPUT_DIR=/out
RUN mkdir -p $OUTPUT_DIR && \
    cp enclaves/$LCP_ELC_TYPE/enclave/enclave.so \
    enclaves/$LCP_ELC_TYPE/enclave/Enclave.config.xml \
    enclaves/$LCP_ELC_TYPE/enclave/enclave_sig.dat \
    $OUTPUT_DIR/

RUN bash ./scripts/mrenclave.sh $OUTPUT_DIR

WORKDIR /out