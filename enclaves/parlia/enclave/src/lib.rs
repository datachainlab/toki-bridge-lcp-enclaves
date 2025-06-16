#![no_std]
extern crate alloc;

use enclave_runtime::{setup_runtime, Environment, MapLightClientRegistry};

setup_runtime!({
    Environment::new(build_lc_registry())
});

fn build_lc_registry() -> MapLightClientRegistry {
    let mut registry = MapLightClientRegistry::new();
    parlia_elc::register_implementations(&mut registry);
    registry.seal().unwrap();
    registry
}
