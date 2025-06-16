# toki-bridge-lcp-enclaves

## Overview
1. Build and deploy Docker images of the Enclave Light Client (ELC) used by [toki.finance](https://toki.finance)
2. Publish and verify the MRENCLAVE value of each ELC enclave

This repository manages the configuration and Docker images of the [Enclave Light Client (ELC)](https://docs.lcp.network/protocol/elc/), which runs on the LightClientProxy (LCP) backend in toki.finance.

Each ELC runs inside a Trusted Execution Environment (TEE) powered by Intel SGX. It performs light client verification and generates commitment and proof data to relay messages between two blockchains.

In toki.finance, each blockchain is served by a dedicated LCP node running a single ELC. Therefore, this repository is structured as a collection of Cargo projects under the `enclaves/` directory, each building one enclave per supported network.

In addition, for each enclave, we publish its MRENCLAVE value—a unique measurement determined by its source code, configuration, and SGX SDK version—along with the corresponding build procedure.

We also provide instructions to verify that the MRENCLAVE derived from a specific build (either one we provide or built in your own environment) matches the MRENCLAVE registered in the on-chain LCPClient.  
This comparison guarantees that the deployed LCP node is running the expected enclave revision and logic.

## Build

You must specify the following build-time arguments:

| Parameter           | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| `LCP_ELC_TYPE`       | Name of the directory under `enclaves/` to build (e.g., `ethereum`, `parlia`, `optimism`) |
| `DEPLOYMENT_NETWORK`| Deployment target: `testnet` or `mainnet`                                   |

### Example

The following example builds a Docker image for the `ethereum` ELC targeting the `mainnet`.  
`LCP_ELC_TYPE` is set to `ethereum` and `DEPLOYMENT_NETWORK` is set to `mainnet`.

```bash
$ docker build -t toki-bridge-lcp-enclaves/ethereum/mainnet \
  --build-arg LCP_ELC_TYPE=ethereum \
  --build-arg DEPLOYMENT_NETWORK=mainnet .
```

## MRENCLAVE Verification
The MRENCLAVE is a unique measurement that ensures enclave integrity. It is deterministically derived from the enclave’s source code, Intel SGX SDK version, configuration files, and build environment.

When the MRENCLAVE derived from a local build matches the value recorded on-chain in the deployed LCPClient, it guarantees that the light client verification is being performed using the publicly available code revision.\

### Extracting the MRENCLAVE from the ELC
The following script extracts the MRENCLAVE value from the Docker image built for the Ethereum Mainnet ELC, as shown in the build example above:

```bash
$ docker run --rm -t toki-bridge-lcp-enclaves/ethereum/mainnet \
  bash -c "/app/scripts/mrenclave.sh /out /tests/mrenclave && cat /tests/mrenclave/mrenclave.txt"
0x4a58ec920a4c5c759321370b02364c349a61c2429f8a52e9159bbb835bb19322
```

### Extracting the MRENCLAVE from the LCPClient
TODO

### Comparing the ELC and LCPClient MRENCLAVE values
TODO