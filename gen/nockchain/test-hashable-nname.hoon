::  Test generator that creates an nname and returns its hashable representation
::  For debugging Rust implementation of nname hashing
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
::  Generate test keypair (using same key as other tests)
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
::  Create lock (1-of-1 multisig)
=/  test-lock=lock:txe
  :*  1                               :: m (1-of-1 multisig)
      (~(put z-in *(z-set schnorr-pubkey:txe)) test-pk)  :: pubkeys
  ==
::
::  Create source
=/  test-hash=hash:txe
  (hash-hashable:tip5 leaf+0xfeed.face.cafe.babe)
=/  test-source=source:txe
  [test-hash %.n]  :: hash and not-nullified flag
::
::  Create nname manually to show the structure
::  nname consists of [hash hash ~] where:
::  - First hash: commitment to lock and whether it has a timelock
::  - Second hash: commitment to source and actual timelock
=/  test-nname=nname:txe
  :*  (hash:lock:txe test-lock)       :: First hash: lock commitment
      (hash:source:txe test-source)   :: Second hash: source commitment  
      ~                                :: Pacts (unimplemented)
  ==
::
::  Get the hashable representation of the nname
=/  hashable-nname=hashable:tip5
  (hashable:nname:txe test-nname)
::
::  Compute the final hash from the hashable structure
=/  final-hash=hash:txe
  (hash-hashable:tip5 hashable-nname)
::
::  Return only the input nname and the resulting hash
:*  nname=test-nname
    hash=final-hash
==