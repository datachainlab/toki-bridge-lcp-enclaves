FROM ghcr.io/datachainlab/toki-bridge-lcp-enclaves/intel-sgx-sdk:70724a0e3fd3818a75b9976da2957fc9b728f41c

ARG RUST_TOOLCHAIN_VERSION=nightly-2024-09-05
LABEL org.rust-lang.org.toolchain.version=$RUST_TOOLCHAIN_VERSION

ARG LCP_ELC_TYPE
LABEL finance.toki.lcp.enclave.elc=$LCP_ELC_TYPE

ARG DEPLOYMENT_NETWORK=localnet
LABEL finance.toki.lcp.enclave.network=$DEPLOYMENT_NETWORK

ENV DEBIAN_FRONTEND=noninteractive

ARG UID=1000
ARG GID=1000
ARG USERNAME=app

RUN set -eux; \
    # If a user with the same ID exists, delete and create.
    if getent passwd "$UID" > /dev/null; then \
        OLD_USER=$(getent passwd "$UID" | cut -d: -f1); \
        echo "Removing existing user: $OLD_USER"; \
        userdel -r "$OLD_USER" || true; \
    fi; \
    # If group does not exist, create group.
    if ! getent group "$GID" > /dev/null; then \
        groupadd -g "$GID" "$USERNAME"; \
    fi; \
    useradd -u "$UID" -g "$GID" -m "$USERNAME";

RUN mkdir -p /app && chown $UID:$GID /app
RUN mkdir -p /out && chown $UID:$GID /out

USER $USERNAME
WORKDIR /app

ADD --chown=$UID:$GID ./scripts ./scripts
ENV rust_toolchain=$RUST_TOOLCHAIN_VERSION
RUN bash ./scripts/install_rust.sh

SHELL ["/bin/bash", "-c", "-l"]

ADD --chown=$UID:$GID ./buildenv.mk ./buildenv.mk
ADD --chown=$UID:$GID ./enclaves/$LCP_ELC_TYPE ./enclaves/$LCP_ELC_TYPE

ARG SGX_MODE=HW
ENV SGX_MODE=$SGX_MODE
ENV LCP_ELC_TYPE=$LCP_ELC_TYPE
ENV DEPLOYMENT_NETWORK=$DEPLOYMENT_NETWORK

RUN make -C enclaves/$LCP_ELC_TYPE enclave/enclave_sig.dat

RUN cp enclaves/$LCP_ELC_TYPE/enclave/enclave.so \
    enclaves/$LCP_ELC_TYPE/enclave/Enclave.config.xml \
    enclaves/$LCP_ELC_TYPE/enclave/enclave_sig.dat \
    /out/

WORKDIR /out