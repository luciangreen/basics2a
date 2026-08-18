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

Requires [SWI-Prolog](https://www.swi-prolog.org/) (tested with 9.0.4).

Clone or download the repository, then load in SWI-Prolog:

```sh
cd basics2a
swipl
```

```prolog
?- [basic_s2a].
```

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

Returns a structured report explaining why the transformation was inferred.

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
       [ [[input,[['A',[1,2]]]],[output,[['B',[2,1]]]]],
         [[input,[['A',[3,4]]]],[output,[['B',[4,3]]]]],
         [[input,[['A',[5,6]]]],[output,[['B',[6,5]]]]]
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

```sh
cd tests
swipl -g "halt(0)" -l test_basic_s2a.pl
swipl -g "halt(0)" -l test_addresses.pl
swipl -g "halt(0)" -l test_generalise.pl
swipl -g "halt(0)" -l test_chars.pl
swipl -g "halt(0)" -l test_basic_generator.pl
```

---

## Running Examples

```sh
swipl -g "halt(0)" -l examples/swap.pl
swipl -g "halt(0)" -l examples/nested.pl
swipl -g "halt(0)" -l examples/constants.pl
swipl -g "halt(0)" -l examples/strings.pl
```

---

## Generated BASIC Dialect

The `dialect(generic)` backend produces portable BASIC using:

- `SUB Name(Input(), Output())` — array arguments
- `Output(N) = Input(M)` — array element assignment
- `Output(N) = "string"` — string constant
- `END SUB`

String operations (used internally when `chars(on)` is active):

| Operation | Meaning |
|-----------|---------|
| `MID$(s$, start, len)` | Extract substring |
| `LEN(s$)` | String length |
| `+` | String concatenation |

---

## Limitations

- Structural pattern discovery is positional (address-based); it does not
  discover arithmetic or conditional relationships.
- Character mode (`chars(on)`) works on top-level atoms/strings; deeply nested
  string manipulation is not yet supported.
- Only the `dialect(generic)` backend is implemented in v1.
- Parallel execution is not generated (sequential BASIC only).

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
