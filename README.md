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

3. **Copy the repository files to your ship:**
   ```bash
   cp -r gen/* /path/to/your-ship/base/gen/
   cp -r lib/* /path/to/your-ship/base/lib/
   ```

4. **Commit the changes:**
   ```dojo
   |commit %base
   ```

## Library Files

### Core Nockchain Libraries

- **`lib/tx-engine.hoon`** - Core blockchain transaction engine implementing UTXO model with Schnorr signatures
- **`lib/zose.hoon`** - Secp256k1 elliptic curve cryptography library for Bitcoin-style operations
- **`lib/zeke.hoon`** - Keccak/SHA-3 hashing functions and related cryptographic utilities
- **`lib/zoon.hoon`** - Additional cryptographic primitives and utility functions

### ZTD (Zero-knowledge STARK) Libraries

The `lib/ztd/` directory contains a comprehensive STARK implementation:
- **`ztd/one.hoon`** - Basic STARK field operations and constants
- **`ztd/two.hoon`** - Field arithmetic and polynomial operations
- **`ztd/three.hoon`** - FFT/NTT implementations for polynomial evaluation
- **`ztd/four.hoon`** - FRI (Fast Reed-Solomon Interactive Oracle Proof) protocol
- **`ztd/five.hoon`** - Constraint system and algebraic intermediate representation
- **`ztd/six.hoon`** - STARK prover implementation
- **`ztd/seven.hoon`** - STARK verifier implementation
- **`ztd/eight.hoon`** - High-level STARK protocol orchestration

## Test Generators

### Transaction Testing

- **`gen/test-raw-tx.hoon`** - Tests the `new:raw-tx` function with multiple inputs
  - Creates a transaction with 2 inputs from different UTXOs
  - Uses same key for both inputs (150 + 200 coins)
  - Applies different fees (10 + 15 coins)
  - Outputs clean summary with tx-id and input details

- **`gen/hello-raw-tx.hoon`** - Simple single-input raw transaction test
  - Creates a basic transaction with 100 coins
  - Applies 10 coin fee
  - Tests basic raw transaction creation flow

- **`gen/test-tx-engine.hoon`** - Comprehensive tx-engine functionality tests
  - Tests various transaction engine components
  - Validates UTXO operations
  - Checks signature verification

### Cryptographic Testing

- **`gen/test-zeke.hoon`** - Tests Keccak/SHA-3 hashing functions
  - Validates hash outputs against known test vectors
  - Tests different hash sizes (224, 256, 384, 512)

- **`gen/test-schnorr.hoon`** - Tests Schnorr signature operations
  - Key generation and derivation
  - Signature creation and verification
  - Public key recovery

## Key Features

- **UTXO Model**: Full unspent transaction output implementation
- **Schnorr Signatures**: Efficient signature scheme for transaction authorization
- **STARK Proofs**: Zero-knowledge proof system for scalable verification
- **Keccak Hashing**: SHA-3 family hash functions for data integrity
- **Secp256k1**: Bitcoin-compatible elliptic curve cryptography

## Testing Workflow

After copying files and committing to %base, you can run tests:

```dojo
> +test-raw-tx
> +hello-raw-tx
> +test-tx-engine
> +test-zeke
> +test-schnorr
```

Each generator will output test results showing successful operations or any errors encountered.

## Architecture Notes

The transaction engine (`tx-engine.hoon`) implements a complete blockchain transaction system with:
- Note (UTXO) creation and spending
- Multi-signature support
- Timelock functionality
- Raw transaction construction
- Transaction validation and hashing

The cryptographic libraries provide the underlying primitives needed for secure blockchain operations, while the ZTD libraries enable efficient zero-knowledge proofs for scalability.

## Contributing

When adding new test generators or library functions:
1. Follow Hoon naming conventions (kebab-case)
2. Include descriptive comments
3. Add corresponding test generators in `gen/`
4. Update this README with new functionality

## License

See the parent repository for license information.