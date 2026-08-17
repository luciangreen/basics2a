% test_chars.pl — Tests for character decomposition

:- use_module(library(plunit)).
:- use_module('../chars').

:- begin_tests(chars).

test(decompose_atom) :-
    decompose_chars_spec(in(ab)-out(ba), in([a,b])-out([b,a])).

test(decompose_list) :-
    decompose_chars_spec(in([ab,cd])-out([cd,ab]), in([[a,b],[c,d]])-out([[c,d],[a,b]])).

test(recompose) :-
    recompose_chars([h,i], Atom),
    Atom = hi.

test(decompose_chars_spec) :-
    decompose_chars_spec(in(ab)-out(ba), in([a,b])-out([b,a])).

:- end_tests(chars).

:- run_tests(chars).
