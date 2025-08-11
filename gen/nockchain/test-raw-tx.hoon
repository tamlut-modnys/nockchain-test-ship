::  Test generator for new:raw-tx function in tx-engine
::  Tests both single-input and multi-input transactions
::
/+  tx-engine=nockchain-tx-engine, *nockchain-zoon, *nockchain-zeke
::
:-  %say
|=  *
:-  %noun
::
::  Create a simple test for raw-tx
=/  txe  ~(. tx-engine *blockchain-constants:tx-engine)
::
::  Generate test keypair (same key used for all tests)
=/  test-sk=schnorr-seckey:txe
  %-  from-atom:schnorr-seckey:txe
  0x1234.5678.9abc.def0.1234.5678.9abc.def0.1234.5678.9abc.def0.1234.5678.9abc.def0
::
::  Derive public key from secret key
=/  test-pk=schnorr-pubkey:txe
  %-  ch-scal:affine:curve:cheetah
  :*  (to-atom:schnorr-seckey:txe test-sk)
      a-gen:curve:cheetah
  ==
::
::  Create lock that requires this public key
=/  test-lock=lock:txe
  :*  1                               :: m (1-of-1 multisig)
      (~(put z-in *(z-set schnorr-pubkey:txe)) test-pk)  :: pubkeys
  ==
::
::  ============================================
::  TEST 1: Single input transaction
::  ============================================
::
::  Create single input note with 100 coins
=/  single-note=nnote:txe
  :*  [%0 1 *timelock:txe]           :: version, origin-page, timelock
      *nname:txe                      :: name  
      test-lock                       :: lock (with our pubkey)
      *source:txe                     :: source
      100                             :: assets (100 coins)
  ==
::
::  Create seed for output (100 coins - 10 fee = 90 to recipient)
=/  single-note-hash=hash:txe  (hash:nnote:txe single-note)
=/  single-seed=seed:txe
  :*  ~                               :: output-source (unit)
      test-lock                       :: recipient (same lock for simplicity)
      *timelock-intent:txe            :: timelock-intent
      90                              :: gift (100 assets - 10 fee)
      single-note-hash                :: parent-hash
  ==
::
=/  single-seeds=seeds:txe
  (~(put z-in *seeds:txe) single-seed)
::
::  Create unsigned spend
=/  single-unsigned-spend=spend:txe
  :*  ~                               :: signature (starts empty)
      single-seeds                    :: seeds
      10                              :: fee
  ==
::
::  Sign the spend
=/  single-signed-spend=spend:txe
  (sign:spend:txe single-unsigned-spend test-sk)
::
::  Create input structure
=/  single-input=input:txe
  [single-note single-signed-spend]
::
::  Create inputs form with single input
=/  single-inputs=inputs:txe
  (new:inputs:txe single-input)
::
::  Create the single-input raw tx
=/  single-result=raw-tx:txe
  %-  new:raw-tx:txe
  single-inputs
::
::  ============================================
::  TEST 2: Multi-input transaction
::  ============================================
::
::  Create first input note with 150 coins
=/  test-note1=nnote:txe
  :*  [%0 1 *timelock:txe]           :: version, origin-page, timelock
      *nname:txe                      :: name  
      test-lock                       :: lock (with our pubkey)
      *source:txe                     :: source
      150                             :: assets (150 coins)
  ==
::
::  Create second input note with 200 coins
=/  test-note2=nnote:txe
  :*  [%0 2 *timelock:txe]           :: version, origin-page 2, timelock
      *nname:txe                      :: name  
      test-lock                       :: lock (same lock as first)
      *source:txe                     :: source
      200                             :: assets (200 coins)
  ==
::
::  Create seeds for first input (150 coins - 10 fee = 140 to recipient)
=/  note1-hash=hash:txe  (hash:nnote:txe test-note1)
=/  test-seed1=seed:txe
  :*  ~                               :: output-source (unit)
      test-lock                       :: recipient (same lock for simplicity)
      *timelock-intent:txe            :: timelock-intent
      140                             :: gift (150 assets - 10 fee)
      note1-hash                      :: parent-hash
  ==
::
=/  test-seeds1=seeds:txe
  (~(put z-in *seeds:txe) test-seed1)
::
::  Create seeds for second input (200 coins - 15 fee = 185 to recipient)
=/  note2-hash=hash:txe  (hash:nnote:txe test-note2)
=/  test-seed2=seed:txe
  :*  ~                               :: output-source (unit)
      test-lock                       :: recipient
      *timelock-intent:txe            :: timelock-intent
      185                             :: gift (200 assets - 15 fee)
      note2-hash                      :: parent-hash
  ==
::
=/  test-seeds2=seeds:txe
  (~(put z-in *seeds:txe) test-seed2)
::
::  Create unsigned spends for both inputs
=/  unsigned-spend1=spend:txe
  :*  ~                               :: signature (starts empty)
      test-seeds1                     :: seeds
      10                              :: fee for input 1
  ==
::
=/  unsigned-spend2=spend:txe
  :*  ~                               :: signature (starts empty)
      test-seeds2                     :: seeds
      15                              :: fee for input 2
  ==
::
::  Sign the spends with the same secret key
=/  signed-spend1=spend:txe
  (sign:spend:txe unsigned-spend1 test-sk)
::
=/  signed-spend2=spend:txe
  (sign:spend:txe unsigned-spend2 test-sk)
::
::  Create input structures
=/  test-input1=input:txe
  [test-note1 signed-spend1]
::
=/  test-input2=input:txe
  [test-note2 signed-spend2]
::
::  Create inputs form with multiple inputs
=/  test-inputs=inputs:txe
  %-  multi:new:inputs:txe
  ~[test-input1 test-input2]
::
::  Create the multi-input raw tx
=/  multi-result=raw-tx:txe
  %-  new:raw-tx:txe
  test-inputs
::
::  ============================================
::  Return both test results
::  ============================================
:*  %test-results
    :*  %single-input-test
        total-coins-in=100
        fee=10
        total-coins-out=90
        tx-id=id.single-result
    ==
    :*  %multi-input-test
        total-inputs=2
        total-coins-in=350            :: 150 + 200
        total-fees=25                 :: 10 + 15
        total-coins-out=325           :: 140 + 185
        tx-id=id.multi-result
    ==
==