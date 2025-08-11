::  Test generator for ztd library functions
::
/+  *ztd-one
::
:-  %say
|=  [[* eny=@uv *] ~ ~]
:-  %noun
::  Test basic field operations
=/  test-results=(list [@t @])
  :~
    ['badd: 42 + 100 =' (badd 42 100)]
    ['bmul: 7 * 9 =' (bmul 7 9)]
    ['bsub: 100 - 42 =' (bsub 100 42)]
    ['bneg: -42 =' (bneg 42)]
    ['bpow: 2^10 =' (bpow 2 10)]
    ['binv: 1/7 =' (binv 7)]
    ['bdiv: 63 / 7 =' (bdiv 63 7)]
    ::  Test with field characteristic p
    ['p (field characteristic) =' p]
    ['g (generator) =' g]
    ['h (2^32 root of unity) =' h]
  ==
test-results