# PROGRAM REQUIREMENTS — BASIC Spec to Algorithm

This file records the requirements satisfied by this implementation.

## Implemented Requirements

| Req | Status | Notes |
|-----|--------|-------|
| 1. Project Name | ✓ | basic-spec-to-algorithm, SWI-Prolog |
| 2. Purpose | ✓ | Infer BASIC algorithm from I/O examples |
| 3. Core S2A Principle | ✓ | Infers from examples, not optimises |
| 4. Public API `spec_to_basic/3,4` | ✓ | Implemented |
| 4. Options `chars/dialect/verify` | ✓ | All supported |
| 5. Spec Representation (structured+simple) | ✓ | Both forms accepted |
| 6. Structural Generalisation | ✓ | Constants vs varying positions |
| 7. Variable Discovery | ✓ | Changing positions become variables |
| 8. Subterm Address Correspondence | ✓ | addresses.pl |
| 9. Nested Structures | ✓ | Multi-level addressing |
| 10. Pattern Discovery | ✓ | generalise.pl + correspondence.pl |
| 11. Character-Level Mode | ✓ | `chars(on)` option |
| 12. Character Recombination | ✓ | chars.pl |
| 13. Output Constants | ✓ | `constant(Addr,Val)` instruction |
| 14. Repeated Input Variables | ✓ | Multiple copy instructions to same input addr |
| 15. Omitted Input Components | ✓ | Unused input addresses generate no instructions |
| 16. Generated BASIC | ✓ | SUB/END SUB, readable |
| 17. BASIC Arrays | ✓ | `SUB Name(Input(), Output())` convention |
| 18. Scalar Example | ✓ | `Output = Input` for scalars |
| 19. Reordering Example | ✓ | Swap works |
| 20. Constant and Variable Example | ✓ | `Output(1) = "answer"` |
| 21. Intermediate Representation | ✓ | `algorithm(Name, IShape, OShape, Instructions)` |
| 22. BASIC Backend | ✓ | `basic_generate/2,3` |
| 23. Architecture | ✓ | Matches suggested structure |
| 24. Internal Predicates | ✓ | All required predicates present |
| 25. Verification | ✓ | `verify_algorithm/3` |
| 26. Unseen-Input Tests | ✓ | Tests confirm structural mapping |
| 27. Ambiguous Specifications | ✓ | Structural mappings preferred |
| 28. Insufficient Evidence | ✓ | Warning printed for 1 example |
| 29. Conflicting Specifications | ✓ | `error(conflicting_specifications(...))` |
| 30. Determinism of Synthesis | ✓ | Same specs → same result |
| 31–35. No Starlog/Loop2/PLOP/Detlog/Piglog2 | ✓ | Not implemented |
| 36. Scope Boundary | ✓ | Only synthesis |
| 37. Test Categories | ✓ | All 25 test categories covered |
| 38. End-to-End Query | ✓ | Works |
| 39. Character Example | ✓ | `chars(on)` reversal |
| 40. Reporting | ✓ | `spec_to_basic_report/2` |
| 41. Human Readability | ✓ | Input/Output naming |
| 42. Error Handling | ✓ | Structured error terms |
| 43. README | ✓ | README.md |
| 44. GitHub Agent Workflow | ✓ | Incremental, tested at each stage |
| 45. Implementation Stages | ✓ | All 10 stages completed |
| 46. Acceptance Criterion | ✓ | Swap query works end-to-end |

## Algorithm IR Instructions

| Instruction | Meaning |
|-------------|---------|
| `copy(InputAddr, OutputAddr)` | Copy input value at address to output |
| `constant(OutputAddr, Value)` | Place fixed value at output address |

## Error Terms

| Term | Meaning |
|------|---------|
| `error(no_specs)` | Empty specification list |
| `error(malformed_spec(Spec))` | Spec does not match any accepted form |
| `error(conflicting_specifications(Input, Out1, Out2))` | Same input maps to two outputs |
| `error(verification_failed(Result))` | IR fails on training examples |

## Generated BASIC String Operations

When `chars(on)` is active, the following BASIC string operations may be
referenced:

- `MID$(s$, start, len)` — extract a substring
- `LEN(s$)` — length of string
- `+` — string concatenation
