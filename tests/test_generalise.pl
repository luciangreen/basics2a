% test_generalise.pl — Tests for structural generalisation

:- use_module(library(plunit)).
:- use_module('../generalise').
:- use_module('../spec_parser').

:- begin_tests(generalise).

test(find_constants_swap) :-
    find_constants([[1,2],[3,4],[5,6]], Const, Var),
    Const = [],
    msort(Var, SV),
    msort([[1],[2]], SV).

test(find_constants_constant_prefix) :-
    find_constants([[a,1],[a,2],[a,3]], Const, Var),
    member([1], Const),
    member([2], Var).

test(generalise_terms_swap) :-
    generalise_terms([[1,2],[3,4]], Pattern, _VarPos),
    Pattern = [var(_),var(_)].

test(generalise_specs_swap) :-
    normalise_specs([[1,2]-[2,1],[3,4]-[4,3]], NS),
    generalise_specs(NS, generalised(IP, OP, _)),
    IP = [var(_),var(_)],
    OP = [var(_),var(_)].

test(generalise_specs_constant) :-
    normalise_specs([[1]-[answer,1],[2]-[answer,2]], NS),
    generalise_specs(NS, generalised(_IP, OP, _)),
    OP = [answer, var(_)].

:- end_tests(generalise).

:- run_tests(generalise).
