# BASIC Spec to Algorithm — implementation status

This document records the features currently implemented, their boundaries,
and planned follow-up work. `README.md` contains API usage and runnable
commands.

## Implemented

| Area | Behavior |
|------|----------|
| Public API | `spec_to_basic/3`, `spec_to_basic/4`, and `spec_to_basic_report/2` |
| Specification formats | Simple `Input-Output` pairs, one-pair nested lists, and structured `input`/`output` terms |
| Inference | Positional structural generalisation and input/output address correspondence |
| Values | Scalars, lists, nested lists, atoms, strings, numbers, and mixed terms |
| Transformations | Copy, reorder, duplicate, omit, and output constants |
| Character preprocessing | Optional Prolog-side atom/string character decomposition via `chars(on)` |
| Intermediate representation | `algorithm(Name, InputShape, OutputShape, Instructions)` with `copy/2` and `constant/2` instructions |
| Source generation | Generic BASIC-like `SUB`/`END SUB` source, scalar assignments, array references, and constants |
| Verification | Executes the IR against the training examples by default; `verify(off)` disables it |
| Reporting and errors | Structured synthesis report, malformed/empty input errors, conflicting correspondence errors, and verification errors |

The accepted options are `chars(off)` (default), `chars(on)`,
`dialect(generic)` (default), `verify(on)` (default), and `verify(off)`.
Character decomposition changes the Prolog terms used for inference; generated
source continues to use the generic array convention and does not reconstruct
a BASIC string.

## Not implemented

| Feature | Status |
|---------|--------|
| Arithmetic or conditional rule inference | Not implemented; synthesis is positional |
| Native BASIC string input/output and recombination | Not implemented |
| Non-generic BASIC dialects | Not implemented |
| Declarations, array allocation, main program, or runtime integration | Not generated |
| Parallel execution | Not implemented |
| Other Spec-to-Algorithm projects (Starlog, Loop2, PLOP, Detlog, Piglog2) | Outside this repository's scope |

Shape-changing or sparsely demonstrated examples may not generalise as
intended. Generated BASIC source is validated as text and its IR is tested
against the provided examples; no external BASIC compiler/runtime is used.

## Intermediate representation and errors

| Term | Meaning |
|------|---------|
| `copy(InputAddr, OutputAddr)` | Copy the input value at an address to an output address |
| `constant(OutputAddr, Value)` | Put a fixed value at an output address |
| `error(no_specs)` | No examples were supplied |
| `error(malformed_spec(Spec))` | A specification does not match an accepted form |
| `error(conflicting_specifications(Input, Out1, Out2))` | Conflicting outputs were inferred for an input |
| `error(verification_failed(Result))` | The generated IR did not reproduce the training examples |

## Tests

Run all suites from the repository root with `./tests/run_tests.sh`. The
individual PlUnit files under `tests/` cover addresses, generalisation,
character decomposition, source generation, and end-to-end synthesis.
