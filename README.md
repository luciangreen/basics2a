# BASIC Spec to Algorithm

A SWI-Prolog program that accepts multiple input/output specification examples,
discovers the common structural transformation, and generates a BASIC program
implementing that transformation.

This is the BASIC-language counterpart of
[Spec to Algorithm](https://github.com/luciangreen/listprologinterpreter):
given examples, it **infers** an algorithm rather than optimising one already
written.

---

## What is Spec to Algorithm?

*Spec to Algorithm* (S2A) is the approach of inferring an executable algorithm
from a set of input/output pairs.  Given:

```
[1,2] → [2,1]
[3,4] → [4,3]
```

the system observes that position 1 of the input maps to position 2 of the
output and vice versa, generalises this to a structural rule, and generates:

```basic
SUB SWAP(Input(), Output())
    Output(1) = Input(2)
    Output(2) = Input(1)
END SUB
```

The defining capability is:

```
examples → structural pattern → input/output address relationships → BASIC algorithm
```

---

## Features

- Infers algorithms from multiple input/output examples
- Handles lists, nested lists, scalars, atoms, numbers, strings, mixed data
- Discovers copied values, duplicated values, omitted values, output constants
- Optional character-level decomposition (`chars(on)`) for string/atom reversal
- Generates readable generic BASIC (`SUB ... END SUB` calling convention)
- Verifies generated algorithm against all training examples
- Structured error reporting

---

## Installation

Requires [SWI-Prolog](https://www.swi-prolog.org/) 9.0.4 or newer.

Clone or download the repository, then load in SWI-Prolog:

```sh
cd basics2a
swipl
```

```prolog
?- [basic_s2a].
```

Scripts can load the API with `use_module(basic_s2a)`.

---

## Public Predicates

### `spec_to_basic(+Name, +Specs, -Basic)`

Synthesise a BASIC algorithm named `Name` from examples `Specs`.
Uses default options: `chars(off)`, `dialect(generic)`, `verify(on)`.

### `spec_to_basic(+Name, +Specs, +Options, -Basic)`

As above with explicit options.  Supported options:

| Option            | Meaning |
|-------------------|---------|
| `chars(off)`      | Treat atoms/strings as atomic (default) |
| `chars(on)`       | Decompose atoms/strings into character lists |
| `dialect(generic)`| Generic portable BASIC output (default) |
| `verify(on)`      | Verify generated algorithm against examples (default) |
| `verify(off)`     | Skip verification |

### `spec_to_basic_report(+Specs, -Report)`

Returns the example count, generalised input/output patterns, input-to-output
address mappings, output constants, and whether the inferred IR reproduced
the training examples.

```prolog
?- spec_to_basic_report([[1,2]-[2,1],[3,4]-[4,3]], Report).
```

The report has the form
`report(examples(N), input_pattern(IP), output_pattern(OP), mappings(Maps),
constants(Constants), verification(Status))`. Each mapping is an
input-address/output-address pair; constants are output-address/value pairs.
Verification is `passed` or `unverified`.

---

## Specification Syntax

### Simple form

```prolog
[Input1-Output1, Input2-Output2, ...]
```

### Nested simple form

```prolog
[[Input1-Output1], [Input2-Output2], ...]
```

### Structured form (original S2A style)

```prolog
[
  [[input, InputTerm1], [output, OutputTerm1]],
  [[input, InputTerm2], [output, OutputTerm2]],
  ...
]
```

---

## Examples

### Swap

```prolog
?- spec_to_basic(swap,
       [ [1,2]-[2,1],
         [3,4]-[4,3],
         [5,6]-[6,5]
       ],
       Basic),
   writeln(Basic).
```

Output:

```basic
SUB SWAP(Input(), Output())
    Output(2) = Input(1)
    Output(1) = Input(2)
END SUB
```

### Nested Structures

```prolog
?- spec_to_basic(extract,
       [ [[1,2],[3,4]]-[4,1],
         [[5,6],[7,8]]-[8,5]
       ],
       Basic),
   writeln(Basic).
```

### Output Constants

```prolog
?- spec_to_basic(label,
       [ [1]-[answer,1],
         [2]-[answer,2],
         [3]-[answer,3]
       ],
       Basic),
   writeln(Basic).
```

Output:

```basic
SUB LABEL(Input(), Output())
    Output(1) = "answer"
    Output(2) = Input(1)
END SUB
```

### Character Reversal

```prolog
?- spec_to_basic(reverse_two,
       [ab-ba, cd-dc, ef-fe],
       [chars(on)],
       Basic),
   writeln(Basic).
```

Output:

```basic
SUB REVERSE_TWO(Input(), Output())
    Output(1) = Input(2)
    Output(2) = Input(1)
END SUB
```

### Structured Input Form (S2A style)

```prolog
?- spec_to_basic(swap,
       [ [[input,[1,2]],[output,[2,1]]],
         [[input,[3,4]],[output,[4,3]]],
         [[input,[5,6]],[output,[6,5]]]
       ],
       [chars(off),dialect(generic),verify(on)],
       Basic),
   writeln(Basic).
```

---

## Verification

By default (`verify(on)`), the generated algorithm is executed against every
training example and must reproduce the expected output.  If verification fails:

```
error(verification_failed(failed([...])))
```

Turn off with `verify(off)`.

---

## Running Tests

Run all PlUnit suites from the repository root:

```sh
./tests/run_tests.sh
```

SWI-Prolog must be available on `PATH`. To run one suite, for example:
`swipl -q -s tests/test_basic_s2a.pl -g "(run_tests(basic_s2a) -> halt(0) ; halt(1))"`.
Other suite names are `addresses`, `generalise`, `chars`, and
`basic_generator`. Tests cover parsing/addressing, generalisation,
correspondence, character decomposition, IR verification, reports, and BASIC
source generation. They assert generated source text; they do not compile or
execute it in a BASIC runtime.

---

## Running Examples

```sh
swipl -q -s examples/swap.pl
swipl -q -s examples/nested.pl
swipl -q -s examples/constants.pl
swipl -q -s examples/strings.pl
```

---

## Generated BASIC Dialect

The `dialect(generic)` backend emits a portable BASIC-like subroutine using:

- `SUB Name(Input(), Output())` — array arguments
- `Output(N) = Input(M)` — array element assignment
- `Output(N) = "string"` — string constant
- `END SUB`

Scalar examples use `SUB Name(Input, Output)` and `Output = Input`. Nested
addresses are emitted as multidimensional references. The backend emits
address assignments only; it does not emit declarations, allocation, runtime
support, or a program that invokes the generated subroutine.

`chars(on)` decomposes atoms and strings into character terms before inference.
Generated code still uses the generic array-argument convention (for example
`Input(1)`); it does not generate BASIC string expressions or reconstruct a
scalar string.

---

## Limitations

- Structural pattern discovery is positional (address-based); it does not
  discover arithmetic or conditional relationships.
- Character mode performs Prolog-side decomposition, but native BASIC string
  handling and string recombination are not implemented.
- Only `dialect(generic)` is implemented. Dialect-specific declarations,
  allocation, and executable program scaffolding are not generated.
- Input and output structures are inferred positionally; incompatible shapes
  or insufficient evidence may not generalise as intended.
- Parallel execution is not generated (sequential BASIC only).

## Remaining work

The positional synthesis pipeline and generic source emitter are implemented.
Useful follow-on features include native BASIC string input/output and
recombination, additional dialect backends, shape/size declarations and
executable program scaffolding, stronger handling of shape-changing examples,
and arithmetic or conditional rule inference. These are not currently
implemented or promised by the public API.

---

## Architecture

```
basic_s2a.pl        — Public API
spec_parser.pl      — Normalise specification forms
addresses.pl        — Subterm addressing ([1], [2,1], ...)
generalise.pl       — Structural generalisation across examples
correspondence.pl   — Discover input→output address mappings
pattern.pl          — Input/output shape characterisation
algorithm_ir.pl     — Intermediate representation (copy/constant)
basic_generator.pl  — Emit BASIC source from IR
basic_verify.pl     — Verify IR against examples
chars.pl            — Character decomposition/recombination
```

---

## Relationship to Spec to Algorithm

This project implements the *Spec to Algorithm* synthesis concept for the BASIC
target language.  The core pipeline — examples → structural pattern → address
relationships → executable algorithm — is the same as the original S2A
approach.

It does **not** implement Starlog (syntax transformation), Loop2 (findall
elimination), PLOP (optimisation), Detlog (deterministic compilation), or
Piglog2 (parallelisation).
