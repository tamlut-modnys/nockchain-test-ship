::  Test generator for tip5 hasher with a single value
::  Shows input and resulting hash
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
::  Test value to hash - using smaller value
=/  test-value=@
  0x1234
::
::  Create hashable structure with single leaf value
=/  hashable-value=hashable:tip5
  leaf+test-value
::
::  Compute the hash
=/  result-hash=hash:txe
  (hash-hashable:tip5 hashable-value)
::
::  Test 2: Cell with two leaf nodes
=/  left-value=@
  0xdead
=/  right-value=@
  0xbeef
::
::  Create hashable structure with two leaves in a cell
=/  hashable-cell=hashable:tip5
  [leaf+left-value leaf+right-value]
::
::  Compute the hash of the cell
=/  cell-hash=hash:txe
  (hash-hashable:tip5 hashable-cell)
::
::  Return both test results
:*  %test1-single-leaf
    input=test-value
    hash=result-hash
    %test2-cell-with-two-leaves
    input=[left=left-value right=right-value]
    hash=cell-hash
==