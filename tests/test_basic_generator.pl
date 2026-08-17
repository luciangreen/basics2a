% test_basic_generator.pl — Tests for BASIC code generation

:- use_module(library(plunit)).
:- use_module('../basic_generator').

:- begin_tests(basic_generator).

test(generate_swap) :-
    IR = algorithm(swap, list(2), list(2),
                   [copy([2],[1]), copy([1],[2])]),
    basic_generate(IR, Source),
    sub_atom(Source, _, _, _, 'Output(1) = Input(2)'),
    sub_atom(Source, _, _, _, 'Output(2) = Input(1)').

test(generate_identity) :-
    IR = algorithm(identity, scalar, scalar,
                   [copy([],[])]),
    basic_generate(IR, Source),
    sub_atom(Source, _, _, _, 'Output = Input').

test(generate_constant) :-
    IR = algorithm(answer, list(1), list(2),
                   [constant([1], answer), copy([1],[2])]),
    basic_generate(IR, Source),
    sub_atom(Source, _, _, _, 'Output(1) = "answer"'),
    sub_atom(Source, _, _, _, 'Output(2) = Input(1)').

test(generate_sub_header) :-
    IR = algorithm(swap, list(2), list(2), []),
    basic_generate(IR, Source),
    sub_atom(Source, _, _, _, 'SUB SWAP(Input(), Output())').

test(generate_end_sub) :-
    IR = algorithm(swap, list(2), list(2), []),
    basic_generate(IR, Source),
    sub_atom(Source, _, _, _, 'END SUB').

:- end_tests(basic_generator).

:- run_tests(basic_generator).
