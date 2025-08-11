# Nockchain Test Ship

This repository contains libraries and generators for testing Nockchain functionality within an Urbit ship. Nockchain is a blockchain implementation built on Urbit's Nock virtual machine.

## Usage Instructions

1. **Boot a new fakeship:**
   ```bash
   ./urbit -F zod  # or any other fake ship name
   ```

2. **Mount the %base desk:**
   ```dojo
   |mount %base
   ```

3. **Copy the nockchain folders to your ship:**
   ```bash
   cp -r gen/nockchain /path/to/your-ship/base/gen/
   cp -r lib/nockchain /path/to/your-ship/base/lib/
   ```

4. **Commit the changes:**
   ```dojo
   |commit %base
   ```

## Library Files

All Nockchain-related libraries are organized in the `lib/nockchain/` directory:

### Core Nockchain Libraries

- **`lib/nockchain/tx-engine.hoon`** - Core blockchain transaction engine implementing UTXO model with Schnorr signatures
- **`lib/nockchain/zose.hoon`** - Secp256k1 elliptic curve cryptography library for Bitcoin-style operations
- **`lib/nockchain/zeke.hoon`** - Keccak/SHA-3 hashing functions and related cryptographic utilities
- **`lib/nockchain/zoon.hoon`** - Additional cryptographic primitives and utility functions
- **`lib/nockchain/pow.hoon`** - Proof of work stub for testing
- **`lib/nockchain/schedule.hoon`** - Emission schedule stub for testing
- **`lib/nockchain/wrapper.hoon`** - Wrapper types and utilities

### ZTD (Zero-knowledge STARK) Libraries

The `lib/nockchain/ztd/` directory contains a comprehensive STARK implementation:
- **`ztd/one.hoon`** - Basic STARK field operations and constants
- **`ztd/two.hoon`** - Field arithmetic and polynomial operations
- **`ztd/three.hoon`** - FFT/NTT implementations for polynomial evaluation
- **`ztd/four.hoon`** - FRI (Fast Reed-Solomon Interactive Oracle Proof) protocol
- **`ztd/five.hoon`** - Constraint system and algebraic intermediate representation
- **`ztd/six.hoon`** - STARK prover implementation
- **`ztd/seven.hoon`** - STARK verifier implementation
- **`ztd/eight.hoon`** - High-level STARK protocol orchestration

## Test Generator

- **`gen/nockchain/test-raw-tx.hoon`** - Tests the `new:raw-tx` function with multiple inputs
  - Creates a transaction with 2 inputs from different UTXOs
  - Uses same key for both inputs (150 + 200 coins)
  - Applies different fees (10 + 15 coins)
  - Outputs clean summary with tx-id and input details

## Testing Workflow

After copying files and committing to %base, you can:

1. Run the test generator:
   ```dojo
   +nockchain/test-raw-tx
   ```

2. Build the tx-engine library in dojo to access types directly:
   ```dojo
   =tx -build-file /=base=/lib/nockchain/tx-engine/hoon
   ```

3. Access tx-engine types:
   ```dojo
   *nname:tx
   *input:tx
   ```

## Contributing

When adding new test generators or library functions:
1. Follow Hoon naming conventions (kebab-case)
2. Include descriptive comments
3. Place Nockchain-related files in the appropriate `nockchain/` subdirectories
4. Update this README with new functionality

## License

See the parent repository for license information.