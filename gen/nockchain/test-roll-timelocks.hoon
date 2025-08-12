::  Test generator for roll-timelocks:inputs function in tx-engine
::  Multiple test cases with various timelock combinations
::
/+  tx-engine=nockchain-tx-engine, *nockchain-zoon, *nockchain-zeke
::
:-  %say
|=  *
:-  %noun
::
::  Create a simple test for roll-timelocks
=/  txe  ~(. tx-engine *blockchain-constants:tx-engine)
::
::  Generate test keypair
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
::  INPUT 1: No timelock (can spend anytime)
::  ============================================
::
=/  hash1=hash:txe
  (hash-hashable:tip5 leaf+0x1111)
=/  source1=source:txe
  [hash1 %.n]
=/  name1=nname:txe
  (simple:new:nname:txe test-lock source1)
=/  note1=nnote:txe
  :*  [%0 10 *timelock:txe]          :: version, origin-page 10, no timelock
      name1                           :: name  
      test-lock                       :: lock
      source1                         :: source
      100                             :: assets
  ==
::
::  Create spend for input 1
=/  note1-hash=hash:txe  (hash:nnote:txe note1)
=/  seed1=seed:txe
  :*  ~                               :: output-source
      test-lock                       :: recipient
      *timelock-intent:txe            :: timelock-intent
      95                              :: gift (100 - 5 fee)
      note1-hash                      :: parent-hash
  ==
=/  seeds1=seeds:txe
  (~(put z-in *seeds:txe) seed1)
=/  spend1=spend:txe
  (sign:spend:txe [~ seeds1 5] test-sk)
=/  input1=input:txe
  [note1 spend1]
::
::  ============================================
::  INPUT 2: Absolute timelock (can only spend after page 50)
::  ============================================
::
=/  hash2=hash:txe
  (hash-hashable:tip5 leaf+0x2222)
=/  source2=source:txe
  [hash2 %.n]
=/  name2=nname:txe
  (simple:new:nname:txe test-lock source2)
::  Create absolute timelock: min page 50, no max
=/  absolute-timelock=timelock:txe
  `[absolute=[`50 ~] relative=[~ ~]]
=/  note2=nnote:txe
  :*  [%0 20 absolute-timelock]      :: version, origin-page 20, absolute timelock
      name2                           :: name  
      test-lock                       :: lock
      source2                         :: source
      150                             :: assets
  ==
::
::  Create spend for input 2
=/  note2-hash=hash:txe  (hash:nnote:txe note2)
=/  seed2=seed:txe
  :*  ~                               :: output-source
      test-lock                       :: recipient
      *timelock-intent:txe            :: timelock-intent
      140                             :: gift (150 - 10 fee)
      note2-hash                      :: parent-hash
  ==
=/  seeds2=seeds:txe
  (~(put z-in *seeds:txe) seed2)
=/  spend2=spend:txe
  (sign:spend:txe [~ seeds2 10] test-sk)
=/  input2=input:txe
  [note2 spend2]
::
::  ============================================
::  INPUT 3: Relative timelock (can spend 30 pages after origin)
::  ============================================
::
=/  hash3=hash:txe
  (hash-hashable:tip5 leaf+0x3333)
=/  source3=source:txe
  [hash3 %.n]
=/  name3=nname:txe
  (simple:new:nname:txe test-lock source3)
::  Create relative timelock: must wait 30 pages from origin
=/  relative-timelock=timelock:txe
  `[absolute=[~ ~] relative=[`30 ~]]
=/  note3=nnote:txe
  :*  [%0 15 relative-timelock]      :: version, origin-page 15, relative timelock
      name3                           :: name  
      test-lock                       :: lock
      source3                         :: source
      200                             :: assets
  ==
::
::  Create spend for input 3
=/  note3-hash=hash:txe  (hash:nnote:txe note3)
=/  seed3=seed:txe
  :*  ~                               :: output-source
      test-lock                       :: recipient
      *timelock-intent:txe            :: timelock-intent
      185                             :: gift (200 - 15 fee)
      note3-hash                      :: parent-hash
  ==
=/  seeds3=seeds:txe
  (~(put z-in *seeds:txe) seed3)
=/  spend3=spend:txe
  (sign:spend:txe [~ seeds3 15] test-sk)
=/  input3=input:txe
  [note3 spend3]
::
::  ============================================
::  INPUT 4: Absolute min and max (can spend pages 40-60)
::  ============================================
::
=/  hash4=hash:txe
  (hash-hashable:tip5 leaf+0x4444)
=/  source4=source:txe
  [hash4 %.n]
=/  name4=nname:txe
  (simple:new:nname:txe test-lock source4)
::  Create absolute timelock with both min and max
=/  absolute-min-max-timelock=timelock:txe
  `[absolute=[`45 `65] relative=[~ ~]]
=/  note4=nnote:txe
  :*  [%0 25 absolute-min-max-timelock]  :: version, origin-page 25
      name4                               :: name  
      test-lock                           :: lock
      source4                             :: source
      120                                 :: assets
  ==
::
=/  note4-hash=hash:txe  (hash:nnote:txe note4)
=/  seed4=seed:txe
  :*  ~                               :: output-source
      test-lock                       :: recipient
      *timelock-intent:txe            :: timelock-intent
      112                             :: gift (120 - 8 fee)
      note4-hash                      :: parent-hash
  ==
=/  seeds4=seeds:txe
  (~(put z-in *seeds:txe) seed4)
=/  spend4=spend:txe
  (sign:spend:txe [~ seeds4 8] test-sk)
=/  input4=input:txe
  [note4 spend4]
::
::  ============================================
::  INPUT 5: Relative min and max (can spend 20-40 pages after origin)
::  ============================================
::
=/  hash5=hash:txe
  (hash-hashable:tip5 leaf+0x5555)
=/  source5=source:txe
  [hash5 %.n]
=/  name5=nname:txe
  (simple:new:nname:txe test-lock source5)
::  Create relative timelock with both min and max
=/  relative-min-max-timelock=timelock:txe
  `[absolute=[~ ~] relative=[`15 `30]]
=/  note5=nnote:txe
  :*  [%0 35 relative-min-max-timelock]  :: version, origin-page 35
      name5                               :: name  
      test-lock                           :: lock
      source5                             :: source
      80                                  :: assets
  ==
::
=/  note5-hash=hash:txe  (hash:nnote:txe note5)
=/  seed5=seed:txe
  :*  ~                               :: output-source
      test-lock                       :: recipient
      *timelock-intent:txe            :: timelock-intent
      73                              :: gift (80 - 7 fee)
      note5-hash                      :: parent-hash
  ==
=/  seeds5=seeds:txe
  (~(put z-in *seeds:txe) seed5)
=/  spend5=spend:txe
  (sign:spend:txe [~ seeds5 7] test-sk)
=/  input5=input:txe
  [note5 spend5]
::
::  ============================================
::  INPUT 6: Absolute min, relative max (min page 35, max 25 pages after origin)
::  ============================================
::
=/  hash6=hash:txe
  (hash-hashable:tip5 leaf+0x6666)
=/  source6=source:txe
  [hash6 %.n]
=/  name6=nname:txe
  (simple:new:nname:txe test-lock source6)
::  Create mixed timelock: absolute min, relative max
=/  mixed-abs-rel-timelock=timelock:txe
  `[absolute=[`48 ~] relative=[~ `40]]
=/  note6=nnote:txe
  :*  [%0 20 mixed-abs-rel-timelock]     :: version, origin-page 20
      name6                               :: name  
      test-lock                           :: lock
      source6                             :: source
      90                                  :: assets
  ==
::
=/  note6-hash=hash:txe  (hash:nnote:txe note6)
=/  seed6=seed:txe
  :*  ~                               :: output-source
      test-lock                       :: recipient
      *timelock-intent:txe            :: timelock-intent
      84                              :: gift (90 - 6 fee)
      note6-hash                      :: parent-hash
  ==
=/  seeds6=seeds:txe
  (~(put z-in *seeds:txe) seed6)
=/  spend6=spend:txe
  (sign:spend:txe [~ seeds6 6] test-sk)
=/  input6=input:txe
  [note6 spend6]
::
::  ============================================
::  INPUT 7: Relative min, absolute max (min 15 pages after origin, max page 55)
::  ============================================
::
=/  hash7=hash:txe
  (hash-hashable:tip5 leaf+0x7777)
=/  source7=source:txe
  [hash7 %.n]
=/  name7=nname:txe
  (simple:new:nname:txe test-lock source7)
::  Create mixed timelock: relative min, absolute max
=/  mixed-rel-abs-timelock=timelock:txe
  `[absolute=[~ `58] relative=[`20 ~]]
=/  note7=nnote:txe
  :*  [%0 28 mixed-rel-abs-timelock]     :: version, origin-page 28
      name7                               :: name  
      test-lock                           :: lock
      source7                             :: source
      110                                 :: assets
  ==
::
=/  note7-hash=hash:txe  (hash:nnote:txe note7)
=/  seed7=seed:txe
  :*  ~                               :: output-source
      test-lock                       :: recipient
      *timelock-intent:txe            :: timelock-intent
      101                             :: gift (110 - 9 fee)
      note7-hash                      :: parent-hash
  ==
=/  seeds7=seeds:txe
  (~(put z-in *seeds:txe) seed7)
=/  spend7=spend:txe
  (sign:spend:txe [~ seeds7 9] test-sk)
=/  input7=input:txe
  [note7 spend7]
::
::  ============================================
::  Create inputs map and compute timelock range
::  ============================================
::
=/  test-inputs=inputs:txe
  %-  multi:new:inputs:txe
  ~[input1 input2 input3 input4 input5 input6 input7]
::
::  Roll the timelocks to get the combined range
=/  rolled-timelock-range=timelock-range:txe
  (roll-timelocks:inputs:txe test-inputs)
::
::  ============================================
::  TEST CASE 1: Seven inputs with complex timelocks
::  ============================================
::
=/  test1-result=timelock-range:txe
  rolled-timelock-range
::
::  ============================================
::  TEST CASE 2: Single input with no timelock
::  ============================================
::
=/  single-hash=hash:txe
  (hash-hashable:tip5 leaf+0x8888)
=/  single-source=source:txe
  [single-hash %.n]
=/  single-name=nname:txe
  (simple:new:nname:txe test-lock single-source)
=/  single-note=nnote:txe
  :*  [%0 100 *timelock:txe]         :: version, origin-page 100, no timelock
      single-name                     :: name  
      test-lock                       :: lock
      single-source                   :: source
      500                             :: assets
  ==
::
=/  single-note-hash=hash:txe  (hash:nnote:txe single-note)
=/  single-seed=seed:txe
  :*  ~                               :: output-source
      test-lock                       :: recipient
      *timelock-intent:txe            :: timelock-intent
      490                             :: gift (500 - 10 fee)
      single-note-hash                :: parent-hash
  ==
=/  single-seeds=seeds:txe
  (~(put z-in *seeds:txe) single-seed)
=/  single-spend=spend:txe
  (sign:spend:txe [~ single-seeds 10] test-sk)
=/  single-input=input:txe
  [single-note single-spend]
::
=/  single-inputs=inputs:txe
  (new:inputs:txe single-input)
=/  test2-result=timelock-range:txe
  (roll-timelocks:inputs:txe single-inputs)
::
::  ============================================
::  TEST CASE 3: Two inputs with absolute mins and maxes
::  ============================================
::
=/  abs1-hash=hash:txe
  (hash-hashable:tip5 leaf+0x9999)
=/  abs1-source=source:txe
  [abs1-hash %.n]
=/  abs1-name=nname:txe
  (simple:new:nname:txe test-lock abs1-source)
=/  abs1-timelock=timelock:txe
  `[absolute=[`30 `70] relative=[~ ~]]
=/  abs1-note=nnote:txe
  :*  [%0 50 abs1-timelock]          :: origin-page 50
      abs1-name
      test-lock
      abs1-source
      300
  ==
::
=/  abs2-hash=hash:txe
  (hash-hashable:tip5 leaf+0xaaaa)
=/  abs2-source=source:txe
  [abs2-hash %.n]
=/  abs2-name=nname:txe
  (simple:new:nname:txe test-lock abs2-source)
=/  abs2-timelock=timelock:txe
  `[absolute=[`40 `80] relative=[~ ~]]
=/  abs2-note=nnote:txe
  :*  [%0 55 abs2-timelock]          :: origin-page 55
      abs2-name
      test-lock
      abs2-source
      250
  ==
::
=/  abs1-note-hash=hash:txe  (hash:nnote:txe abs1-note)
=/  abs1-seed=seed:txe
  :*  ~
      test-lock
      *timelock-intent:txe
      295
      abs1-note-hash
  ==
=/  abs1-seeds=seeds:txe
  (~(put z-in *seeds:txe) abs1-seed)
=/  abs1-spend=spend:txe
  (sign:spend:txe [~ abs1-seeds 5] test-sk)
=/  abs1-input=input:txe
  [abs1-note abs1-spend]
::
=/  abs2-note-hash=hash:txe  (hash:nnote:txe abs2-note)
=/  abs2-seed=seed:txe
  :*  ~
      test-lock
      *timelock-intent:txe
      244
      abs2-note-hash
  ==
=/  abs2-seeds=seeds:txe
  (~(put z-in *seeds:txe) abs2-seed)
=/  abs2-spend=spend:txe
  (sign:spend:txe [~ abs2-seeds 6] test-sk)
=/  abs2-input=input:txe
  [abs2-note abs2-spend]
::
=/  abs-inputs=inputs:txe
  %-  multi:new:inputs:txe
  ~[abs1-input abs2-input]
=/  test3-result=timelock-range:txe
  (roll-timelocks:inputs:txe abs-inputs)
::
::  ============================================
::  TEST CASE 4: Two inputs with relative mins and maxes
::  ============================================
::
=/  rel1-hash=hash:txe
  (hash-hashable:tip5 leaf+0xbbbb)
=/  rel1-source=source:txe
  [rel1-hash %.n]
=/  rel1-name=nname:txe
  (simple:new:nname:txe test-lock rel1-source)
=/  rel1-timelock=timelock:txe
  `[absolute=[~ ~] relative=[`10 `50]]
=/  rel1-note=nnote:txe
  :*  [%0 20 rel1-timelock]          :: origin-page 20
      rel1-name
      test-lock
      rel1-source
      400
  ==
::
=/  rel2-hash=hash:txe
  (hash-hashable:tip5 leaf+0xcccc)
=/  rel2-source=source:txe
  [rel2-hash %.n]
=/  rel2-name=nname:txe
  (simple:new:nname:txe test-lock rel2-source)
=/  rel2-timelock=timelock:txe
  `[absolute=[~ ~] relative=[`15 `45]]
=/  rel2-note=nnote:txe
  :*  [%0 25 rel2-timelock]          :: origin-page 25
      rel2-name
      test-lock
      rel2-source
      350
  ==
::
=/  rel1-note-hash=hash:txe  (hash:nnote:txe rel1-note)
=/  rel1-seed=seed:txe
  :*  ~
      test-lock
      *timelock-intent:txe
      392
      rel1-note-hash
  ==
=/  rel1-seeds=seeds:txe
  (~(put z-in *seeds:txe) rel1-seed)
=/  rel1-spend=spend:txe
  (sign:spend:txe [~ rel1-seeds 8] test-sk)
=/  rel1-input=input:txe
  [rel1-note rel1-spend]
::
=/  rel2-note-hash=hash:txe  (hash:nnote:txe rel2-note)
=/  rel2-seed=seed:txe
  :*  ~
      test-lock
      *timelock-intent:txe
      343
      rel2-note-hash
  ==
=/  rel2-seeds=seeds:txe
  (~(put z-in *seeds:txe) rel2-seed)
=/  rel2-spend=spend:txe
  (sign:spend:txe [~ rel2-seeds 7] test-sk)
=/  rel2-input=input:txe
  [rel2-note rel2-spend]
::
=/  rel-inputs=inputs:txe
  %-  multi:new:inputs:txe
  ~[rel1-input rel2-input]
=/  test4-result=timelock-range:txe
  (roll-timelocks:inputs:txe rel-inputs)
::
::  ============================================
::  TEST CASE 5: Two inputs - absolute min/relative max + relative min/absolute max
::  ============================================
::
=/  mix1-hash=hash:txe
  (hash-hashable:tip5 leaf+0xdddd)
=/  mix1-source=source:txe
  [mix1-hash %.n]
=/  mix1-name=nname:txe
  (simple:new:nname:txe test-lock mix1-source)
=/  mix1-timelock=timelock:txe
  `[absolute=[`35 ~] relative=[~ `30]]  :: absolute min, relative max
=/  mix1-note=nnote:txe
  :*  [%0 15 mix1-timelock]          :: origin-page 15
      mix1-name
      test-lock
      mix1-source
      200
  ==
::
=/  mix2-hash=hash:txe
  (hash-hashable:tip5 leaf+0xeeee)
=/  mix2-source=source:txe
  [mix2-hash %.n]
=/  mix2-name=nname:txe
  (simple:new:nname:txe test-lock mix2-source)
=/  mix2-timelock=timelock:txe
  `[absolute=[~ `60] relative=[`25 ~]]  :: relative min, absolute max
=/  mix2-note=nnote:txe
  :*  [%0 18 mix2-timelock]          :: origin-page 18
      mix2-name
      test-lock
      mix2-source
      180
  ==
::
=/  mix1-note-hash=hash:txe  (hash:nnote:txe mix1-note)
=/  mix1-seed=seed:txe
  :*  ~
      test-lock
      *timelock-intent:txe
      196
      mix1-note-hash
  ==
=/  mix1-seeds=seeds:txe
  (~(put z-in *seeds:txe) mix1-seed)
=/  mix1-spend=spend:txe
  (sign:spend:txe [~ mix1-seeds 4] test-sk)
=/  mix1-input=input:txe
  [mix1-note mix1-spend]
::
=/  mix2-note-hash=hash:txe  (hash:nnote:txe mix2-note)
=/  mix2-seed=seed:txe
  :*  ~
      test-lock
      *timelock-intent:txe
      177
      mix2-note-hash
  ==
=/  mix2-seeds=seeds:txe
  (~(put z-in *seeds:txe) mix2-seed)
=/  mix2-spend=spend:txe
  (sign:spend:txe [~ mix2-seeds 3] test-sk)
=/  mix2-input=input:txe
  [mix2-note mix2-spend]
::
=/  mix-inputs=inputs:txe
  %-  multi:new:inputs:txe
  ~[mix1-input mix2-input]
=/  test5-result=timelock-range:txe
  (roll-timelocks:inputs:txe mix-inputs)
::
::  ============================================
::  TEST CASE 6: Two inputs - both absolute min/max + both relative min/max
::  ============================================
::
=/  both1-hash=hash:txe
  (hash-hashable:tip5 leaf+0xffff)
=/  both1-source=source:txe
  [both1-hash %.n]
=/  both1-name=nname:txe
  (simple:new:nname:txe test-lock both1-source)
=/  both1-timelock=timelock:txe
  `[absolute=[`40 `70] relative=[`5 `35]]  :: both absolute and relative
=/  both1-note=nnote:txe
  :*  [%0 35 both1-timelock]         :: origin-page 35
      both1-name
      test-lock
      both1-source
      220
  ==
::
=/  both2-hash=hash:txe
  (hash-hashable:tip5 leaf+0x1010)
=/  both2-source=source:txe
  [both2-hash %.n]
=/  both2-name=nname:txe
  (simple:new:nname:txe test-lock both2-source)
=/  both2-timelock=timelock:txe
  `[absolute=[`38 `75] relative=[`10 `40]]  :: both absolute and relative
=/  both2-note=nnote:txe
  :*  [%0 30 both2-timelock]         :: origin-page 30
      both2-name
      test-lock
      both2-source
      260
  ==
::
=/  both1-note-hash=hash:txe  (hash:nnote:txe both1-note)
=/  both1-seed=seed:txe
  :*  ~
      test-lock
      *timelock-intent:txe
      215
      both1-note-hash
  ==
=/  both1-seeds=seeds:txe
  (~(put z-in *seeds:txe) both1-seed)
=/  both1-spend=spend:txe
  (sign:spend:txe [~ both1-seeds 5] test-sk)
=/  both1-input=input:txe
  [both1-note both1-spend]
::
=/  both2-note-hash=hash:txe  (hash:nnote:txe both2-note)
=/  both2-seed=seed:txe
  :*  ~
      test-lock
      *timelock-intent:txe
      254
      both2-note-hash
  ==
=/  both2-seeds=seeds:txe
  (~(put z-in *seeds:txe) both2-seed)
=/  both2-spend=spend:txe
  (sign:spend:txe [~ both2-seeds 6] test-sk)
=/  both2-input=input:txe
  [both2-note both2-spend]
::
=/  both-inputs=inputs:txe
  %-  multi:new:inputs:txe
  ~[both1-input both2-input]
=/  test6-result=timelock-range:txe
  (roll-timelocks:inputs:txe both-inputs)
::
::  ============================================
::  Return test results
::  ============================================
:*  %test1-seven-inputs
    inputs=test-inputs
    result=test1-result
    %test2-single-no-timelock
    inputs=single-inputs
    result=test2-result
    %test3-two-absolute
    inputs=abs-inputs
    result=test3-result
    %test4-two-relative
    inputs=rel-inputs
    result=test4-result
    %test5-mixed-abs-rel
    inputs=mix-inputs
    result=test5-result
    %test6-both-abs-and-rel
    inputs=both-inputs
    result=test6-result
==