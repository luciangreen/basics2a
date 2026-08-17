% generalise.pl — Structural generalisation across examples
%
% Compares corresponding positions across multiple examples.
% Positions that are constant across all examples remain constants.
% Positions that vary become inferred variables.

:- module(generalise, [
    generalise_specs/2,
    generalise_terms/3,
    find_constants/3
]).

:- use_module(addresses).

% generalise_specs(+NormSpecs, -GenResult)
% GenResult = generalised(InputPattern, OutputPattern, VarMap)
generalise_specs(Specs, generalised(InputPattern, OutputPattern, VarMap)) :-
    ( Specs = [] -> throw(error(no_specs)) ; true ),
    pairs_keys_values(Specs, InList, OutList),
    unwrap_ins(InList, Inputs),
    unwrap_outs(OutList, Outputs),
    generalise_terms(Inputs, InputPattern, IVars),
    generalise_terms(Outputs, OutputPattern, OVars),
    build_var_map(IVars, OVars, Inputs, Outputs, VarMap).

unwrap_ins([], []).
unwrap_ins([in(X)|T], [X|R]) :- unwrap_ins(T, R).

unwrap_outs([], []).
unwrap_outs([out(X)|T], [X|R]) :- unwrap_outs(T, R).

% generalise_terms(+Terms, -Pattern, -VarPositions)
% Pattern is the first example with var(_) substituted at varying leaf positions.
% VarPositions = [pos(Addr,VarId)|...]
generalise_terms([First|Rest], Pattern, VarPositions) :-
    term_addresses(First, FirstPairs),
    foldl(intersect_leaf_values, Rest, FirstPairs, ConstantPairs),
    build_pattern(First, FirstPairs, ConstantPairs, Pattern, VarPositions).

build_pattern(Term, Pairs, ConstPairs, Pattern, VarPositions) :-
    leaf_pairs(Pairs, LeafPairs),
    foldl(apply_var_or_const(ConstPairs), LeafPairs, Term-0-[], Pattern-_-VarPositions).

apply_var_or_const(ConstPairs, Addr-Val, T-N-VP, NewT-N1-NewVP) :-
    ( is_leaf_val(Val) ->
        ( member(Addr-Val, ConstPairs) ->
            NewT = T,
            N1 = N,
            NewVP = VP
        ;
            N1 is N + 1,
            VarId = v(N1),
            set_address_value(Addr, T, var(VarId), NewT),
            NewVP = [pos(Addr,VarId)|VP]
        )
    ;
        NewT = T,
        N1 = N,
        NewVP = VP
    ).

leaf_pairs([], []).
leaf_pairs([Addr-V|T], [Addr-V|R]) :-
    is_leaf_val(V), !,
    leaf_pairs(T, R).
leaf_pairs([_|T], R) :- leaf_pairs(T, R).

is_leaf_val(V) :- atomic(V), !.
is_leaf_val([]).

% intersect_leaf_values(+Term, +Pairs, -ConstantPairs)
% Keep only those Addr-Val pairs where Term[Addr] = Val
intersect_leaf_values(Term, Pairs, Constants) :-
    include(pair_matches_term(Term), Pairs, Constants).

pair_matches_term(Term, Addr-Val) :-
    is_leaf_val(Val),
    catch(address_value(Addr, Term, Val), _, fail).

% find_constants(+Terms, -ConstAddrs, -VarAddrs)
find_constants([First|Rest], ConstAddrs, VarAddrs) :-
    term_addresses(First, FirstPairs),
    foldl(intersect_leaf_values, Rest, FirstPairs, ConstPairs),
    leaf_pairs(FirstPairs, AllLeaves),
    pairs_keys(ConstPairs, ConstAddrs),
    pairs_keys(AllLeaves, AllLeafAddrs),
    subtract(AllLeafAddrs, ConstAddrs, VarAddrs).

% build_var_map(+IVars, +OVars, +Inputs, +Outputs, -VarMap)
build_var_map(IVars, OVars, Inputs, Outputs, VarMap) :-
    maplist(match_ovar_to_ivar(IVars, Inputs, Outputs), OVars, VarMap0),
    include(valid_mapping, VarMap0, VarMap).

valid_mapping(mapping(_,_,_)).

match_ovar_to_ivar(IVars, Inputs, Outputs, pos(OAddr,OVarId), Mapping) :-
    maplist(addr_value(OAddr), Outputs, OVals),
    ( member(pos(IAddr,_IVarId), IVars),
      maplist(addr_value(IAddr), Inputs, OVals)
    ->
        Mapping = mapping(IAddr, OAddr, OVarId)
    ;
        Mapping = mapping(none, OAddr, OVarId)
    ).

addr_value(Addr, Term, Val) :- address_value(Addr, Term, Val).
