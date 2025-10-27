DOCKER ?= docker

ENCLAVES_DIRS := $(shell find enclaves -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
NETWORKS      := testnet mainnet
ENCLAVES      := $(foreach e,$(ENCLAVES_DIRS),$(foreach n,$(NETWORKS),$(e)/$(n)))

# docker image
REPOSITORY ?= ghcr.io/datachainlab/toki-bridge-enclaves
TAG ?= $(shell git rev-parse HEAD)

# docker build parameter
UID ?= $(shell id -u)
GID ?= $(shell id -g)

.PHONY: all
all:
	make $(ENCLAVES)

.PHONY: $(ENCLAVES)
$(ENCLAVES):
	enclave=$(word 1,$(subst /, ,$@)); \
	deployment_network=$(word 2,$(subst /, ,$@)); \
	make mrenclave LCP_ELC_TYPE=$$enclave DEPLOYMENT_NETWORK=$$deployment_network

.PHONY: build
build:
	$(DOCKER) build -t $(REPOSITORY)/$(LCP_ELC_TYPE)/$(DEPLOYMENT_NETWORK):$(TAG) \
	--build-arg LCP_ELC_TYPE=$(LCP_ELC_TYPE) \
	--build-arg DEPLOYMENT_NETWORK=$(DEPLOYMENT_NETWORK) \
	--build-arg UID=$(UID) --build-arg GID=$(GID) \
	.

.PHONY: mrenclave
mrenclave: build
	mkdir -p $(PWD)/tests/$(LCP_ELC_TYPE)/mrenclaves/$(DEPLOYMENT_NETWORK)
	$(DOCKER) run --rm $(REPOSITORY)/$(LCP_ELC_TYPE)/$(DEPLOYMENT_NETWORK):$(TAG) \
    bash -c "/app/scripts/mrenclave.sh /out /app/tests/mrenclave > mrenclave.log 2>&1 && cat /app/tests/mrenclave/MRENCLAVE || { cat mrenclave.log; exit 1; }" > $(PWD)/tests/$(LCP_ELC_TYPE)/mrenclaves/$(DEPLOYMENT_NETWORK)/MRENCLAVE && \
	yq ".$(LCP_ELC_TYPE).$(DEPLOYMENT_NETWORK) = \"$$(cat $(PWD)/tests/$(LCP_ELC_TYPE)/mrenclaves/$(DEPLOYMENT_NETWORK)/MRENCLAVE)\" | .$(LCP_ELC_TYPE).$(DEPLOYMENT_NETWORK) style=\"double\"" -i mrenclaves.yaml || exit 1

.PHONY: clean
clean:
	docker images --filter "reference=$(REPOSITORY)/*/*:$(TAG)" -q | xargs -r docker rmi