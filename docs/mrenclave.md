# MRENCLAVE Derivation and Validation Process

This document describes how developers should derive and manage `MRENCLAVE` values for Intel SGX Enclaves during development and CI testing.

---

## When Does MRENCLAVE Change?

The `MRENCLAVE` value is sensitive to several factors. It may change if any of the following occurs:

1. Intel SGX SDK version is updated
2. Rust compiler version used during build changes
3. OS or toolchain versions involved in the build process are updated
4. Changes are made to the Enclave source code or dependencies
5. `Enclave.config.xml` is modified

> ⚠️ **Note:** The `MRENCLAVE` can be derived after the Enclave is signed.
In the workflow, a temporary private key is used as the Enclave signing key for testing purposes.
This key is different from the actual signing key used in production for toki.finance,
but the identity of the signing key has no effect on the derivation of the `MRENCLAVE`.

---

## Developer Responsibilities

When any of the above changes occur:

- The developer must build the Enclave locally
- Derive the corresponding `MRENCLAVE` value
- Commit the updated [mrenclaves.yaml](../mrenclaves.yaml) file

This file is used in the CI workflow triggered by a Pull Request. 

The workflow:
1. Builds a Docker image that includes the Enclave
2. Derives the `MRENCLAVE` from that image
3. Compares it with the locally committed version
4. Rejects the test if they do not match

---

## Deriving MRENCLAVE Locally

### Case: Global Changes (Affect All Enclaves)

If the SDK, Rust version, or toolchain/OS version changes (cases 1–3), all Enclaves must be rebuilt:

```bash
$ make all
```

This command will:

Build all Enclaves under the `enclaves` directory

Attempt to update [mrenclaves.yaml](../mrenclaves.yaml)

### Case: Localized Changes (Affect One Enclave)
If only the Enclave's source code, dependencies, or Enclave.config.xml are modified (cases 4–5), you can rebuild the specific Enclave:

```bash
$ make mrenclave LCP_TYPE=ethereum DEPLOYMENT_NETWORK=mainnet
```

If changes are detected, commit the updated [mrenclaves.yaml](../mrenclaves.yaml) to the repository.