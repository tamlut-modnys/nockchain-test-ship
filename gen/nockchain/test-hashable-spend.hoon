::  Test generator that creates a spend and returns its hashable representation
::  For debugging Rust implementation of spend hashing
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
::  Create recipient lock (for the seed/output)
=/  recipient-lock=lock:txe
  :*  1                               :: m (1-of-1 multisig)
      (~(put z-in *(z-set schnorr-pubkey:txe)) test-pk)  :: pubkeys
  ==
::
::  Create parent note hash (hash of the input being spent)
=/  parent-hash=hash:txe
  (hash-hashable:tip5 leaf+0xfeed.face.dead.beef)
::
::  Create timelock intent (spend after block 50, within 20 blocks)
=/  test-timelock-intent=timelock-intent:txe
  :*  [~ 50]                          :: unit absolute
      [~ 20]                          :: unit relative
  ==
::
::  Create seed (output specification)
=/  test-seed=seed:txe
  :*  ~                               :: output-source (~ means new)
      recipient-lock                  :: recipient
      test-timelock-intent            :: timelock-intent
      990                             :: gift amount (1000 - 10 fee)
      parent-hash                     :: parent-hash
  ==
::
::  Create seeds (z-set of seed)
=/  test-seeds=seeds:txe
  (~(put z-in *seeds:txe) test-seed)
::
::  Create additional seeds for a multi-output spend
=/  seed2=seed:txe
  :*  ~
      recipient-lock
      *timelock-intent:txe            :: no timelock intent
      500
      parent-hash
  ==
=/  seed3=seed:txe
  :*  ~
      recipient-lock
      :*  [~ 60]                      :: different timelock absolute
          ~                            :: no relative
      ==
      485
      parent-hash
  ==
=/  multi-seeds=seeds:txe
  %-  ~(gas z-in *seeds:txe)
  ~[test-seed seed2 seed3]
::
::  Create single-output spend (unsigned version for structure viewing)
=/  unsigned-spend=[output-source=(unit source:txe) seeds=seeds:txe fee=@ud]
  [~ test-seeds 10]
::
::  Create signed single-output spend
=/  signed-spend=spend:txe
  (sign:spend:txe unsigned-spend test-sk)
::
::  Create multi-output spend
=/  multi-spend=spend:txe
  (sign:spend:txe [~ multi-seeds 15] test-sk)
::
::  Get the hashable representations
=/  hashable-single-spend=hashable:tip5
  (hashable:spend:txe signed-spend)
::
=/  hashable-multi-spend=hashable:tip5
  (hashable:spend:txe multi-spend)
::
::  Return both single and multi-output spends with their hashable structures
:*  %spend-test
    :*  %single-output
        spend=signed-spend
        hashable=hashable-single-spend
    ==
    :*  %multi-output
        spend=multi-spend
        hashable=hashable-multi-spend
    ==
==