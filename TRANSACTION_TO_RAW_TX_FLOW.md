# Complete Flow: Transaction to Raw-TX Processing

## Overview
This document traces the complete flow of processing a `++transaction` data structure into a `++raw-tx` structure in the Nockchain system.

## File Dependencies

### Primary Files
1. **`/hoon/apps/wallet/wallet.hoon`** - Entry point for transaction processing
2. **`/hoon/common/tx-engine.hoon`** - Core transaction engine with all type definitions
3. **`/hoon/common/ztd/three.hoon`** - TIP5 hashing implementation
4. **`/hoon/common/zoon.hoon`** - Z-map and Z-set data structures
5. **`/hoon/common/zeke.hoon`** - Additional utility functions
6. **`/hoon/common/wrapper.hoon`** - Wrapper utilities
7. **`/hoon/common/zose.hoon`** - Core utilities

### Import Chain
```
wallet.hoon imports:
  ├── /common/tx-engine     (transact)
  ├── /common/zeke          (z)
  ├── /common/zoon          (zo)
  ├── /common/wrapper       (*)
  └── /common/zose          (*)

tx-engine.hoon imports:
  ├── /common/schedule      (emission)
  ├── /common/pow           (mine)
  ├── /common/zeke          (*)
  └── /common/zoon          (*)
```

## Data Structure Flow

### 1. Input: `++transaction` (wallet.hoon:343)
```hoon
+$  transaction  [name=@t p=inputs:transact]
```
- `name`: Transaction identifier (e.g., "my-transaction")
- `p`: Collection of inputs (`inputs:transact`)

### 2. Processing Entry Point (wallet.hoon:1740-1754)
```hoon
++  do-send-tx
  |=  =cause
  ?>  ?=(%send-tx -.cause)
  =/  raw=raw-tx:transact  (new:raw-tx:transact p.dat.cause)
  =/  tx-id  id.raw
```

### 3. Core Processing: `new:raw-tx` (tx-engine.hoon:913-929)
```hoon
++  new
  ++  default
    |=  ips=inputs
    ^-  form
    =/  raw-tx=form
      %*  .  *form
        inputs          ips
        total-fees      (roll-fees:inputs ips)
        timelock-range  (roll-timelocks:inputs ips)
      ==
    =.  raw-tx  raw-tx(id (compute-id raw-tx))
    ?>  (validate raw-tx)
    raw-tx
```

## Detailed Processing Steps

### Step 1: Extract Inputs from Transaction
- Location: wallet.hoon:1745
- Extract `p.dat.cause` which contains the `inputs:transact` structure

### Step 2: Calculate Total Fees
- Location: tx-engine.hoon:733-738
- Function: `roll-fees:inputs`
```hoon
++  roll-fees
  |=  ips=form
  ^-  coins
  %+  roll  ~(val z-by ips)
  |=  [inp=input fees=coins]
  (add fee.spend.inp fees)
```

### Step 3: Calculate Timelock Range
- Location: tx-engine.hoon:740-747
- Function: `roll-timelocks:inputs`
```hoon
++  roll-timelocks
  |=  ips=form
  ^-  timelock-range
  %+  roll  ~(val z-by ips)
  |=  [ip=input range=timelock-range]
  %+  merge:timelock-range
    range
  (fix-absolute:timelock timelock.note.ip origin-page.note.ip)
```

### Step 4: Compute Transaction ID
- Location: tx-engine.hoon:959-965
- Function: `compute-id`
```hoon
++  compute-id
  |=  raw=form
  ^-  tx-id
  %-  hash-hashable:tip5
  :+  (hashable:inputs inputs.raw)
    (hashable:timelock-range timelock-range.raw)
  leaf+total-fees.raw
```

### Step 5: Hash Processing Chain
The TX-ID is computed through a series of hashing operations:

#### 5.1 Convert Inputs to Hashable
- Location: tx-engine.hoon:773-779
- Creates a tree structure of hashable elements from the z-map of inputs

#### 5.2 Hash with TIP5
- Location: ztd/three.hoon:327+
- Uses TIP5 hash algorithm (placeholder implementation currently)
- Combines:
  - Hashed inputs structure
  - Hashed timelock range
  - Total fees as a leaf

### Step 6: Validation
- Location: tx-engine.hoon:928
- Validates the raw-tx structure before returning
- Ensures all inputs are properly signed and valid

## Output: `++raw-tx` Structure (tx-engine.hoon:903-912)
```hoon
+$  form
  $:  id=tx-id              :: Computed hash of transaction
      =inputs               :: Original signed inputs
      =timelock-range       :: Valid block range
      total-fees=coins      :: Sum of all fees
  ==
```

## Key Type Definitions

### `inputs` (tx-engine.hoon:709)
```hoon
+$  form  (z-map nname input)
```
A z-map mapping note names to input structures.

### `input` (tx-engine.hoon:484)
Contains:
- `note`: The note being spent
- `spend`: Spending authorization with signature
- Seeds for outputs

### `tx-id` (tx-engine.hoon:147)
```hoon
+$  tx-id  hash
```
A hash digest (5-element array) uniquely identifying the transaction.

### `timelock-range` (tx-engine.hoon:195)
```hoon
+$  timelock-range  [min=page-number max=page-number]
```
Valid block range for transaction inclusion.

## Hash Computation Details

The transaction ID is deterministically computed from:
1. **Inputs Tree**: Converted to hashable format preserving z-map structure
2. **Timelock Range**: Min and max block numbers
3. **Total Fees**: Sum of all input fees

The hash function uses a triple structure:
```
hash-hashable:tip5([inputs, timelock, fees])
```

## Execution Flow Summary

1. **User initiates**: `[%send-tx dat=transaction]` cause in wallet
2. **Wallet processes**: Calls `do-send-tx` (wallet.hoon:1740)
3. **Extract inputs**: Get `p.dat.cause` (the inputs collection)
4. **Create raw-tx**: Call `new:raw-tx:transact` (tx-engine.hoon:913)
   - Calculate total fees
   - Determine timelock range
   - Compute transaction ID via hashing
   - Validate structure
5. **Return raw-tx**: Structure with ID, inputs, timelock, and fees
6. **Broadcast**: Send to network via NPC poke

## Important Notes

- The `new:raw-tx` function automatically calls validation
- Transaction IDs are deterministic - same inputs always produce same ID
- The current implementation uses placeholder TIP5 hashing
- All monetary values are in smallest units (coins)
- Timelocks ensure transactions are only valid within specified block ranges