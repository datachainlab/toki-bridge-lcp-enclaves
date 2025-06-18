FROM ghcr.io/datachainlab/toki-bridge-lcp-enclaves/intel-sgx-sdk:70724a0e3fd3818a75b9976da2957fc9b728f41c

ARG RUST_TOOLCHAIN_VERSION=nightly-2024-09-05
LABEL org.rust-lang.org.toolchain.version=$RUST_TOOLCHAIN_VERSION

ARG LCP_ELC_TYPE
LABEL finance.toki.lcp.enclave.elc=$LCP_ELC_TYPE

ARG DEPLOYMENT_NETWORK=localnet
LABEL finance.toki.lcp.enclave.network=$DEPLOYMENT_NETWORK

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

ADD ./scripts ./scripts
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

RUN mkdir -p /out && \
    cp enclaves/$LCP_ELC_TYPE/enclave/enclave.so \
    enclaves/$LCP_ELC_TYPE/enclave/Enclave.config.xml \
    enclaves/$LCP_ELC_TYPE/enclave/enclave_sig.dat \
    /out/

WORKDIR /out