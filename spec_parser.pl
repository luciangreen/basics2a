% spec_parser.pl — Normalise input/output specification forms
%
% Accepts:
%   Structured form: [[[input,In],[output,Out]], ...]
%   Simple form:     [In-Out, ...]
%   Nested simple:   [[In-Out], ...]

:- module(spec_parser, [
    normalise_specs/2
]).

% normalise_specs(+RawSpecs, -NormSpecs)
% NormSpecs is a list of pairs in(In)-out(Out)
normalise_specs([], []).
normalise_specs([H|T], [NH|NT]) :-
    normalise_spec(H, NH),
    normalise_specs(T, NT).

normalise_spec([[input,In],[output,Out]], in(In)-out(Out)) :- !.
normalise_spec([[input,In]|Rest], in(In)-out(Out)) :-
    member([output,Out], Rest), !.
normalise_spec(In-Out, in(In)-out(Out)) :- !.
normalise_spec([In-Out], in(In)-out(Out)) :- !.
normalise_spec(Spec, _) :-
    throw(error(malformed_spec(Spec))).
