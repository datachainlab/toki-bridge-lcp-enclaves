FROM ghcr.io/datachainlab/toki-bridge-lcp-enclaves/intel-sgx-sdk:cb5743b676b9547d7cd0700de0192a690b90a033

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

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN mkdir -p /app /out $RUSTUP_HOME $CARGO_HOME && \
    chown $UID:$GID /app /out $RUSTUP_HOME $CARGO_HOME

USER $USERNAME
WORKDIR /app

ADD --chown=$UID:$GID ./scripts ./scripts
ADD --chown=$UID:$GID ./buildcommon.mk ./buildcommon.mk
ADD --chown=$UID:$GID ./buildenv.mk ./buildenv.mk
ADD --chown=$UID:$GID ./enclaves/$LCP_ELC_TYPE ./enclaves/$LCP_ELC_TYPE

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain $(cat ./enclaves/$LCP_ELC_TYPE/rust-toolchain) -y && \
    rustup component add rust-src && \
    cargo install xargo

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