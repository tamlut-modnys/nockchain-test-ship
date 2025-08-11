::  Simple test of raw-tx functionality from tx-engine
::
/+  tx-engine
::
:-  %say
|=  *
:-  %noun
::
::  Initialize the tx-engine with default blockchain constants
=/  txe  ~(. tx-engine *blockchain-constants:tx-engine)
::
::  Show the blockchain constants being used
*blockchain-constants:tx-engine