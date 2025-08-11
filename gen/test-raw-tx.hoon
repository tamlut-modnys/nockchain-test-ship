::  Test generator for new:raw-tx function in tx-engine
::
/+  tx-engine, *zoon, *zeke
::
:-  %say
|=  *
:-  %noun
::
::  Create a simple test for raw-tx
=/  txe  ~(. tx-engine *blockchain-constants:tx-engine)
::
::  Generate a test keypair
::  Using a proper 256-bit test secret key
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
::  Create a lock that requires this public key
=/  test-lock=lock:txe
  :*  1                               :: m (1-of-1 multisig)
      (~(put z-in *(z-set schnorr-pubkey:txe)) test-pk)  :: pubkeys
  ==
::
::  Create a simple input for testing
=/  test-note=nnote:txe
  :*  [%0 1 *timelock:txe]           :: version, origin-page, timelock
      *nname:txe                      :: name  
      test-lock                       :: lock (with our pubkey)
      *source:txe                     :: source
      100                             :: assets (100 coins)
  ==
::
::  Create a seed that sends coins minus fee
=/  note-hash=hash:txe  (hash:nnote:txe test-note)
=/  test-seed=seed:txe
  :*  ~                               :: output-source (unit)
      test-lock                       :: recipient (same lock for simplicity)
      *timelock-intent:txe            :: timelock-intent
      90                              :: gift (100 assets - 10 fee)
      note-hash                       :: parent-hash
  ==
::
=/  test-seeds=seeds:txe
  (~(put z-in *seeds:txe) test-seed)
::
::  Create unsigned spend first
=/  unsigned-spend=spend:txe
  :*  ~                               :: signature (starts empty)
      test-seeds                      :: seeds
      10                              :: fee
  ==
::
::  Sign the spend
=/  signed-spend=spend:txe
  (sign:spend:txe unsigned-spend test-sk)
::
=/  test-input=input:txe
  [test-note signed-spend]
::
::  Test input validation
=/  input-valid=?
  (validate:input:txe test-input)
::
::  Create inputs form
=/  test-inputs=inputs:txe
  (new:inputs:txe test-input)
::
::  Try to create a raw tx
=/  result=(unit raw-tx:txe)
  %-  mole
  |.
  %-  new:raw-tx:txe
  test-inputs
::
::  Return test results with tx-id
:*  %test-result
    loaded=%.y
    keypair-created=?=(^ test-sk)
    lock-created=?=(^ test-lock)
    spend-signed=?=(^ signature.signed-spend)
    input-valid=input-valid
    raw-tx-created=?=(^ result)
    tx-id=?~(result ~ id.u.result)
    total-fees=?~(result ~ total-fees.u.result)
    result-info=?~(result 'Failed to create raw-tx' 'Raw-tx created successfully!')
==