---
v: 3

title: CBOR Common Deterministic Encoding (CDE)
abbrev: CBOR CDE
docname: draft-ietf-cbor-cde-latest
category: bcp
stream: IETF
updates: 8949

date:
consensus: true
area: "Applications and Real-Time"
workgroup: CBOR
keyword:

# v3xml2rfc:
#  table_borders: light

venue:
  group: "Concise Binary Object Representation Maintenance and Extensions (CBOR)"
  mail: "cbor@ietf.org"
  github: cbor-wg/draft-ietf-cbor-cde

author:
  -
    ins: C. Bormann
    name: Carsten Bormann
    org: Universität Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63921
    email: cabo@tzi.org
contributor:
- name: Laurence Lundblade
  org: Security Theory LLC
  email: lgl@securitytheory.com
  contribution: Laurence provided most of the text that became
    {{models}} and {{impcheck}}.

normative:
  STD94: cbor
#    =: RFC8949
  IEEE754:
    target: https://ieeexplore.ieee.org/document/8766229
    title: IEEE Standard for Floating-Point Arithmetic
    author:
    - org: IEEE
    date: false
    seriesinfo:
      IEEE Std: 754-2019
      DOI: 10.1109/IEEESTD.2019.8766229
  RFC8610: cddl
  IANA.cddl:


informative:
  I-D.ietf-cbor-edn-literals: edn
  I-D.bormann-cbor-det: det
  I-D.mcnally-deterministic-cbor: dcbor
  I-D.bormann-cbor-numbers: numbers
  UAX-15:
    title: "Unicode Normalization Forms"
    rc: Unicode Standard Annex #15
    target: https://unicode.org/reports/tr15/
    date: false
  RFC8392: cwt
  RFC9581: tag1001
  RFC9679: thumb
  STD96: cose
  RFC7493: ijson
  RFC9741: more
  C23:
    author:
    - org: International Organization for Standardization
    title: >
      Information technology — Programming languages — C
    date: October 2024
    target: https://www.iso.org/standard/82075.html
    seriesinfo:
      ISO/IEC: 9899:2024
    ann: >
       
      This revision of the standard is widely known as C23.
      Technically equivalent specification text is available at
      <https://www.open-std.org/jtc1/sc22/wg14/www/docs/n3220.pdf>.

--- abstract

[^abs1-]

[^abs1-]:
    CBOR (STD 94, RFC 8949) defines the concept of "Deterministically
    Encoded CBOR" in its Section 4.2, determining one specific way to
    encode each particular CBOR value.
    This definition is instantiated by "core requirements", providing
    some flexibility for application specific decisions; this makes it
    harder than necessary to offer Deterministic Encoding as a
    selectable feature of generic CBOR encoders.

    The present specification documents the Best Current Practice for CBOR
    _Common Deterministic Encoding_ (CDE), which can be shared by a
    large set of applications with potentially diverging detailed
    application requirements.

    The document also discusses the desire for partial
    implementations, which can be another reason for constraining CBOR
    encoders, and singles out the encoding constraint
    "`definite-length-only`" as a likely constraint to be used in
    application protocol and media type definitions.

[^upd-]:
    This specification updates RFC 8949 in that it provides
    clarifications and definitions of additional terms as well as more
    examples and explanatory text; it does not make technical changes
    to RFC 8949.

[^upd-]

[^status]

[^status]: This is a draft pull request.
    It needs further editing, but could be useful as
    input for the discussion of directions to be taken at 2025-cbor-17 interim on 2025-10-01.

--- middle

# Introduction

[^abs1-]

[^upd-]

## Structure of This Document

After introductory material (this introduction and {{choi}}), {{dep}}
defines the CBOR Common Deterministic Encoding (CDE).
{{cddl-support}} defines Concise Data Definition Language (CDDL) support for indicating the use of CDE.
This is followed by the conventional sections for
{{<<seccons}} ({{<seccons}}),
{{<<sec-iana}} ({{<sec-iana}}),
and {{<<sec-combined-references}} ({{<sec-combined-references}}).

For use as background material, {{models}} introduces terminology for
the layering of models used to describe CBOR.

Instead of giving rise to the definition of application-specific,
non-interoperable variants of CDE, this document identifies
Application-level Deterministic Representation (ALDR) rules as a
concept that is separate from CDE itself ({{aldr}}) and therefore out of
scope for this document.
ALDR rules are situated at the application-level, i.e., on top of
CDE, and address requirements on deterministic representation of
application data that are specific to an application or a set of
applications.
ALDR rules are routinely provided as part of a specification for a CBOR-based
protocol, or, if needed, can be provided by referencing a shared "ALDR
ruleset" that is defined in a separate document.

The informative {{impcheck}} provides brief checklists that implementers
can use to check their CDE implementations.
{{ps}} provides a checklist for implementing `preferred-serialization`.
{{bs}} discusses the `definite-length-only` encoding constraint, which
may be used by encoders to hit a sweet spot for maximizing
interoperability with partial (e.g., constrained) CBOR decoder
implementations.
{{cde}} discusses `lexicographic-map-sorting`, which is added to these
two encoding constraints to arrive at CDE.

{{examples}} provides a few examples for CBOR data items in CDE
encoding, as well as a few failing examples; {{exa-pref}} examines
preferred serialization of the number `1` in more detail.
For reference by implementers, {{encode-f16}} shows an implementation
that attempts to encode a floating point number as "half precision" binary16.

## Conventions and Definitions

The conventions and definitions of {{-cbor}} apply.
{{models}} provides additional discussion of the terms information
model, data model, and serialization.

The terms specifically called out for this document fall into four categories:

1. terms defined in {{Section 1.2 of RFC8949@-cbor}} (among others,
   Well-Formed, Valid, and Expected);
2. terms defined (or consistently used) in the text of {{RFC8949}}, but
   possibly supplemented with a concise definition here ("{{RFC8949}}
   terms"), such as Preferred Serialization;
3. terms we use in their English/computer science sense ("generic
   terms"), for which we may still want to supply a sharpened
   definition here, such as Deterministic Encoding;
4. terms specifically defined in this document ("CDE terms"),
   such as CDE or Encoding constraint.

{:vspace="1"}
"CBOR Application" ("application" for short, {{RFC8949}} term):
: application that uses CBOR as an
interchange format and uses (often generic) CBOR encoders/decoders to
serialize/ingest the CBOR form of their application data to be
exchanged.

"CBOR Protocol" ({{RFC8949}} term):
: the protocol that
governs the interchange of data in CBOR format for a specific
application or set of applications.

"Representation" ({{RFC8949}} term):
: the process, and its result, of building
the representation format out of (information-model level) application
data.

"Serialization" ({{RFC8949}} term):
: the subset of the representation process, and its
result, that represents ("serializes") a data item at the CBOR generic data model
form into encoded data items.
"Encoding" is often used as a synonym when the focus is on that.
Often involves choosing one of several equivalent encodings (serializations), i.e., providing "variation".

"Encoding constraint" (CDE):
: A rule that governs the choice of one of several otherwise equivalent CBOR encodings for a CBOR data item.
  Several encoding constraints can be combined into an encoding
  constraint set, which is itself an encoding constraint that requires
  that all encoding constraints in the set are met.\\
  When giving encoding constraints names, this document uses lower-case
  words separated by hyphens, rendered in a typewriter font, as in
  `lexicographic-map-sorting`.

"Preferred serialization" ({{RFC8949}} term):
: Defined in {{Section 4.1 of RFC8949@-cbor}} for the basic data model,
  Preferred Serialization is one specific set of encoding constraints.
  Tag specifications can also define the Preferred Serialization of
  the specific tag that are defining (e.g., in {{Section 3.4.3 of
  RFC8949@-cbor}}).
  Collectively the encoding constraint is named `preferred-serialization`.

"Deterministic encoding" (generic):
: An encoding process (or, more specifically, encoding constraint) that deterministically always chooses the same encoding for each data item with several encoding choices.
(The term refers both to such a process and a result of a specific such process.)
Note that there can be many rule sets that each can yield
 deterministic encodings; for instance, {{-cbor}} defines elements of a
 legacy deterministic encoding in {{Section 4.2.3 of RFC8949@-cbor}} that is distinct from the one for which requirements are defined in {{Section 4.2.1 of RFC8949@-cbor}}.

"Generic encoder"/"Generic decoder" ({{RFC8949}} term):
: Defined in {{Section 5.2 of RFC8949@-cbor}}, a generic CBOR decoder
   can decode all well-formed ({{Section 1.2 of RFC8949@-cbor}}) encoded CBOR data
   items and present the data items to an application.
   Similarly, generic CBOR encoders provide an application interface that allows
   the application to specify any well-formed value to be encoded as a
   CBOR data item, including simple values and tags that are unknown to the
   encoder.

"Partial Implementation" (CDE):
: A decoder or encoder that is not generic, but usually limited to the
  needs of specific (a specific set of) applications.

"Common Deterministic Encoding" (CDE):
: The common deterministic encoding process defined in the present
  BCP, based on Preferred Serialization and {{Section 4.2.1 of RFC8949@-cbor}}.
  Out of many potential and actual deterministic encodings, CDE is
  RECOMMENDED for implementation and specification where deterministic
  encoding is required or desired.

"CDE-checking decoder" (CDE):
: A decoder that checks that the encoding constraints of CDE have been met.
  (Note that a decoder can also provide other types of checks, such
  validity-checking and duplicate-checking ({{RFC8949}}); just speaking
  of "checking decoders" without further qualification can therefore
  be imprecise.)
  Note that an encoder can meet a set of encoding constraints without
  the CBOR decoder then checking them (or even being aware of the
  constraints or that they have been used).
  Certain benefits of specific encoding constraints may only be
  available in conjunction with decoders checking those constraints.

Bignum ({{RFC8949}} term):
: An integer that is represented using CBOR tag 2 or tag 3.
  (Not called Bigint as that term may be in use for a platform representation.)

NaN payload ({{IEEE754}}):
: All but the first bit (Q-bit) of the trailing significand component
  of the {{IEEE754}} value for a NaN.
  Separate from sign bit and Q-bit.

Trivial NaN (CDE):
: A NaN with a zero sign bit, and a payload composed of zero bits only.
  Note that in {{IEEE754}}, all-zero payload implies that the Q-bit is
  set to one.
  Represented in CDE as the three bytes 0xf97e00.

{::boilerplate bcp14-tagged-bcp14}

# Encoding Choices in CBOR {#choi}

In many cases, CBOR provides more than one way to encode a data item,
i.e., to serialize it into a sequence of bytes that is well-formed CBOR.
This flexibility can provide convenience for the generator of the
encoded data item, but handling the resulting variation can also put
an onus on the decoder.
In general, there is no single perfect encoding choice that is optimal for all
applications.
Determining whether encoding constraints are needed and, if yes,
choosing the right encoding constraints can be one element of
application protocol design.
Having predefined sets of such choices is a useful way to reduce
variation between applications, enabling generic implementations.

The default choice of course is not to employ any encoding constraints at all.
The name `well-formed` is a good name for the empty set of encoding
constraints, as well-formed CBOR is the baseline that is required for
any interoperability.
Many CBOR applications have no need for encoding constraints and
therefore have no requirement beyond `well-formed` encoding.

Still, an encoder has to make a decision at some point, even if it
could use any well-formed CBOR encoding.
{{Section 4.1 of RFC8949@-cbor}} provides a recommendation for a
*Preferred Serialization*.
This recommendation is a useful guideline for generic encoders, and it
is a good choice for specialized encoders for most applications.
Its main constraint is to choose the shortest _head_ ({{Section 3
of RFC8949@-cbor}}) that preserves the value of a data item
(`shortest-head` encoding constraint).
In addition, tag definitions can specify a preferred serialization for
a tag ({{Section 3.4 of RFC8949@-cbor}}); the `shortest-head` encoding
constraint together with the preferred serializations of tags
constitute the `preferred-serialization` encoding constraint.
Typically, this encoding constraint is relevant only for the encoder,
as there is nothing to be gained by enforcing it by itself in a
decoder, which will instead accept all well-formed CBOR.

Preferred Serialization allows indefinite length encoding ({{Section
3.2 of RFC8949@-cbor}}), which does not express the length of a string,
an array, or a map in its head.  Supporting both definite length and
indefinite length encoding is an additional onus on the decoder.
Many applications therefore choose not to use indefinite length
encoding at all (`definite-length-encoding` encoding constraint),
which enables the use of *partial implementations* that do not support
decoding indefinite length encoding.
In contrast to `preferred-serialization`, relying on this constraint
enforces the choice at the decoder, we therefore speak about an
_interoperability constraint_.

Combining `preferred-serialization` with `definite-length-encoding`
still allows some variation.
Specifically, there is more than one serialization for data items that
contain maps that have more than one entry:
The order of serialization of map entries in a map is not significant
in CBOR (the same as in JSON), so maps with more than one entry have all
permutations of these entries as valid serializations.

The encoding constraint `lexicographic-map-sorting`
defines a common order for the entries in a map, requiring
lexicographic ordering for the representations of the map keys.
For many applications, ensuring this common order is an additional
onus on the generator that is not actually needed, so they do not
choose to apply this encoding constraint.
However, there are several use cases for Deterministic Serialization
(further discussed in {{Section 2 of -det}}), and
if the objective is minimal effort for the consuming
application, deterministic map ordering can be useful even outside
those use cases.
For most of these use cases, the benefits of the encoding constraints
for deterministic serialization not only require the encoder to follow
them, but also need the constraints to be enforced ("checked") by the
decoder.
We speak of "checking decoders", which also turn the encoding
constraints into interoperability constraints.

{{tab-constraints}} summarizes the sets of encoding choices that have
been given names in this section.

<?v3xml2rfc table_borders="full" ?>

{: #tab-constraints title="Constraints on the Serialization of CBOR"}
| Encoding Constraint            | Interoperability Constraint?                                                                                                                           | Applications |
|--------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|
| `well-formed` (no constraints) |                                                                                                                                                        |              |
| `preferred-serialization`      | typically no (encoding guideline only)                                                                                                                 | most         |
| `definite-length-encoding`     | often yes (enabling partial implementations in the decoder)                                                                                            | many         |
| `lexicographic-map-sorting`    | an interoperability constraint specifically for *Common Deterministic Encoding* (CDE)                                                                  | specific     |
| `cde`                          | the combination of `preferred-serialization`, `definite-length-encoding` and `lexicographic-map-sorting` as interoperability constraints to obtain CDE | specific     |


Note that the objective to have a deterministic serialization for a
specific application data item can only be fulfilled if the
application itself does not generate multiple different CBOR data
items that represent that same (equivalent) application data item.
We speak of the need for Application-level Deterministic
Representation (ALDR), and we may want to aid achieving this by
the application defining rules for ALDR (see also {{aldr}}).
Where Deterministic Representation is not actually needed,
application-level representation rules of course can still be useful
to facilitate processing at the recipient.

# CBOR Common Deterministic Encoding (CDE) {#dep}

This specification documents the *CBOR Common Deterministic Encoding*
(CDE) Best Current Practice that is
based on the _Core Deterministic Encoding
Requirements_ defined for CBOR in
{{Section 4.2.1 of RFC8949@-cbor}}.

Note that, for {{RFC8949}}, this specific set of requirements is elective — in
principle, other variants of deterministic encoding can be defined
(and have been, now being phased out, as detailed in {{Section 4.2.3
of RFC8949@-cbor}}).
In many applications of CBOR, deterministic encoding is not used
at all, as its restriction of choices can create some additional
performance cost and code complexity.

{{-cbor}}'s "Core Deterministic Encoding Requirements" are designed to
provide well-understood and
easy-to-implement rules while maximizing coverage, i.e., the subset of
CBOR data items that are fully specified by these rules, and also
placing minimal burden on implementations.

Formally, Common Deterministic Encoding (CDE) is an encoding
constraint (named `cde` for short), built from multiple constituent encoding
constraints (which may, in turn, be built from multiple constituent
encoding constraints).
As discussed in {{choi}}, CDE combines the constraints of
`preferred-serialization` with `definite-length-only` and the
`lexicographic-map-sorting` constraint.

{:aside}
>
While many CBOR encoder implementations do set out to provide Preferred
Serialization, there is less of a practical requirement to fully
conform, as generic CBOR decoders do not normally check for Preferred
Serialization.
In contrast, an application that relies on deterministic representation,
during ingestion of an encoded CBOR data item will often need to
employ a "CDE-checking decoder", i.e., a CBOR decoder configured to
also check that all CDE encoding constraints are satisfied (see also
{{impcheck}}).
Here, small deviations from CDE, including deviations from
`preferred-serialization`, turn into interoperability problems; hence
the additional attention of the present document on these constraints.

The remaining section discusses the three constituent encoding
constraints from which `cde` is defined.

## The `preferred-serialization` Constraint {#psconstr}

The `preferred-serialization` encoding constraint is a combination of the
`shortest-head` constraint and tag-specific encoding constraints
defined to be part of `preferred-serialization`.

The `shortest-head` constraint is somewhat trivial (see {{exa-pref}} for
examples), except for two fine points having to do with the numeric
systems underlying CBOR.

### `shortest-head` and Integer Serialization

{{Section 4.2.2 of RFC8949@-cbor}} picks up on the interaction of extensibility
(CBOR tags) and deterministic encoding.
CBOR itself uses some tags to increase the range of its basic
generic data types.
Specifically, tags 2/3 extend the range of basic major types 0/1 in a
seamless way.
{{Section 4.2.2 of RFC8949@-cbor}} recommends handling this transition the same
way as with the transition between different integer representation
lengths in the basic generic data model, i.e., by mandating the
Preferred Serialization for all integers ({{Section 3.4.3 of
RFC8949@-cbor}}; see also {{exa-int}} and {{exa-pref}}).

By adopting the encoding constraints from Preferred Serialization, CDE
turns this recommendation into a mandate: Integers that can be
represented by basic major type 0 and 1 MUST be encoded using the (`shortest-head`)
deterministic encoding defined for them, and integers outside this
range MUST be encoded using the Preferred Serialization ({{Section 3.4.3
of RFC8949@-cbor}}) of tag 2 and 3 (i.e., no leading zero bytes).

{:aside}
>
Not only for numbers, most tags capture more specific application
semantics than tag 2/3 and therefore may be harder to define a
deterministic encoding for.
While the deterministic encoding of their tag internals is often
covered by the _Core Deterministic Encoding Requirements_, the mapping
of diverging platform application data types onto the tag contents may
require additional attention to perform it in a deterministic way; see
{{Section 3.2 of -det}} for
more explanation as well as examples.\\
As CDE would continually
need to address additional issues raised by the registration of new
tags, this specification recommends that new tag registrations address
deterministic encoding in the context of CDE.
Note that not in all cases the tag's deterministic encoding constraints
will be confined to its definition of Preferred Serialization.

### `shortest-head` and {{IEEE754}} Floating Point

A particularly difficult field to obtain deterministic encoding for is
floating point numbers, partially because they themselves are often
obtained from processes that are not entirely deterministic between platforms.
See {{Section 3.2.2 of -det}} for more details.
{{Section 4.2.2 of RFC8949@-cbor}} presents a number of choices that need to
be made to obtain deterministic representation, some of which are
application-level choices.
To obtain the CBOR Common Deterministic Encoding (CDE), this
specification entirely recurs to the `shortest-head` component of
Preferred Serialization and does *not* itself define any additional
constraints.

Similar to the `shortest-head` constraint for major types 0 to 6,
floating point values are represented with the shortest head ({{Section
3 of RFC8949@-cbor}}) that preserves the value of the data item.
This means that the application has no control over the representation
size, e.g., the number 1.0 will always be serialized as a binary16 floating
point number (0xf93c00) as that is the shortest representation that
preserves the value.
It also means that generic decoders often will expand floating point
numbers to a single size that is convenient on the platform (such as
binary64).

The rest of this section responds to a perceived need to clarify some of the
Preferred Serialization constraints for floating point values.
Specifically, CDE specifies (in the order of the bullet list at the end of {{Section
4.2.2 of RFC8949@-cbor}}):

{: group="1"}
1. Besides the mandated use of Preferred Serialization, there is no further
   specific action for the two different zero values, e.g., an encoder
   that is asked by an application to represent a negative floating
   point zero (-0.0) will generate 0xf98000.
2. There is no attempt to mix integers and floating point numbers,
   i.e., all floating point values are encoded as the preferred
   floating-point representation that accurately represents the value,
   independent of whether the floating point value is, mathematically,
   an integral value (choice 2 of the second bullet in {{Section
   4.2.2 of RFC8949@-cbor}}).
3. Apart from finite and infinite numbers, {{IEEE754}} floating point
   values include NaN (not a number) values {{-numbers}}.
   In CDE, there is no special handling of NaN values, except a
   clarification that the
   Preferred Serialization rules also apply to NaNs (with zero or
   non-zero payloads), using the encoding of NaNs as defined
   in Section 6.2.1 of {{IEEE754}}.
   Note that {{IEEE754}} leaves several details about handling NaNs
   implementation-defined; CBOR makes several decisions here:
   Specifically, shorter forms of encodings for a NaN
   are used when that can be achieved by only removing trailing zeros
   in the NaN payload (example serializations are available in
   {{Section A.1.2 of -numbers}}; see also the aside below).
   Further clarifying a "should"-level statement in Section 6.2.1 of
   {{IEEE754}}, the CBOR encoding always uses a leading bit of 1 in the
   significand to encode a quiet NaN; the use of signaling NaNs by
   application protocols is NOT RECOMMENDED but when presented by an
   application these are encoded by using a leading significand bit of 0.

   Typically, most applications that employ NaNs in their storage and
   communication interfaces will only use a single NaN value: quiet,
   non-negative NaN with a payload of all zero bits.
   This value therefore deterministically encodes as 0xf97e00.
4. There is no special handling of subnormal values.
5. CDE does not presume
   equivalence of basic floating point values with floating point
   values using other representations (e.g., tag 4/5).
   Such equivalences and related deterministic representation rules
   can be added at the ALDR level if desired, e.g., by stipulating
   additional equivalences and deterministically choosing exactly one
   representation for each such equivalence, and by restricting in
   general the set of data item values actually used by an
   application.\\
   (A new tag definition might define Preferred Serializations that
   are basic major-type 7 floating point values; this is
   unproblematic as long as the tag definition does not attempt to
   redefine the Preferred Serialization for basic floating point values.)

The main intent here is to preserve the basic generic data model, so
applications (in their ALDR rules or by referencing a separate ALDR
ruleset document, see
{{aldr}}) can
make their own decisions within that data model.
E.g., an application's ALDR rules can decide that it only ever allows a
single NaN value that would be encoded as 0xf97e00, so a CDE
implementation focusing on this application would not even need to
provide processing for other NaN values.
Basing the definition of both CDE and ALDR rules on the
generic data model of CBOR also means that there is no effect on the
Concise Data Definition Language (CDDL)
{{-cddl}}, except where the data description is documenting specific
encoding decisions for byte strings that carry embedded CBOR (see
{{cddl-support}}).

{:aside}
>
Section 9.7 of {{IEEE754}} specifies an implementation-defined
programming interface for accessing non-zero NaN payloads, the
getpayload/setpayload functions.
(A version of these, with separate sets of functions for each
representation size, is also included in the revision of the C
language that is most recent at the time of writing {{C23}}.)
When using these functions, it is important to be aware that their effects are
specific to the representation size of the floating point values they
are applied to (e.g., half, single, or double precision).
The representation size for interchange will be chosen by Preferred
Serialization for each value, which may not always be the size that
was intended for the use of getpayload/setpayload.
A good way to handle this diversity is, upon decoding, to widen the
representation size of all NaNs to a common size, often double
precision ({{IEEE754}} binary64), before applying getpayload/setpayload.
The inverse to the narrowing performed by preferred serialization,
this widening operation successively adds the necessary one bits to
the exponent and trailing zero bits to the payload to build the next
longer form until the desired size for the NaN has been reached.

## The `definite-length-only` Encoding Constraint

The `definite-length-only` encoding constraint means that indefinite
length encoding MUST NOT be used.
In many encoders, the use of indefinite length encoding is controlled
by its configuration and can simply be switched off.

{:aside}
>
Indefinite length strings require non-trivial implementation effort when a with zero allocation/zero copy approach is in use.
Therefore, there can be a strong argument to not include them in a partial implementation.
Application protocols may cater to this argument by specifying the encoding constraint `definite-length-only`.

## The `lexicographic-map-sorting` Encoding Constraint

In line with {{Section 4.2.1 of RFC8949@-cbor}}, the third constituent
of CDE is the constraint to sort map entries bytewise
lexicographically by their map keys.

{:aside}
>
In some implementations, where platform representations of maps
preserve ordering, `lexicographic-map-sorting` can be achieved using a
generic CBOR encoder by pre-ordering all maps to be encoded, as long
as that generic encoder also preserves the ordering in maps.
In implementations without these properties, a specialized CBOR
encoder may need to be employed.

Specifically, for `lexicographic-map-sorting` the (CDE-encoded) map
key of a map entry MUST be lexicographically strictly greater than
that of the map entry immediately preceding it in the encoding of the
map, if any.
(Note that this constraint is trivially satisfied by data items that
do not contain maps or only contain maps that have zero or one map
entry.)
The bytewise lexicographic comparison steps in parallel through the
bytes of the two encoded map keys, comparing the (unsigned integer
values of the) bytes.
If the bytes differ, the difference determines the outcome of the comparison.
If the bytes are the same, the next pair of bytes are examined.
If there is no such next pair, the comparison and thus CDE
serialization fails entirely (the map keys of the two map entries are
the same, which is not valid in a CBOR map, or one is an extension of
the other, which is not possible in the self-delimiting CBOR
encoding).
See the last bullet of {{Section 4.2.1 of RFC8949@-cbor}} for examples
and additional explanation.

{:aside}
>
RFC 8949 has a validity requirement that maps cannot contain multiple
entries with the same key (“no duplicate keys”, {{Sections 5.3.1 and
5.6 of RFC8949@-cbor}}).
This is only a validity requirement as enforcing this requires the
encoder to be aware of all map keys at the same time, which may be
particularly difficult to implement for streaming encoders.
The `lexicographic-map-sorting` encoding constraint does require such
awareness already as a prerequisite to sorting the entries by map key.
In combination with the other CDE encoding constraints
`preferred-serialization` and `definite-length-only`, the check
therefore becomes trivial: multiple entries with the same
map key would have the same (deterministic) map key serialization and
would therefore be consecutive when sorted.
Given this opportunity, the `lexicographic-map-sorting` encoding constraint
therefore is
deliberately phrased to require consecutive entries to have strictly
increasing map keys; with the other CDE encoding constraints, this prevents
encoding multiple entries that have
the same key.
Note that {{Section 5.6.1 of RFC8949@-cbor}} lists one specific case
"(specifically, -0.0 is equal to 0.0)" where two different keys are
considered equivalent for the purpose of duplicate map keys; this
needs to be checked with extra code for a full validity checker.


# CDDL support

CDDL defines the structure of CBOR data items at the data model level;
it enables being specific about the data items allowed in a particular
place.
It does not specify encoding; CBOR protocols can specify the use
of CDE (or simply `definite-length-only` encoding) independent of the
CDDL data model.

CDDL operates by restricting the set of data-model level data items.
E.g., CDDL allows the specification of a floating point data item
as "float16"; this means the application data model only foresees data
that can be encoded as {{IEEE754}} binary16.
Note that specifying "float32" for a floating point data item enables
all floating point values that can be represented as binary32; this
includes values that can also be represented as binary16 and that will
be so represented in Preferred Serialization.

{{-cddl}} defines control operators to indicate that the contents of a
byte string carries a CBOR-encoded data item (`.cbor`) or a sequence of
CBOR-encoded data items (`.cborseq`).

CDDL specifications may want to specify that the data items should be
encoded in Common CBOR Deterministic Encoding.
The present specification adds two CDDL control operators that can be used
for this.

The control operators `.cde` and `.cdeseq` are exactly like `.cbor` and
`.cborseq` except that they also require the encoded data item(s) to be
encoded according to CDE.
[^nodlo]

[^nodlo]: Note that there is no `.dlo` or `.dloseq` for
    `definite-length-only`, as, so far, a requirement for these hasn't
    been detected.

For example, a byte string of embedded CBOR that is to be encoded
according to CDE can be formalized as:

~~~
leaf = #6.24(bytes .cde any)
~~~

More importantly, if the encoded data item also needs to have a
specific structure, this can be expressed by the right-hand side
(instead of using the most general CDDL type `any` here).

(Note that the `.cdeseq` control operator does not enable specifying
different deterministic encoding requirements for the elements of the
sequence.  If a use case for such a feature becomes known, it could be
added, or the CBOR sequence could be constructed with `.join` ({{Section
3.1 of -more}}).)

Obviously, specifications that document ALDR rules can define related control operators
that also embody the processing required by those ALDR rules,
and are encouraged to do so.


# Security Considerations {#seccons}

The security considerations in {{Section 10 of RFC8949@-cbor}} apply.
The use of deterministic encoding can mitigate issues arising out of
the use of non-preferred serializations specially crafted by an attacker.
However, this effect only accrues if the decoder actually checks that
deterministic encoding was applied correctly.
More generally, additional security properties of deterministic
encoding can rely on this check being performed properly.

# IANA Considerations {#sec-iana}

[^to-be-removed]

[^to-be-removed]: RFC Editor: please replace RFCXXXX with the RFC
    number of this RFC and remove this note.

This document requests IANA to register the contents of
{{tbl-iana-reqs}} into the registry
"{{cddl-control-operators (CDDL Control Operators)<IANA.cddl}}" of the
{{IANA.cddl}} registry group:

<?v3xml2rfc table_borders="light" ?>

| Name      | Reference |
| .cde      | \[RFCXXXX] |
| .cdeseq   | \[RFCXXXX] |
{: #tbl-iana-reqs title="New control operators to be registered"}


--- back

# Information Model, Data Model and Serialization {#models}

This appendix is informative.

For a good understanding of this document, it is helpful to understand the difference between an information model, a data model and serialization.

<?v3xml2rfc table_borders="full" ?>

|                   | Abstraction Level                                            | Example                                              | Standards | Implementation Representation                                       |
| Information Model | Top level; conceptual                                        | The temperature of something                         |           |                                                                     |
| Data Model        | Realization of information in data structures and data types | A floating-point number representing the temperature | CDDL      | API input to CBOR encoder library, output from CBOR decoder library |
| Serialization     | Actual bytes encoded for transmission                        | Encoded CBOR of a floating-point number              | CBOR      | Encoded CBOR in memory or for transmission                          |
{: #layers title="A three-layer model of information representation"}

CBOR does not provide facilities for expressing information models.
They are mentioned here for completeness and to provide some context.

CBOR defines a palette of basic data items that can be grouped into
data types such as the usual integer or floating-point numbers, text or
byte strings, arrays and maps, and certain special "simple values"
such as Booleans and `null`.
Extended data types may be constructed from these basic types.
These basic and extended types are used to construct the data model of a CBOR protocol.
One notation that is often used for describing the data model of a CBOR protocol is CDDL {{-cddl}}.
The various types of data items in the data model are serialized per RFC 8949 {{-cbor}} to create encoded CBOR data items.

## Data Model, Encoding Variants and Interoperability with Partial Implementations

In contrast to JSON, CBOR-related documents explicitly discuss the data model separately from its serialization.
Both JSON and CBOR allow variation in the way some data items can be serialized:

* In JSON, the number 1 can be serialized in several different ways
(`1`, `0.1e1`, `1.0`, `1.00`, `100e-2`) — while it may seem obvious to use
`1` for this case, this is less clear for `1000000000000000000000000000000` vs. `1e+30` or `1e30`.
(As its serialization also doubles as a human-readable interface, JSON
also allows the introduction of blank space for readability.)
The lack of an agreed data model for JSON led to the need for a complementary
specification documenting an interoperable subset {{-ijson}}.

* The CBOR standard addresses constrained environments, both by being
  concise and by limiting variation, but also by conversely allowing
  certain data items in the data model to be serialized in multiple
  ways, which may ease implementation on low-resource platforms.
  On the other hand, constrained environments may further save
  resources by only partially implementing the decoder functionality,
  e.g., by not implementing all those variations.

Note that partial implementations of a representation format are quite common
in embedded applications.
Protocols for embedded applications often reduce the footprint of an
embedded JSON implementation by explicitly restricting the breadth of
the data model, e.g., by not using floating point numbers with 64 bits
of precision or by not using floating point numbers at all.
These data-model-level restrictions do not get in the way of using
complete implementations ("generic encoders/decoders", {{Section 5.2 of
RFC8949@-cbor}}).

Intended as as a routine way for encoders to deal with this encoding
variability exhibited by certain data items, CBOR defines a _Preferred
Serialization_ ({{Section 4.1 of RFC8949@-cbor}}).
_Partial CBOR implementations_ are more likely to interoperate if their
encoder uses Preferred Serialization and the decoder implements
decoding at least the Preferred Serialization for the data items
supported.
On the other hand, a specific protocol for a constrained application
may specify restrictions that for instance allow or even specify some
fields to be of fixed length, leaving the envelope of Preferred
Serialization, but guaranteeing interoperability even with
partial implementations optimized for this application.

Another encoding variation is provided by indefinite-length encoding
for strings, arrays, and maps, which enables these to be streamed
without knowing their length upfront ({{Section 3.2 of RFC8949@-cbor}}).
For applications that do not perform streaming of this kind, variation
can be reduced (and often performance improved) by only allowing
definite-length encoding, as in the encoding constraint `definite-length-only`.

The Common Deterministic Encoding, CDE, finally combines
`preferred-serialization` and `definite-length-only` with a deterministic ordering of entries in a map
(`lexicographic-map-sorting`, see also {{tab-constraints}}).

(Note that applications may need to complement deterministic
encoding with decisions on the deterministic representation of
application data into CBOR data items, see {{aldr}}.)

Encoding constraints (unconstrained `well-formed`, `preferred-serialization`,
`definite-length-only`, `cde`) are orthogonal to data-model-level data
definitions as provided by {{-cddl}}.
To be useful in all applications, these constraints have been defined
for all possible data items, covering the full range of values offered
by CBOR's data types.
This ensures that these serialization constraints can be applied to
any CBOR protocol, without requiring protocol-specific modifications
to generic encoder/decoder implementations.

# Application-level Deterministic Representation {#aldr}

This appendix is informative.

CBOR application protocols are agreements about how to use CBOR for a
specific application or set of applications.

For a CBOR protocol to provide deterministic representation, both the
encoding and application layer must be deterministic.
While CDE ensures determinism at the encoding layer, requirements at
the application layer may also be necessary.

Application protocols make representation decisions in order to
constrain the variety of ways in which some aspect of the information
model could be represented in the CBOR data model for the application.
For instance, there are several CBOR tags that can be used to
represent a time stamp (such as tag 0, 1, 1001), each with some specific
properties.

<aside markdown="1">
For example, an application protocol that needs to represent birthdate/times could specify:

* At the sender’s convenience, the birthdate/time MAY
    be sent either in epoch date format (as in tag 1) or string date
    format (as in tag 0).
* The receiver MUST decode both formats.

While this specification is interoperable, it lacks determinism.
There is variability in the application layer akin to variability in the CBOR encoding layer when CDE is not required.

To make this example application layer specification deterministic,
allow only one date format (or at least be deterministic when there is
a choice, e.g., by specifying string format for leap seconds only).
</aside>

Application protocols that need to represent a timestamp typically
choose a specific tag and further constrain its use where necessary
(e.g., tag 1001 was designed to cover a wide variety of applications
{{-tag1001}}).
Where no tag is available, the application protocol can design its own
format for some application data.
Even where a tag is available, the application data can choose to use
its definitions without actually encoding the tag (e.g., by using its
content in specific places in an "unwrapped" form).

Another source of application layer variability comes from the variety
of number types CBOR offers.
For instance, the number 2 can be represented as an integer, float,
big number, decimal fraction and other.
Most protocols designs will just specify one number type to use, and
that will give determinism, but here’s an example specification that
doesn’t:


<aside markdown="1">
For instance, CWT {{-cwt}} defines an application data type "NumericDate" which
(as an application-level rule) is formed by "unwrapping" tag 1 (see
{{Sections 2 and 5 of -cwt}}).
CWT does stop short of using deterministic encoding.
A hypothetical deterministic variant of CWT would need to make an
additional ALDR rule for NumericDate, as
the definition of tag 1 allows both integer and floating point numbers
({{Section 3.4.2 of RFC8949@-cbor}}), which allows multiple
application-level representations of integral numbers.
These application rules may choose to only ever use integers, or to always
use integers when the numeric value can be represented as such without
loss of information, or to always use floating point numbers, or some
of these for some application data and different ones for other
application data.
</aside>

Applications that require Deterministic Representation, and that
derive CBOR data items from application data without maintaining a
record of which choices are to be made when representing these
application data, generally make rules for these choices as part of
the application protocol.
In this document, we speak about these choices as Application-level
Deterministic Representation Rules (ALDR rules for short).

<aside markdown="1">
As an example, {{-thumb}} is intended to derive a (deterministic)
thumbprint from a COSE key {{-cose}}.
{{Section 4 of -thumb}} provides the rules that are used to construct a
deterministic application-level representation (ALDR rules).
Only certain data from a COSE key are selected to be included in that
ALDR, and, where the COSE can choose multiple representations of
semantically equivalent application data, the ALDR rules choose one of
them, potentially requiring a conversion ({{Section 4.2 of -thumb}}):

{:quote}
>  Note: \[{{RFC9052}}] supports both compressed and uncompressed point
   representations.  For interoperability, implementations adhering to
   this specification MUST use the uncompressed point representation.
   Therefore, the y-coordinate is expressed as a bstr.  If an
   implementation uses the compressed point representation, it MUST
   first convert it to the uncompressed form for the purpose of
   thumbprint calculation.
</aside>

CDE provides for encoding commonality between different applications
of CBOR once these application-level choices have been made.
It can be useful for an application or a group of applications to
document their choices aimed at deterministic representation of
application data in a general way, constraining the set of data items
handled (_exclusions_, e.g., no compressed point representations) and
defining further mappings (_reductions_, e.g., conversions to
uncompressed form)
that help the application(s) get by with the exclusions.
This can be done in the application protocol specification (as in
{{-thumb}}) or as a separate document.

<aside markdown="1">
An early example of a separate document is the dCBOR specification
{{-dcbor}}.
dCBOR specifies the use of CDE together with some application-level
rules, i.e., an ALDR ruleset, such as a requirement for all text
strings to be in Unicode Normalization Form C (NFC) {{UAX-15}} — this
specific requirement is an example for an _exclusion_ of non-NFC data
at the application level, and it invites implementing a _reduction_ by
routine normalization of text strings.
</aside>

ALDR rules (including rules specified in a ALDR ruleset document) enable
simply using implementations of the common CDE; they do not
"fork" CBOR in the sense of requiring distinct generic encoder/decoder
implementations for each application.

An implementation of specific ALDR rules combined with a CDE
implementation produces well-formed,
deterministically encoded CBOR according to {{STD94}}, and existing
generic CBOR decoders will therefore be able to decode it, including
those that check for Deterministic Encoding ("CDE-checking decoders", see also
{{impcheck}}).
Similarly, generic CBOR encoders will be able to produce valid CBOR
that can be ingested by an implementation that enforces an application's
ALDR rules if the encoder was handed data model level information
from an application that simply conformed to those ALDR rules.

Please note that the separation between standard CBOR processing and
the processing required by the ALDR rules is a conceptual one:
Instead of employing generic encoders/decoders, both ALDR rule
processing and standard CBOR processing can be combined into a specialized
encoder/decoder specifically designed for a particular set of ALDR
rules.

ALDR rules are intended to be used in conjunction with an
application, which typically will naturally use a subset of the CBOR generic
data model, which in turn
influences which subset of the ALDR rules is used by the specific application
(in particular if the application simply references a more general
ALDR ruleset document).
As a result, ALDR rules themselves place no direct
requirement on what minimum subset of CBOR is implemented.
For instance, a set of ALDR rules might include rules for the
processing of floating point values, but there is no requirement that
implementations of that set of ALDR rules support floating point
numbers (or any other kind of number, such as arbitrary precision
integers or 64-bit negative integers) when they are used with
applications that do not use them.

# Implementers' Checklists {#impcheck}

This appendix is informative.
It provides brief checklists that implementers can use to check their
implementations.
It uses {{RFC2119}} language, specifically the keyword MUST, to highlight
the specific items that implementers may want to check.
It does not contain any normative mandates.
This appendix is informative.

Notes:

* This is largely a restatement of parts of {{Section 4 of
  RFC8949@-cbor}}.
  The purpose of the restatement is to aid the work of implementers,
  not to redefine anything.

  Preferred Serialization Encoders as well as CDE
  Encoders and CDE-checking Decoders have certain properties that are expressed
  using {{RFC2119}} keywords in this appendix.

* Duplicate map keys are never valid in CBOR at all (see
  list item "Major type 5" in {{Section 3.1 of RFC8949@-cbor}})
  no matter what sort of serialization is used.
  Of the various strategies listed in {{Section 5.6 of RFC8949@-cbor}},
  detecting duplicates and handling them as an error instead of
  passing invalid data to the application is the most robust one;
  achieving this level of robustness is a mark of quality of
  implementation.

* Preferred serialization and CDE only affect serialization.
  They do not place any requirements, exclusions, mappings or such on
  the data model level.
  ALDR rules such as the ALDR ruleset defined by dCBOR are different as they can affect
  the data model by restricting some values and ranges.

* CBOR decoders in general (as opposed to "CDE-checking decoders" specifically
  advertised as supporting CDE)
  are not required to check for preferred
  serialization or CDE and reject inputs that do not fulfill
  these requirements.
  However, in an environment that employs deterministic encoding,
  employing non-checking CBOR decoders negates many of its benefits.
  Decoder implementations that advertise "support" for preferred
  serialization or CDE need to check the encoding and reject
  input that is not encoded to the encoding specification in use.
  Again, ALDR rules such as those in dCBOR may pose additional
  requirements, such as requiring rejection of non-conforming inputs.

  If a generic decoder needs to be used that does not "support" CDE, a
  simple (but somewhat clumsy) way to check its input for proper CDE encoding is
  to re-encode the decoded data with CDE and check for bit-to-bit equality with
  the original input.

## Preferred Serialization {#ps}

In the following, the abbreviation "ai" will be used for the 5-bit
additional information field in the first byte of an encoded CBOR data
item, which follows the 3-bit field for the major type.

### Preferred Serialization Encoders {#pse}

1. Shortest-form encoding of the argument MUST be used for all major
   types (`shortest-head` constraint).
   Major type 7 is used for floating-point and simple values; floating
   point values have its specific rules for how the shortest form is
   derived for the argument.
   The shortest form encoding for any argument that is not a floating
   point value is:

   * 0 to 23 and -1 to -24 MUST be encoded in the same byte as the
     major type.
   * 24 to 255 and -25 to -256 MUST be encoded only with one additional
     byte (ai = 0x18).
   * 256 to 65535 and -257 to -65536 MUST be encoded only with an
     additional two bytes (ai = 0x19).
   * 65536 to 4294967295 and -65537 to -4294967296 MUST be encoded
     only with an additional four bytes (ai = 0x1a).

2. If floating-point numbers are emitted, the following apply:

   * The length of the argument indicates half (binary16, ai = 0x19),
     single (binary32, ai = 0x1a) and double (binary64, ai = 0x1b)
     precision encoding.
     If multiple of these encodings preserve the precision of the
     value to be encoded, only the shortest form of these MUST be
     emitted.
     That is, encoders MUST support half-precision and
     single-precision floating point.

   * {{IEEE754}} Infinites and NaNs, and thus NaN payloads, MUST be
     supported, to the extent possible on the platform.

     As with all floating point numbers, Infinites and NaNs MUST be
     encoded in the shortest of double, single or half precision that
     preserves the value:

     * Positive and negative infinity and zero MUST be represented in
       half-precision floating point.

     * For NaNs, the value to be preserved includes the sign bit,
     the quiet bit, and the NaN payload (whether zero or non-zero).
     The shortest form is obtained by removing the rightmost N bits of the
     payload, where N is the difference in the number of bits in the
     significand (mantissa representation) between the original format
     and the shortest format.
     This trimming is performed only (preserves the value only) if all the
     rightmost bits removed are zero.
     (This means that a double or single quiet NaN that has a zero
     NaN payload will always be represented in a half-precision quiet NaN.)

3. If tags 2 and 3 are supported, the following apply:

   * Positive integers from 0 to 2^64 - 1 MUST be encoded as a type 0 integer.

   * Negative integers from -(2^64) to -1 MUST be encoded as a type 1 integer.

   * Leading zeros MUST NOT be present in the byte string content of tag 2 and 3.

   (This also applies to the use of tags 2 and 3 within other tags,
   such as 4 or 5.)

### Decoders and Preferred Serialization {#psd}

There are no special requirements that CBOR decoders need to meet to
be what could be called a "Preferred Serialization Decoder".

Partial decoder implementations that want to accept at least Preferred
Serialization need to pay attention to at least the
following requirements:

1. Decoders MUST accept shortest-form encoded arguments (see {{Section
   3 of RFC8949@-cbor}}).

2. {:#arraymap-indef} If arrays or maps are supported, both definite-length and indefinite-length arrays or maps MUST be accepted.

3. {:#string-indef} If text or byte strings are supported, both definite-length and indefinite-length text or byte
   strings MUST be accepted.

4. If floating-point numbers are supported, the following apply:

   * Half-precision values MUST be accepted.
   * Double- and single-precision values SHOULD be accepted; leaving these out
     is only foreseen for decoders that need to work in exceptionally
     constrained environments.
   * If double-precision values are accepted, single-precision values
     MUST be accepted.
   * Infinites and NaNs, and thus NaN payloads, MUST be accepted and
     presented to the application (not necessarily in the platform
     number format, if that doesn't support those values).

5. If big numbers (tags 2 and 3) are supported, type 0 and type 1 integers MUST
   be accepted where a tag 2 or 3 would be accepted.  Leading zero bytes
   in the tag content of a tag 2 or 3 MUST be ignored.

## `definite-length-only` {#bs}

The encoding constraint `definite-length-only` excludes the use of
indefinite length encoding, both for (binary/text) strings and for
arrays and maps.
A CBOR encoder can choose to employ this encoding constraint in order to
reduce the variability that needs to be handled by decoders,
potentially maximizing interoperability with partial (e.g.,
constrained) CBOR decoder implementations.
A popular partial implementation of a CBOR decoder would be to not
support indefinite length encoding, requiring the encoder to implement
`definite-length-only` encoding.

{:aside}
>
Some encoders turn to indefinite length encoding for arrays and maps
with 256 or more elements/entries, to use the slightly smaller
serialization size indefinite length encoding offers for these cases.
Since leaving out support for indefinite length encoding is a common
form of partial implementation, this may reduce interoperability.
(Indefinite length encoding may also be used conditionally to avoid
having to compute the total size ahead of time if the platform uses
some form of chunking.)
As CDE requires `definite-length-only`, such behavior needs to be
turned off for CDE.

## CDE

### CDE Encoders

1. CDE encoders MUST only emit CBOR that fulfills the encoding
   constraints `preferred-serialization` and `definite-length-only`.

2. CDE encoders MUST only emit CBOR that fulfills the encoding
   constraints `lexicographic-map-sorting`, i.e.,
   sort maps by the CBOR representation of the map key.
   The sorting is byte-wise lexicographic order of the encoded map
   key data items.

3. CDE encoders MUST generate CBOR that fulfills basic validity
   ({{Section 5.3.1 of RFC8949@-cbor}}).  Note that this includes not
   emitting duplicate keys in a major type 5 map as well as emitting
   only valid UTF-8 in major type 3 text strings.

   Note also that CDE does NOT include a requirement for Unicode
   normalization {{UAX-15}}; {{Section C of
   ?I-D.bormann-dispatch-modern-network-unicode}} contains some
   rationale that went into not requiring routine use of Unicode normalization
   processes.

### CDE-checking Decoders

The term "CDE-checking Decoder" is a shorthand for a CBOR decoder that
advertises _supporting_ CDE (see the start of this appendix).

1. CDE-checking decoders MUST check the input for
   keeping the `preferred-serialization` and `definite-length-only`
   encoding constraints.

2. CDE-checking decoders MUST check the input for keeping the
   `lexicographic-map-sorting` encoding constraints, i.e., they need
   to check for strict ordering of map (major type 5) entries by
   lexicographically comparing their keys (including rejecting
   duplicate map keys).

3. To complete checking for basic validity of the CBOR encoding (see
   {{Section 5.3.1 of RFC8949@-cbor}}, CDE-checking decoders MUST check
   the validity of the UTF-8 encoding of text strings (major type 3).

To be called a CDE-checking decoder, it MUST NOT present to the application
a decoded data item that fails one of these checks (except maybe via
special diagnostic channels with no potential for confusion with a
correctly CDE-decoded data item).

# Encoding Examples {#examples}

The following three tables provide examples of CDE-encoded CBOR data
items, each giving Diagnostic Notation (EDN {{-edn}}), the encoded data
item in hexadecimal, and a comment:

* The comments use f16, f32, and f64 as abbreviations for 16-bit float
(half precision, C language `_Float16`), 32-bit float (single
precision, C language `_Float32`, fits in `float`), and 64-bit float
(double precision, C language `_Float64`, fits in `double`),
respectively, as well as qNaN for quiet NaN and sNaN for signaling
NaN.

* As there is no established EDN for notating NaNs with non-zero
payloads at the time of writing, this table uses `float'hex'`, where
hex is a hexadecimal representation of the IEEE 754 interchange format
for the NaN value.

Implementers that want to use these examples as test input may be
interested in the file `example-table-input.csv` in the github
repository `cbor-wg/draft-ietf-cbor-cde`.

{::include example-tables.md}

# Examples for Preferred Serialization of Integers {#exa-pref}

This appendix looks at the set of encoded CBOR data items that
represent the integer number `1`.
Preferred Serialization chooses one of them (`0x01`), which is then
always used to encode the number.
The CDE encoding constraints include those of preferred serialization.
A CDE-checking decoder checks that no other serialization is being
used in the encoded data item being decoded.

<?v3xml2rfc table_borders="full" ?>

| Serialization of integer number 1                    | Preferred?                             |
| 0x01                                                 | yes (shortest mt0)                     |
| 0x1801, 0x190001, 0x1a00000001, 0x1b0000000000000001 | no (mt0, but not shortest argument)    |
| 0xc24101                                             | no (could use mt0)                     |
| 0xc2420001, 0xc243000001, etc.                       | no (could use mt0, uses leading zeros) |
| 0xc25f41004101ff, and similar                        | no (could use mt0, uses leading zeros) |
{: #tbl-ser-1 title="Serializations of integer number 1"}

For the integer number 100000000000000000000 (1 with 20 decimal
zeros), the only serialization that meets the
`preferred-serialization` and `definite-length-only` constraints is:

~~~
C2                       # tag(2)
   49                    # bytes(9)
      056BC75E2D63100000 #
~~~

(Note that, in addition to this serialization, there are multiple
serializations that would also count as *preferred* serializations, as
the preferred serialization constraint by itself does not exclude
indefinite length encoding of the byte string that is the content of
tag 2.)

# Example Code for Encoding into 16-bit Floating Point {#encode-f16}

{{Appendix D (Half-Precision) of RFC8949@-cbor}} provides example C and
Python code for decoding 16-bit ("Half Precision", binary16) floating point
numbers.
Providing this code was considered important at the time to aid in
the creation of generic decoders.

Given that CDE implementations that support floating point Numbers not
only need to decode, but also to encode their 16-bit format, this
appendix provides example C code to convert a floating point number
that is in 64-bit form ("Double Precision", binary64) into binary16.

If such a conversion is not possible (i.e., there is no 16-bit
representation for the 64-bit value given), the function
`try_float16_encode` returns `-1`.
Otherwise it returns a two-byte integer (range `0x0000` to `0xFFFF`)
that, prefixed with `0xF9`, is suitable to encode the value.

~~~ c
{::include half-encode.c}
~~~
{: #half-encode title="Example C Code for a Half-Precision Encoder"}


{::include-all cde-lists.md}

# Acknowledgments
{:numbered="false"}

An early version of this document was based on the work of {{{Wolf
McNally}}} and {{{Christopher Allen}}} as documented in {{-dcbor}}, which
serves as an example for an ALDR ruleset document.
We would like to explicitly acknowledge that this work has
contributed greatly to shaping the concept of a CBOR Common
Deterministic Encoding and the use of ALDR rules/rulesets on top of that.
{{{Mikolai Gütschow}}} proposed adding {{choi}}.
{{{Anders Rundgren}}} provided most of the initial text that turned into
{{examples}}, {{{Laurence Lundblade}}} provided examples for "NaN" (not a
number) floating point values.
