% correspondence.pl — Discover input→output address mappings

:- module(correspondence, [
    discover_correspondences/3,
    discover_variables/3
]).

:- use_module(addresses).
:- use_module(generalise).

% discover_correspondences(+NormSpecs, +Options, -Correspondences)
% Correspondences = list of:
%   copy(InputAddr, OutputAddr)
%   constant(OutputAddr, Value)
discover_correspondences(Specs, Options, Correspondences) :-
    ( Specs = [] -> throw(error(no_specs)) ; true ),
    check_conflicts(Specs),
    pairs_keys_values(Specs, InWrapped, OutWrapped),
    unwrap_ins(InWrapped, Inputs),
    unwrap_outs(OutWrapped, Outputs),
    ( member(chars(on), Options) ->
        maplist(decompose_chars, Inputs, CInputs),
        maplist(decompose_chars, Outputs, COutputs)
    ;
        CInputs = Inputs,
        COutputs = Outputs
    ),
    find_output_leaf_addresses(COutputs, OLeafAddrs),
    find_input_leaf_addresses(CInputs, ILeafAddrs),
    maplist(classify_output_addr(CInputs, COutputs, ILeafAddrs),
            OLeafAddrs, Correspondences).

find_output_leaf_addresses([First|_], Addrs) :-
    leaf_addresses(First, Addrs).

find_input_leaf_addresses([First|_], Addrs) :-
    leaf_addresses(First, Addrs).

classify_output_addr(Inputs, Outputs, ILeafAddrs, OAddr, Corr) :-
    maplist(addr_value(OAddr), Outputs, OVals),
    ( all_same(OVals) ->
        % constant in output
        OVals = [ConstVal|_],
        Corr = constant(OAddr, ConstVal)
    ;
        % varying — find matching input address
        ( member(IAddr, ILeafAddrs),
          maplist(addr_value(IAddr), Inputs, OVals)
        ->
            Corr = copy(IAddr, OAddr)
        ;
            Corr = unresolved(OAddr)
        )
    ).

addr_value(Addr, Term, Val) :- address_value(Addr, Term, Val).

all_same([]).
all_same([_]).
all_same([X,X|T]) :- all_same([X|T]).

% check_conflicts(+NormSpecs)
check_conflicts(Specs) :-
    pairs_keys_values(Specs, InWrapped, OutWrapped),
    unwrap_ins(InWrapped, Inputs),
    unwrap_outs(OutWrapped, Outputs),
    pairs_keys_values(IOPairs, Inputs, Outputs),
    check_pairs_conflict(IOPairs).

check_pairs_conflict([]).
check_pairs_conflict([I-O1|Rest]) :-
    ( member(I-O2, Rest), O1 \= O2 ->
        throw(error(conflicting_specifications(I, O1, O2)))
    ; true ),
    check_pairs_conflict(Rest).

unwrap_ins([], []).
unwrap_ins([in(X)|T], [X|R]) :- unwrap_ins(T, R).

unwrap_outs([], []).
unwrap_outs([out(X)|T], [X|R]) :- unwrap_outs(T, R).

% discover_variables(+NormSpecs, +Options, -Variables)
% Variables = [var(VarId, InputAddr, OutputAddr)|...]
discover_variables(Specs, Options, Variables) :-
    discover_correspondences(Specs, Options, Corrs),
    include(is_copy, Corrs, Copies),
    maplist(copy_to_var, Copies, Variables).

is_copy(copy(_,_)).
copy_to_var(copy(IA,OA), var(IA,OA)).

% decompose_chars(+Term, -CharTerm)
% Decompose atoms/strings at the top level into character lists if possible.
decompose_chars(Term, Chars) :-
    ( atom(Term) ->
        atom_chars(Term, Chars)
    ; string(Term) ->
        string_chars(Term, Chars)
    ; is_list(Term) ->
        maplist(decompose_chars, Term, Chars)
    ;
        Chars = Term
    ).
