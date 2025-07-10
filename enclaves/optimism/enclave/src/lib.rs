#![no_std]
extern crate alloc;

use enclave_runtime::{setup_runtime, Environment, MapLightClientRegistry};

#[cfg(feature = "mainnet")]
const SYNC_COMMITTEE_SIZE: usize = optimism_elc::preset::mainnet::PRESET.SYNC_COMMITTEE_SIZE;
#[cfg(feature = "testnet")]
const SYNC_COMMITTEE_SIZE: usize = optimism_elc::preset::mainnet::PRESET.SYNC_COMMITTEE_SIZE;
#[cfg(feature = "localnet")]
const SYNC_COMMITTEE_SIZE: usize = optimism_elc::preset::minimal::PRESET.SYNC_COMMITTEE_SIZE;

setup_runtime!({
    Environment::new(build_lc_registry())
});

fn build_lc_registry() -> MapLightClientRegistry {
    let mut registry = MapLightClientRegistry::new();
    optimism_elc::register_implementations::<SYNC_COMMITTEE_SIZE>(&mut registry);
    registry.seal().unwrap();
    registry
}
