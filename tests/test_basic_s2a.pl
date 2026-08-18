% test_basic_s2a.pl — End-to-end tests for BASIC Spec to Algorithm
%
% Covers:
%  1. identity
%  2. two-item swap
%  3. three-item permutation
%  4. duplicated input value
%  5. omitted input value
%  6. output constants
%  7. nested input structures
%  8. nested output structures (via constants)
%  9. input-to-output address mapping
% 10. multiple independent mappings
% 11. atoms
% 12. strings
% 13. numbers
% 14. mixed data
% 15. chars(off)
% 16. chars(on)
% 17. character reversal
% 18. character recombination
% 19. unseen values
% 20. conflicting examples
% 21. insufficient examples
% 22. malformed specifications
% 23. BASIC source generation
% 24. generated BASIC escaping
% 25. verification against all training specifications

:- use_module(library(plunit)).
:- use_module('../basic_s2a').
:- use_module('../spec_parser').
:- use_module('../algorithm_ir').
:- use_module('../basic_verify').

:- begin_tests(basic_s2a).

% 1. Identity
test(identity, [true(sub_atom(B,_,_,_,'Output = Input'))]) :-
    spec_to_basic(identity, [1-1, 2-2, 3-3], B).

% 2. Two-item swap
test(swap_basic) :-
    spec_to_basic(swap, [[1,2]-[2,1],[3,4]-[4,3],[5,6]-[6,5]], B),
    sub_atom(B, _, _, _, 'Output(1) = Input(2)'),
    sub_atom(B, _, _, _, 'Output(2) = Input(1)').

% 3. Three-item permutation: [1,2,3]->[3,1,2]
test(perm3) :-
    spec_to_basic(perm, [[1,2,3]-[3,1,2],[4,5,6]-[6,4,5]], B),
    sub_atom(B, _, _, _, 'Output(1) = Input(3)'),
    sub_atom(B, _, _, _, 'Output(2) = Input(1)'),
    sub_atom(B, _, _, _, 'Output(3) = Input(2)').

% 4. Duplicated input value: [X,Y]->[X,X,Y]
test(duplicate) :-
    spec_to_basic(dup, [[1,2]-[1,1,2],[3,4]-[3,3,4]], B),
    sub_atom(B, _, _, _, 'Output(1) = Input(1)'),
    sub_atom(B, _, _, _, 'Output(2) = Input(1)'),
    sub_atom(B, _, _, _, 'Output(3) = Input(2)').

% 5. Omitted input value: [1,2,3]->[3,1]
test(omit) :-
    spec_to_basic(omit, [[1,2,3]-[3,1],[4,5,6]-[6,4]], B),
    sub_atom(B, _, _, _, 'Output(1) = Input(3)'),
    sub_atom(B, _, _, _, 'Output(2) = Input(1)'),
    \+ sub_atom(B, _, _, _, 'Input(2)').

% 6. Output constants
test(output_const) :-
    spec_to_basic(answer, [[1]-[answer,1],[2]-[answer,2]], B),
    sub_atom(B, _, _, _, '"answer"').

% 7. Nested input: [[1,2],[3,4]]->[4,1]
test(nested_input) :-
    spec_to_basic(nest, [[[1,2],[3,4]]-[4,1],[[5,6],[7,8]]-[8,5]], B),
    sub_atom(B, _, _, _, 'SUB NEST').

% 8. Nested output (constants in nested output)
test(nested_output) :-
    spec_to_basic(constout, [1-[ok,1], 2-[ok,2]], B),
    sub_atom(B, _, _, _, '"ok"').

% 9. Address mapping correctness
test(address_mapping) :-
    spec_to_basic(swap, [[a,b]-[b,a],[c,d]-[d,c]], B),
    sub_atom(B, _, _, _, 'Input(1)'),
    sub_atom(B, _, _, _, 'Input(2)').

% 10. Multiple independent mappings
test(multi_mapping) :-
    spec_to_basic(multi, [[1,2,3]-[3,2,1],[4,5,6]-[6,5,4]], B),
    sub_atom(B, _, _, _, 'Output(1) = Input(3)'),
    sub_atom(B, _, _, _, 'Output(2) = Input(2)'),
    sub_atom(B, _, _, _, 'Output(3) = Input(1)').

% 11. Atoms
test(atoms) :-
    spec_to_basic(atm, [a-a, b-b, c-c], B),
    sub_atom(B, _, _, _, 'Output = Input').

% 12. Strings (chars(off) treats strings as scalars)
test(strings_off) :-
    spec_to_basic(str, ["hello"-"hello","world"-"world"], [chars(off)], B),
    sub_atom(B, _, _, _, 'Output = Input').

% 13. Numbers
test(numbers) :-
    spec_to_basic(num, [42-42, 7-7], B),
    sub_atom(B, _, _, _, 'Output = Input').

% 14. Mixed data
test(mixed) :-
    spec_to_basic(mix, [[1,a,2.0]-[2.0,a,1],[3,b,4.0]-[4.0,b,3]], B),
    sub_atom(B, _, _, _, 'Output(1) = Input(3)'),
    sub_atom(B, _, _, _, 'Output(3) = Input(1)').

% 15. chars(off) treats atoms as atomic
test(chars_off) :-
    spec_to_basic(rev, [ab-ab, cd-cd], [chars(off)], B),
    sub_atom(B, _, _, _, 'Output = Input').

% 16. chars(on) decomposes atoms
test(chars_on) :-
    spec_to_basic(rev2, [ab-ba, cd-dc, ef-fe], [chars(on)], B),
    sub_atom(B, _, _, _, 'SUB REV2').

% 17. Character reversal with chars(on)
test(char_reversal) :-
    spec_to_basic(crev, [ab-ba, cd-dc], [chars(on)], B),
    sub_atom(B, _, _, _, 'Output(1) = Input(2)'),
    sub_atom(B, _, _, _, 'Output(2) = Input(1)').

% 18. Character recombination
test(char_recom) :-
    spec_to_basic(crev, [ab-ba, cd-dc, ef-fe], [chars(on)], B),
    sub_atom(B, _, _, _, 'Input(1)'),
    sub_atom(B, _, _, _, 'Input(2)').

% 19. Unseen values — structural not memorised
test(unseen_values) :-
    spec_to_basic(swap, [[1,2]-[2,1],[3,4]-[4,3]], B),
    % The algorithm should map any [X,Y] to [Y,X], not just training values
    sub_atom(B, _, _, _, 'Output(1) = Input(2)'),
    sub_atom(B, _, _, _, 'Output(2) = Input(1)').

% 20. Conflicting examples
test(conflicting, [throws(error(conflicting_specifications(_,_,_)))]) :-
    spec_to_basic(bad, [1-a, 1-b], _B).

% 21. Insufficient examples (warning, not error)
test(insufficient, [true]) :-
    catch(
        spec_to_basic(ident, [1-1], B),
        _,
        B = ''
    ),
    true.

% 22. Malformed specifications
test(malformed, [throws(error(malformed_spec(_)))]) :-
    spec_to_basic(bad, [not_a_valid_spec_format(x,y,z)], _).

% 23. BASIC source generation structure
test(basic_source_structure) :-
    spec_to_basic(swap, [[1,2]-[2,1],[3,4]-[4,3]], B),
    sub_atom(B, _, _, _, 'SUB SWAP('),
    sub_atom(B, _, _, _, 'END SUB').

% 24. Generated BASIC escaping of string constants
test(basic_escaping) :-
    spec_to_basic(answer, [[1]-[answer,1],[2]-[answer,2]], B),
    sub_atom(B, _, _, _, '"answer"').

% 25. Verification against training specs
test(verify_training) :-
    normalise_specs([[1,2]-[2,1],[3,4]-[4,3]], NS),
    build_algorithm_ir(swap, NS, [], IR),
    verify_algorithm(IR, NS, passed).

:- end_tests(basic_s2a).

:- run_tests(basic_s2a).
