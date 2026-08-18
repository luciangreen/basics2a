% algorithm_ir.pl — Build intermediate representation of inferred algorithm

:- module(algorithm_ir, [
    build_algorithm_ir/4,
    execute_ir/3
]).

:- use_module(addresses).
:- use_module(correspondence).
:- use_module(pattern).

% build_algorithm_ir(+Name, +NormSpecs, +Options, -IR)
% IR = algorithm(Name, InputShape, OutputShape, Instructions)
build_algorithm_ir(Name, Specs, Options, algorithm(Name, IShape, OShape, Instructions)) :-
    characterise_specs(Specs, shapes(IShape, OShape)),
    discover_correspondences(Specs, Options, Corrs),
    filter_valid_corrs(Corrs, ValidCorrs),
    maplist(corr_to_instruction, ValidCorrs, Instructions).

filter_valid_corrs([], []).
filter_valid_corrs([H|T], [H|R]) :-
    ( H = copy(_,_) ; H = constant(_,_) ), !,
    filter_valid_corrs(T, R).
filter_valid_corrs([_|T], R) :-
    filter_valid_corrs(T, R).

corr_to_instruction(copy(IA, OA), copy(IA, OA)).
corr_to_instruction(constant(OA, V), constant(OA, V)).

% execute_ir(+IR, +Input, -Output)
% Execute the IR against Input to produce Output.
execute_ir(algorithm(_Name, _IShape, _OShape, Instructions), Input, Output) :-
    maplist(eval_instruction(Input), Instructions, Pairs),
    build_output_from_pairs(Pairs, Output).

eval_instruction(Input, copy(IA, OA), OA-Val) :-
    address_value(IA, Input, Val).
eval_instruction(_Input, constant(OA, Val), OA-Val).

% build_output_from_pairs(+Pairs, -Output)
% Reconstruct a nested structure from a flat list of address-value pairs.
build_output_from_pairs(Pairs, Output) :-
    ( Pairs = [([]-Val)] ->
        Output = Val
    ;
        max_list_index(Pairs, MaxIdx),
        build_list(1, MaxIdx, Pairs, Output)
    ).

max_list_index(Pairs, Max) :-
    maplist(top_index, Pairs, Indices),
    max_list(Indices, Max).

top_index([I|_]-_, I).

build_list(I, Max, _Pairs, []) :- I > Max, !.
build_list(I, Max, Pairs, [Elem|Rest]) :-
    I =< Max,
    % Collect all pairs with top index I, strip the top index
    include(has_top(I), Pairs, SubPairs0),
    maplist(strip_top, SubPairs0, SubPairs),
    ( SubPairs = [[]-Val] ->
        Elem = Val
    ; SubPairs = [] ->
        Elem = _
    ;
        max_list_index(SubPairs, SubMax),
        build_list(1, SubMax, SubPairs, Elem)
    ),
    Next is I + 1,
    build_list(Next, Max, Pairs, Rest).

has_top(I, [I|_]-_).
strip_top([_|Rest]-Val, Rest-Val).
