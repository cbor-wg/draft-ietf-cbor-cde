## CDE: Integer Value Examples {#exa-int}

<?v3xml2rfc table_borders="light" ?>

| EDN | CBOR (hex) | Comment |
| 0 | 00 | Smallest unsigned immediate int |
| -1 | 20 | Largest negative immediate int |
| 23 | 17 | Largest unsigned immediate int |
| -24 | 37 | Smallest negative immediate int |
| 24 | 1818 | Smallest unsigned one-byte int |
| -25 | 3818 | Largest negative one-byte int |
| 255 | 18ff | Largest unsigned one-byte int |
| -256 | 38ff | Smallest negative one-byte int |
| 256 | 190100 | Smallest unsigned two-byte int |
| -257 | 390100 | Largest negative two-byte int |
| 65535 | 19ffff | Largest unsigned two-byte int |
| -65536 | 39ffff | Smallest negative two-byte int |
| 65536 | 1a00010000 | Smallest unsigned four-byte int |
| -65537 | 3a00010000 | Largest negative four-byte int |
| 4294967295 | 1affffffff | Largest unsigned four-byte int |
| -4294967296 | 3affffffff | Smallest negative four-byte int |
| 4294967296 | 1b0000000100000000 | Smallest unsigned eight-byte int |
| -4294967297 | 3b0000000100000000 | Largest negative eight-byte int |
| 18446744073709551615 | 1bffffffffffffffff | Largest unsigned eight-byte int |
| -18446744073709551616 | 3bffffffffffffffff | Smallest negative eight-byte int |
| 18446744073709551616 | c249010000000000000000 | Smallest unsigned bignum |
| -18446744073709551617 | c349010000000000000000 | Largest negative bignum |
{: #tab-example-int title="CDE: Integer Value Examples"}

## CDE: Floating Point Value Examples {#exa-flt}

<?v3xml2rfc table_borders="light" ?>

| EDN | CBOR (hex) | Comment |
| 0.0 | f90000 | Zero |
| -0.0 | f98000 | Negative zero |
| Infinity | f97c00 | Infinity |
| -Infinity | f9fc00 | -Infinity |
| NaN | f97e00 | NaN with zero payload (see further down for more NaN examples) |
| 5.960464477539063e-8 | f90001 | Smallest positive f16 (subnormal) |
| 0.00006097555160522461 | f903ff | Largest positive subnormal f16 |
| 0.00006103515625 | f90400 | Smallest non-subnormal positive f16 |
| 65504.0 | f97bff | Largest positive f16 |
| 1.401298464324817e-45 | fa00000001 | Smallest positive f32 (subnormal) |
| 1.1754942106924411e-38 | fa007fffff | Largest positive subnormal f32 |
| 1.1754943508222875e-38 | fa00800000 | Smallest non-subnormal positive f32 |
| 3.4028234663852886e+38 | fa7f7fffff | Largest positive f32 |
| 5.0e-324 | fb0000000000000001 | Smallest positive f64 (subnormal) |
| 2.225073858507201e-308 | fb000fffffffffffff | Largest positive subnormal f64 |
| 2.2250738585072014e-308 | fb0010000000000000 | Smallest non-subnormal positive f64 |
| 1.7976931348623157e+308 | fb7fefffffffffffff | Largest positive f64 |
| -0.0000033333333333333333 | fbbecbf647612f3696 | Arbitrarily selected number |
| 10.559998512268066 | fa4128f5c1 | -"- |
| 10.559998512268068 | fb40251eb820000001 | Next in succession |
| 295147905179352830000.0 | fa61800000 | 2<sup>68</sup> (diagnostic notation truncates precision) |
| 2.0 | f94000 | Number without a fractional part |
| -5.960464477539063e-8 | f98001 | Largest negative subnormal f16 |
| -5.960464477539062e-8 | fbbe6fffffffffffff | Adjacent to largest negative subnormal f16 |
| -5.960464477539064e-8 | fbbe70000000000001 | -"- |
| -5.960465188081798e-8 | fab3800001 | -"- |
| 0.0000609755516052246 | fb3f0ff7ffffffffff | Adjacent to largest subnormal f16 |
| 0.000060975551605224616 | fb3f0ff80000000001 | -"- |
| 0.000060975555243203416 | fa387fc001 | -"- |
| 0.00006103515624999999 | fb3f0fffffffffffff | Adjacent to smallest f16 |
| 0.00006103515625000001 | fb3f10000000000001 | -"- |
| 0.00006103516352595761 | fa38800001 | -"- |
| 65503.99999999999 | fb40effbffffffffff | Adjacent to largest f16 |
| 65504.00000000001 | fb40effc0000000001 | -"- |
| 65504.00390625 | fa477fe001 | -"- |
| 1.4012984643248169e-45 | fb369fffffffffffff | Adjacent to smallest subnormal f32 |
| 1.4012984643248174e-45 | fb36a0000000000001 | -"- |
| 1.175494210692441e-38 | fb380fffffbfffffff | Adjacent to largest subnormal f32 |
| 1.1754942106924412e-38 | fb380fffffc0000001 | -"- |
| 1.1754943508222874e-38 | fb380fffffffffffff | Adjacent to smallest f32 |
| 1.1754943508222878e-38 | fb3810000000000001 | -"- |
| 3.4028234663852882e+38 | fb47efffffdfffffff | Adjacent to largest f32 |
| 3.402823466385289e+38 | fb47efffffe0000001 | -"- |
| float'7e01' | f97e01 | f16 qNaN with non-zero payload |
| float'7f800001' | fa7f800001 |  f32 sNan with payload of rightmost bit set -- no shorter encoding |
| float'7fbfe000' | f97dff |  f32 sNaN with 9 bit payload -- shortens to f16 |
| float'7fbff000' | fa7fbff000 |  f32 sNaN with 10 bit payload -- no shorter encoding |
| float'7fc00000' | f97e00 |  f32 qNaN with zero payload -- shortens to f16 |
| float'7ff0000000000001' | fb7ff0000000000001 |  f64 sNaN with payload of rightmost bit set -- no shorter encoding |
| float'7ff00000000003ff' | fb7ff00000000003ff |  f64 sNaN with 10 rightmost payload bits set -- no shorter encoding |
| float'7ff0000020000000' | fa7f800001 |  f64 sNaN with 23rd leftmost payload bit set -- shortens to f32 |
| float'7ff43d7c40000000' | fa7fa1ebe2 |  f64 sNaN with randomly chosen bit pattern -- shortens to f32 |
| float'7ff7fffff0000000' | fb7ff7fffff0000000 |  f64 sNaN with 23 leftmost payload bits set -- no shorter encoding |
| float'7ff8000000000000' | f97e00 |  f64 qNaN -- shortens to f16 |
| float'7fffe000' | f97fff |  f32 qNaN with 9 bit payload -- shortens to f16 |
| float'7ffff000' | fa7ffff000 |  f32 qNaN with 10 bit payload -- no shorter encoding |
| float'7ffffc0000000000' | f97fff |  f64 qNaN with 9 leftmost payload bits set -- shortens to f16 |
| float'7fffffffe0000000' | fa7fffffff |  f64 qNaN with 22 leftmost payload bits set -- shortens to f32 |
| float'7fffffffffffffff' | fb7fffffffffffffff |  f64 qNaN with all bits set -- no shorter encoding |
| float'fe00' | f9fe00 | negative NaN with zero payload |
| float'fff0000000000001' | fbfff0000000000001 |  f64 negative sNaN with payload of rightmost bit set -- no shorter encoding |
| float'fff8000000000000' | f9fe00 |  f64 negative qNaN with zero payload -- shortens to f16 |
| float'ffffffffe0000000' | faffffffff |  f64 negative qNaN with 22 leftmost payload bits set -- shortens to f32 |
{: #tab-example-flt title="CDE: Floating Point Value Examples"}

## Failing Examples: Not CDE {#exa-bad}

<?v3xml2rfc table_borders="light" ?>

| EDN | CBOR (hex) | Comment |
| {"b":0,"a":1} | a2616200616101 | Incorrect map key ordering |
| [4, 5] | 98020405 | Array length not in preferred serialization |
| 255 | 1900ff | Integer not in preferred serialization |
| -18446744073709551617 | c34a00010000000000000000 | Bignum with leading zero bytes |
| 10.5 | fa41280000 | Not in preferred serialization |
| NaN | fa7fc00000 | Not in preferred serialization |
| 65536 | c243010000 | Integer value too small for bignum |
| (_ h'01', h'0203') | 5f4101420203ff | Indefinite length encoding |
{: #tab-example-bad title="Failing Examples: Not CDE"}

