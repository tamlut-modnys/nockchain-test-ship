::  Test generator that creates an nnote and returns its hashable representation
::  For debugging Rust implementation of nnote hashing
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
  (hash-hashable:tip5 leaf+0xdead.beef.cafe.babe)
=/  test-source=source:txe
  [test-hash %.n]  :: hash and not-nullified flag
::
::  Create nname (note name)
=/  test-nname=nname:txe
  (simple:new:nname:txe test-lock test-source)
::
::  Create timelock (absolute blocks 100-110, relative 10-20 blocks)
=/  test-timelock=timelock:txe
  `[absolute=[`100 `110] relative=[`10 `20]]
::
::  Create nnote
=/  test-nnote=nnote:txe
  :*  [%0 42 test-timelock]          :: version 0, origin-page 42, timelock
      test-nname                      :: name
      test-lock                       :: lock
      test-source                     :: source
      1.337                           :: assets (1337 coins)
  ==
::
::  Get the hashable representation of the nnote
=/  hashable-nnote=hashable:tip5
  (hashable:nnote:txe test-nnote)
::
::  Return the nnote and its hashable structure
:*  %nnote-test
    nnote=test-nnote
    hashable=hashable-nnote
==