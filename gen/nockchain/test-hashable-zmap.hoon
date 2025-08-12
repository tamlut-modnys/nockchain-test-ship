::  Test generator that outputs inputs and their hashable z-map representation
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
::  ============================================
::  Create 5 inputs with unique sources
::  ============================================
::
=/  hash5a=hash:txe
  (hash-hashable:tip5 leaf+0x8888)
=/  source5a=source:txe
  [hash5a %.n]
=/  name5a=nname:txe
  (simple:new:nname:txe test-lock source5a)
=/  note5a=nnote:txe
  :*  [%0 500 *timelock:txe]
      name5a
      test-lock
      source5a
      501
  ==
::
=/  hash5b=hash:txe
  (hash-hashable:tip5 leaf+0x9999)
=/  source5b=source:txe
  [hash5b %.n]
=/  name5b=nname:txe
  (simple:new:nname:txe test-lock source5b)
=/  note5b=nnote:txe
  :*  [%0 501 *timelock:txe]
      name5b
      test-lock
      source5b
      502
  ==
::
=/  hash5c=hash:txe
  (hash-hashable:tip5 leaf+0xaaaa)
=/  source5c=source:txe
  [hash5c %.n]
=/  name5c=nname:txe
  (simple:new:nname:txe test-lock source5c)
=/  note5c=nnote:txe
  :*  [%0 502 *timelock:txe]
      name5c
      test-lock
      source5c
      503
  ==
::
=/  hash5d=hash:txe
  (hash-hashable:tip5 leaf+0xbbbb)
=/  source5d=source:txe
  [hash5d %.n]
=/  name5d=nname:txe
  (simple:new:nname:txe test-lock source5d)
=/  note5d=nnote:txe
  :*  [%0 503 *timelock:txe]
      name5d
      test-lock
      source5d
      504
  ==
::
=/  hash5e=hash:txe
  (hash-hashable:tip5 leaf+0xcccc)
=/  source5e=source:txe
  [hash5e %.n]
=/  name5e=nname:txe
  (simple:new:nname:txe test-lock source5e)
=/  note5e=nnote:txe
  :*  [%0 504 *timelock:txe]
      name5e
      test-lock
      source5e
      505
  ==
::
::  Create spends
=/  note5a-hash=hash:txe  (hash:nnote:txe note5a)
=/  seed5a=seed:txe
  [~ test-lock *timelock-intent:txe 500 note5a-hash]
=/  seeds5a=seeds:txe
  (~(put z-in *seeds:txe) seed5a)
=/  spend5a=spend:txe
  (sign:spend:txe [~ seeds5a 1] test-sk)
=/  input5a=input:txe
  [note5a spend5a]
::
=/  note5b-hash=hash:txe  (hash:nnote:txe note5b)
=/  seed5b=seed:txe
  [~ test-lock *timelock-intent:txe 500 note5b-hash]
=/  seeds5b=seeds:txe
  (~(put z-in *seeds:txe) seed5b)
=/  spend5b=spend:txe
  (sign:spend:txe [~ seeds5b 2] test-sk)
=/  input5b=input:txe
  [note5b spend5b]
::
=/  note5c-hash=hash:txe  (hash:nnote:txe note5c)
=/  seed5c=seed:txe
  [~ test-lock *timelock-intent:txe 500 note5c-hash]
=/  seeds5c=seeds:txe
  (~(put z-in *seeds:txe) seed5c)
=/  spend5c=spend:txe
  (sign:spend:txe [~ seeds5c 3] test-sk)
=/  input5c=input:txe
  [note5c spend5c]
::
=/  note5d-hash=hash:txe  (hash:nnote:txe note5d)
=/  seed5d=seed:txe
  [~ test-lock *timelock-intent:txe 500 note5d-hash]
=/  seeds5d=seeds:txe
  (~(put z-in *seeds:txe) seed5d)
=/  spend5d=spend:txe
  (sign:spend:txe [~ seeds5d 4] test-sk)
=/  input5d=input:txe
  [note5d spend5d]
::
=/  note5e-hash=hash:txe  (hash:nnote:txe note5e)
=/  seed5e=seed:txe
  [~ test-lock *timelock-intent:txe 500 note5e-hash]
=/  seeds5e=seeds:txe
  (~(put z-in *seeds:txe) seed5e)
=/  spend5e=spend:txe
  (sign:spend:txe [~ seeds5e 5] test-sk)
=/  input5e=input:txe
  [note5e spend5e]
::
::  Create z-map using multi:new:inputs:txe
=/  inputs-zmap=inputs:txe
  %-  multi:new:inputs:txe
  ~[input5a input5b input5c input5d input5e]
::
::  Get the hashable representation of the z-map
=/  hashable-zmap=hashable:tip5
  (hashable:inputs:txe inputs-zmap)
::
::  Return the inputs and the hashable structure
:*  %hashable-zmap-test
    :*  %inputs
        input1=[name=name5a input=input5a]
        input2=[name=name5b input=input5b]
        input3=[name=name5c input=input5c]
        input4=[name=name5d input=input5d]
        input5=[name=name5e input=input5e]
    ==
    hashable=hashable-zmap
==