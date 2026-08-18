% addresses.pl — Subterm address system
%
% An address is a list of positive integers.
% [] refers to the whole term.
% [1] refers to the first element/argument.
% [2,1] refers to the first element of the second element.

:- module(addresses, [
    term_addresses/2,
    address_value/3,
    set_address_value/4,
    leaf_addresses/2
]).

% term_addresses(+Term, -AddressValuePairs)
% Enumerate all addresses (and their values) in Term, including the term itself.
term_addresses(Term, Pairs) :-
    collect_addresses(Term, [], [], Pairs).

collect_addresses(Term, Addr, Acc, Result) :-
    ( is_list(Term), Term \= [] ->
        length(Term, Len),
        Len > 0,
        enumerate_list_addresses(Term, Addr, 1, Acc, Mid),
        Result = [Addr-Term|Mid]
    ; compound(Term), Term \= (_-_) ->
        Term =.. [_|Args],
        length(Args, Arity),
        enumerate_arg_addresses(Args, 1, Arity, Addr, Acc, Mid),
        Result = [Addr-Term|Mid]
    ;
        Result = [Addr-Term|Acc]
    ).

enumerate_list_addresses([], _, _, Acc, Acc).
enumerate_list_addresses([H|T], BaseAddr, Idx, Acc, Result) :-
    append(BaseAddr, [Idx], ChildAddr),
    collect_addresses(H, ChildAddr, Acc, Mid),
    Next is Idx + 1,
    enumerate_list_addresses(T, BaseAddr, Next, Mid, Result).

enumerate_arg_addresses([], _, _, _, Acc, Acc).
enumerate_arg_addresses([H|T], Idx, _, BaseAddr, Acc, Result) :-
    append(BaseAddr, [Idx], ChildAddr),
    collect_addresses(H, ChildAddr, Acc, Mid),
    Next is Idx + 1,
    enumerate_arg_addresses(T, Next, _, BaseAddr, Mid, Result).

% address_value(+Addr, +Term, -Value)
address_value([], Term, Term) :- !.
address_value([I|Rest], Term, Value) :-
    ( is_list(Term) ->
        nth1(I, Term, Sub)
    ; compound(Term) ->
        arg(I, Term, Sub)
    ),
    address_value(Rest, Sub, Value).

% set_address_value(+Addr, +Term, +Value, -NewTerm)
set_address_value([], _, Value, Value) :- !.
set_address_value([I|Rest], Term, Value, NewTerm) :-
    ( is_list(Term) ->
        nth1(I, Term, OldSub, RestList),
        set_address_value(Rest, OldSub, Value, NewSub),
        nth1(I, NewTerm, NewSub, RestList)
    ; compound(Term) ->
        Term =.. [F|Args],
        length(Args, Arity),
        I =< Arity,
        nth1(I, Args, OldSub, RestArgs),
        set_address_value(Rest, OldSub, Value, NewSub),
        nth1(I, NewArgs, NewSub, RestArgs),
        NewTerm =.. [F|NewArgs]
    ).

% leaf_addresses(+Term, -LeafAddresses)
% All addresses whose value is atomic (or empty list).
leaf_addresses(Term, Leaves) :-
    term_addresses(Term, All),
    include(is_leaf_pair, All, LeafPairs),
    pairs_keys(LeafPairs, Leaves).

is_leaf_pair(_-V) :-
    ( atomic(V) -> true
    ; V = [] -> true
    ; fail
    ).
