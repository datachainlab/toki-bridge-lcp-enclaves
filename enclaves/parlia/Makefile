include ../../buildenv.mk
include ../../buildcommon.mk

######## Build Parameters ########
# ParliaELC supports BohrHF and PascalHF now

# set the Block Height that the oldest HF supported by ELC to MINIMUM_HEIGHT_SUPPORTED
# set the Block Timestamp that the oldest HF supported by ELC to MINIMUM_TIMESTAMP_SUPPORTED

ifeq ($(DEPLOYMENT_NETWORK), mainnet)
	MINIMUM_HEIGHT_SUPPORTED    = 47618307      # PascalHF height      https://bscscan.com/block/47618307
	MINIMUM_TIMESTAMP_SUPPORTED = 1742436600000 # PascalHF timestamp   2024-03-20 02:10:00 AM UTC
else ifeq ($(DEPLOYMENT_NETWORK), testnet)
	MINIMUM_HEIGHT_SUPPORTED    = 48576786      # PascalHF height      https://testnet.bscscan.com/block/48576786
	MINIMUM_TIMESTAMP_SUPPORTED = 1740452880000 # PascalHF timestamp   2025-02-25 03:08:00 AM UTC
else # localnet
	MINIMUM_HEIGHT_SUPPORTED    = 1
	MINIMUM_TIMESTAMP_SUPPORTED = 1
endif

export MINIMUM_HEIGHT_SUPPORTED
export MINIMUM_TIMESTAMP_SUPPORTED
