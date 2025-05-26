######## Docker build Settings ########
DOCKER       ?= docker
DOCKER_BUILD ?= docker build

LCP_ELC_TYPES      := $(notdir $(filter-out $(wildcard enclaves/*.*), $(wildcard enclaves/*)))
DEPLOYMENT_NETWORK ?= testnet
IMAGE_TAG          ?= $(shell git rev-parse HEAD)

.PHONY: all
all:
	make $(LCP_ELC_TYPES)

$(LCP_ELC_TYPES):
	make enclave LCP_ELC_TYPE=$@

.PHONY: enclave
enclave:
	$(DOCKER_BUILD) \
		-t toki-bridge-lcp-enclaves:$(LCP_ELC_TYPE)-$(DEPLOYMENT_NETWORK)-$(IMAGE_TAG) \
		--build-arg DEPLOYMENT_NETWORK=$(DEPLOYMENT_NETWORK) \
		--build-arg LCP_ELC_TYPE=$(LCP_ELC_TYPE) $(EXTRA_VARS) \
		.