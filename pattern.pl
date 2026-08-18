% pattern.pl — Structural pattern discovery

:- module(pattern, [
    characterise_specs/2,
    input_shape/2,
    output_shape/2
]).

:- use_module(addresses).

% characterise_specs(+NormSpecs, -Shapes)
% Shapes = shapes(InputShape, OutputShape)
characterise_specs(Specs, shapes(IShape, OShape)) :-
    pairs_keys_values(Specs, InWrapped, OutWrapped),
    unwrap_ins(InWrapped, Inputs),
    unwrap_outs(OutWrapped, Outputs),
    Inputs = [FirstIn|_],
    Outputs = [FirstOut|_],
    input_shape(FirstIn, IShape),
    output_shape(FirstOut, OShape).

input_shape(T, S) :- term_shape(T, S).
output_shape(T, S) :- term_shape(T, S).

term_shape(T, scalar) :- atomic(T), !.
term_shape(T, list(N)) :- is_list(T), !, length(T, N).
term_shape(T, compound(F,N)) :- compound(T), !, functor(T, F, N).

unwrap_ins([], []).
unwrap_ins([in(X)|T], [X|R]) :- unwrap_ins(T, R).

unwrap_outs([], []).
unwrap_outs([out(X)|T], [X|R]) :- unwrap_outs(T, R).
