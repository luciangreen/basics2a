% basic_verify.pl — Verify IR against all supplied examples

:- module(basic_verify, [
    verify_algorithm/3,
    verify_specs/2
]).

:- use_module(algorithm_ir).
:- use_module(addresses).

% verify_algorithm(+IR, +NormSpecs, -Result)
% Result = passed | failed(Failures)
verify_algorithm(IR, Specs, Result) :-
    maplist(verify_one(IR), Specs, Results),
    ( include(is_failure, Results, []) ->
        Result = passed
    ;
        include(is_failure, Results, Failures),
        Result = failed(Failures)
    ).

is_failure(failure(_,_,_)).

verify_one(IR, in(Input)-out(Expected), Outcome) :-
    ( catch(execute_ir(IR, Input, Got), E,
            (Outcome = failure(Input, Expected, error(E)), fail)) ->
        ( Got = Expected ->
            Outcome = ok
        ;
            Outcome = failure(Input, Expected, Got)
        )
    ; true ).

% verify_specs(+NormSpecs, +IR)
% Throws if verification fails.
verify_specs(Specs, IR) :-
    verify_algorithm(IR, Specs, Result),
    ( Result = passed -> true
    ;
        throw(error(verification_failed(Result)))
    ).
