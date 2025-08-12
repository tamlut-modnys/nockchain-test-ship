::  Test generator for z-map creation with nname-input pairs
::  Tests the fundamental z-map operations used in inputs:txe
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
::  TEST 1: Single [nname input] pair into z-map
::  ============================================
::
::  Create a unique source and name
=/  test-hash=hash:txe
  (hash-hashable:tip5 leaf+0xdead.beef)
=/  test-source=source:txe
  [test-hash %.n]
=/  test-name=nname:txe
  (simple:new:nname:txe test-lock test-source)
::
::  Create a note
=/  test-note=nnote:txe
  :*  [%0 42 *timelock:txe]          :: version, origin-page 42, no timelock
      test-name                       :: name
      test-lock                       :: lock
      test-source                     :: source
      1.000                           :: assets (1000 coins)
  ==
::
::  Create a spend for the input
=/  note-hash=hash:txe  (hash:nnote:txe test-note)
=/  test-seed=seed:txe
  :*  ~                               :: output-source
      test-lock                       :: recipient
      *timelock-intent:txe            :: timelock-intent
      990                             :: gift (1000 - 10 fee)
      note-hash                       :: parent-hash
  ==
=/  test-seeds=seeds:txe
  (~(put z-in *seeds:txe) test-seed)
=/  test-spend=spend:txe
  (sign:spend:txe [~ test-seeds 10] test-sk)
::
::  Create the input
=/  test-input=input:txe
  [test-note test-spend]
::
::  Create z-map with single entry using put
=/  manual-zmap=(z-map nname:txe input:txe)
  (~(put z-by *(z-map nname:txe input:txe)) [test-name test-input])
::
::  Create z-map using new:inputs:txe (the function we're testing)
=/  function-zmap=inputs:txe
  (new:inputs:txe test-input)
::
::  Extract values for comparison
=/  manual-value=(unit input:txe)
  (~(get z-by manual-zmap) test-name)
=/  function-value=(unit input:txe)
  (~(get z-by function-zmap) test-name)
::
::  Check if both maps have the same size
=/  manual-size=@ud
  ~(wyt z-by manual-zmap)
=/  function-size=@ud
  ~(wyt z-by function-zmap)
::
::  ============================================
::  TEST 2: Two [nname input] pairs into z-map
::  ============================================
::
::  Create first input
=/  hash1=hash:txe
  (hash-hashable:tip5 leaf+0xcafe.babe)
=/  source1=source:txe
  [hash1 %.n]
=/  name1=nname:txe
  (simple:new:nname:txe test-lock source1)
=/  note1=nnote:txe
  :*  [%0 100 *timelock:txe]         :: version, origin-page 100
      name1                           :: name
      test-lock                       :: lock
      source1                         :: source
      500                             :: assets
  ==
::
=/  note1-hash=hash:txe  (hash:nnote:txe note1)
=/  seed1=seed:txe
  :*  ~
      test-lock
      *timelock-intent:txe
      495                             :: 500 - 5 fee
      note1-hash
  ==
=/  seeds1=seeds:txe
  (~(put z-in *seeds:txe) seed1)
=/  spend1=spend:txe
  (sign:spend:txe [~ seeds1 5] test-sk)
=/  input1=input:txe
  [note1 spend1]
::
::  Create second input with different source
=/  hash2=hash:txe
  (hash-hashable:tip5 leaf+0xface.b00c)
=/  source2=source:txe
  [hash2 %.n]
=/  name2=nname:txe
  (simple:new:nname:txe test-lock source2)
=/  note2=nnote:txe
  :*  [%0 200 *timelock:txe]         :: version, origin-page 200
      name2                           :: name
      test-lock                       :: lock
      source2                         :: source
      750                             :: assets
  ==
::
=/  note2-hash=hash:txe  (hash:nnote:txe note2)
=/  seed2=seed:txe
  :*  ~
      test-lock
      *timelock-intent:txe
      742                             :: 750 - 8 fee
      note2-hash
  ==
=/  seeds2=seeds:txe
  (~(put z-in *seeds:txe) seed2)
=/  spend2=spend:txe
  (sign:spend:txe [~ seeds2 8] test-sk)
=/  input2=input:txe
  [note2 spend2]
::
::  Create z-map manually with two entries
=/  manual-zmap2=(z-map nname:txe input:txe)
  %-  ~(gas z-by *(z-map nname:txe input:txe))
  ~[[name1 input1] [name2 input2]]
::
::  Create z-map using multi:new:inputs:txe
=/  function-zmap2=inputs:txe
  %-  multi:new:inputs:txe
  ~[input1 input2]
::
::  Extract values for comparison
=/  manual-val1=(unit input:txe)
  (~(get z-by manual-zmap2) name1)
=/  manual-val2=(unit input:txe)
  (~(get z-by manual-zmap2) name2)
=/  function-val1=(unit input:txe)
  (~(get z-by function-zmap2) name1)
=/  function-val2=(unit input:txe)
  (~(get z-by function-zmap2) name2)
::
::  Check sizes
=/  manual-size2=@ud
  ~(wyt z-by manual-zmap2)
=/  function-size2=@ud
  ~(wyt z-by function-zmap2)
::
::  ============================================
::  TEST 3: Three [nname input] pairs into z-map
::  ============================================
::
::  Create three inputs with unique sources
=/  hash3a=hash:txe
  (hash-hashable:tip5 leaf+0xa111)
=/  source3a=source:txe
  [hash3a %.n]
=/  name3a=nname:txe
  (simple:new:nname:txe test-lock source3a)
=/  note3a=nnote:txe
  :*  [%0 300 *timelock:txe]
      name3a
      test-lock
      source3a
      333
  ==
::
=/  hash3b=hash:txe
  (hash-hashable:tip5 leaf+0xb222)
=/  source3b=source:txe
  [hash3b %.n]
=/  name3b=nname:txe
  (simple:new:nname:txe test-lock source3b)
=/  note3b=nnote:txe
  :*  [%0 301 *timelock:txe]
      name3b
      test-lock
      source3b
      444
  ==
::
=/  hash3c=hash:txe
  (hash-hashable:tip5 leaf+0xc333)
=/  source3c=source:txe
  [hash3c %.n]
=/  name3c=nname:txe
  (simple:new:nname:txe test-lock source3c)
=/  note3c=nnote:txe
  :*  [%0 302 *timelock:txe]
      name3c
      test-lock
      source3c
      555
  ==
::
::  Create spends for each
=/  note3a-hash=hash:txe  (hash:nnote:txe note3a)
=/  seed3a=seed:txe
  [~ test-lock *timelock-intent:txe 330 note3a-hash]
=/  seeds3a=seeds:txe
  (~(put z-in *seeds:txe) seed3a)
=/  spend3a=spend:txe
  (sign:spend:txe [~ seeds3a 3] test-sk)
=/  input3a=input:txe
  [note3a spend3a]
::
=/  note3b-hash=hash:txe  (hash:nnote:txe note3b)
=/  seed3b=seed:txe
  [~ test-lock *timelock-intent:txe 440 note3b-hash]
=/  seeds3b=seeds:txe
  (~(put z-in *seeds:txe) seed3b)
=/  spend3b=spend:txe
  (sign:spend:txe [~ seeds3b 4] test-sk)
=/  input3b=input:txe
  [note3b spend3b]
::
=/  note3c-hash=hash:txe  (hash:nnote:txe note3c)
=/  seed3c=seed:txe
  [~ test-lock *timelock-intent:txe 550 note3c-hash]
=/  seeds3c=seeds:txe
  (~(put z-in *seeds:txe) seed3c)
=/  spend3c=spend:txe
  (sign:spend:txe [~ seeds3c 5] test-sk)
=/  input3c=input:txe
  [note3c spend3c]
::
=/  manual-zmap3=(z-map nname:txe input:txe)
  %-  ~(gas z-by *(z-map nname:txe input:txe))
  ~[[name3a input3a] [name3b input3b] [name3c input3c]]
::
=/  function-zmap3=inputs:txe
  %-  multi:new:inputs:txe
  ~[input3a input3b input3c]
::
=/  manual-size3=@ud  ~(wyt z-by manual-zmap3)
=/  function-size3=@ud  ~(wyt z-by function-zmap3)
::
::  ============================================
::  TEST 4: Four [nname input] pairs into z-map
::  ============================================
::
=/  hash4a=hash:txe
  (hash-hashable:tip5 leaf+0xd444)
=/  source4a=source:txe
  [hash4a %.n]
=/  name4a=nname:txe
  (simple:new:nname:txe test-lock source4a)
=/  note4a=nnote:txe
  :*  [%0 400 *timelock:txe]
      name4a
      test-lock
      source4a
      401
  ==
::
=/  hash4b=hash:txe
  (hash-hashable:tip5 leaf+0xe555)
=/  source4b=source:txe
  [hash4b %.n]
=/  name4b=nname:txe
  (simple:new:nname:txe test-lock source4b)
=/  note4b=nnote:txe
  :*  [%0 401 *timelock:txe]
      name4b
      test-lock
      source4b
      402
  ==
::
=/  hash4c=hash:txe
  (hash-hashable:tip5 leaf+0xf666)
=/  source4c=source:txe
  [hash4c %.n]
=/  name4c=nname:txe
  (simple:new:nname:txe test-lock source4c)
=/  note4c=nnote:txe
  :*  [%0 402 *timelock:txe]
      name4c
      test-lock
      source4c
      403
  ==
::
=/  hash4d=hash:txe
  (hash-hashable:tip5 leaf+0x1777)
=/  source4d=source:txe
  [hash4d %.n]
=/  name4d=nname:txe
  (simple:new:nname:txe test-lock source4d)
=/  note4d=nnote:txe
  :*  [%0 403 *timelock:txe]
      name4d
      test-lock
      source4d
      404
  ==
::
::  Create spends
=/  note4a-hash=hash:txe  (hash:nnote:txe note4a)
=/  seed4a=seed:txe
  [~ test-lock *timelock-intent:txe 399 note4a-hash]
=/  seeds4a=seeds:txe
  (~(put z-in *seeds:txe) seed4a)
=/  spend4a=spend:txe
  (sign:spend:txe [~ seeds4a 2] test-sk)
=/  input4a=input:txe
  [note4a spend4a]
::
=/  note4b-hash=hash:txe  (hash:nnote:txe note4b)
=/  seed4b=seed:txe
  [~ test-lock *timelock-intent:txe 399 note4b-hash]
=/  seeds4b=seeds:txe
  (~(put z-in *seeds:txe) seed4b)
=/  spend4b=spend:txe
  (sign:spend:txe [~ seeds4b 3] test-sk)
=/  input4b=input:txe
  [note4b spend4b]
::
=/  note4c-hash=hash:txe  (hash:nnote:txe note4c)
=/  seed4c=seed:txe
  [~ test-lock *timelock-intent:txe 399 note4c-hash]
=/  seeds4c=seeds:txe
  (~(put z-in *seeds:txe) seed4c)
=/  spend4c=spend:txe
  (sign:spend:txe [~ seeds4c 4] test-sk)
=/  input4c=input:txe
  [note4c spend4c]
::
=/  note4d-hash=hash:txe  (hash:nnote:txe note4d)
=/  seed4d=seed:txe
  [~ test-lock *timelock-intent:txe 399 note4d-hash]
=/  seeds4d=seeds:txe
  (~(put z-in *seeds:txe) seed4d)
=/  spend4d=spend:txe
  (sign:spend:txe [~ seeds4d 5] test-sk)
=/  input4d=input:txe
  [note4d spend4d]
::
=/  manual-zmap4=(z-map nname:txe input:txe)
  %-  ~(gas z-by *(z-map nname:txe input:txe))
  ~[[name4a input4a] [name4b input4b] [name4c input4c] [name4d input4d]]
::
=/  function-zmap4=inputs:txe
  %-  multi:new:inputs:txe
  ~[input4a input4b input4c input4d]
::
=/  manual-size4=@ud  ~(wyt z-by manual-zmap4)
=/  function-size4=@ud  ~(wyt z-by function-zmap4)
::
::  ============================================
::  TEST 5: Five [nname input] pairs into z-map
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
=/  manual-zmap5=(z-map nname:txe input:txe)
  %-  ~(gas z-by *(z-map nname:txe input:txe))
  ~[[name5a input5a] [name5b input5b] [name5c input5c] [name5d input5d] [name5e input5e]]
::
=/  function-zmap5=inputs:txe
  %-  multi:new:inputs:txe
  ~[input5a input5b input5c input5d input5e]
::
=/  manual-size5=@ud  ~(wyt z-by manual-zmap5)
=/  function-size5=@ud  ~(wyt z-by function-zmap5)
::
::  Return test results
:*  %test1-single-pair
    input=test-input
    zmap=function-zmap
    %test2-two-pairs
    inputs=~[input1 input2]
    zmap=function-zmap2
    %test3-three-pairs
    inputs=~[input3a input3b input3c]
    zmap=function-zmap3
    %test4-four-pairs
    inputs=~[input4a input4b input4c input4d]
    zmap=function-zmap4
    %test5-five-pairs
    inputs=~[input5a input5b input5c input5d input5e]
    zmap=function-zmap5
==