::  Test generator that outputs a single input and its hashable z-map representation
::  For debugging Rust implementation of tx-id hashing
::
/+  tx-engine=nockchain-tx-engine, *nockchain-zoon, *nockchain-zeke
::
:-  %say
|=  *
:-  %noun
::
::  Create tx-engine instance
=/  txe  ~(. tx-engine *blockchain-constants:tx-engine)
::
::  Generate test keypair (using same key as test-raw-tx)
=/  test-sk=schnorr-seckey:txe
  %-  from-atom:schnorr-seckey:txe
  0x1234.5678.9abc.def0.1234.5678.9abc.def0.1234.5678.9abc.def0.1234.5678.9abc.def0
::
::  Derive public key
=/  test-pk=schnorr-pubkey:txe
  %-  ch-scal:affine:curve:cheetah
  :*  (to-atom:schnorr-seckey:txe test-sk)
      a-gen:curve:cheetah
  ==
::
::  Create lock
=/  test-lock=lock:txe
  :*  1                               :: m (1-of-1 multisig)
      (~(put z-in *(z-set schnorr-pubkey:txe)) test-pk)  :: pubkeys
  ==
::
::  Create single input
=/  hash1=hash:txe
  (hash-hashable:tip5 leaf+0x1111)
=/  source1=source:txe
  [hash1 %.n]
=/  name1=nname:txe
  (simple:new:nname:txe test-lock source1)
=/  note1=nnote:txe
  :*  [%0 100 *timelock:txe]
      name1
      test-lock
      source1
      1.000
  ==
::
=/  note1-hash=hash:txe  (hash:nnote:txe note1)
=/  seed1=seed:txe
  [~ test-lock *timelock-intent:txe 990 note1-hash]
=/  seeds1=seeds:txe
  (~(put z-in *seeds:txe) seed1)
=/  spend1=spend:txe
  (sign:spend:txe [~ seeds1 10] test-sk)
=/  input1=input:txe
  [note1 spend1]
::
::  Create z-map with single input using new:inputs:txe
=/  single-inputs-zmap=inputs:txe
  (new:inputs:txe input1)
::
::  Get the hashable representation of the single-input z-map
=/  single-hashable-zmap=hashable:tip5
  (hashable:inputs:txe single-inputs-zmap)
::
::  Return the single input and its hashable structure
:*  %single-input-hashable-test
    :*  %input
        name=name1
        input=input1
    ==
    hashable=single-hashable-zmap
==