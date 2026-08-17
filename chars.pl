% chars.pl — Character-level decomposition and recombination

:- module(chars, [
    decompose_chars_spec/2,
    recompose_chars/2,
    recombine_character_pattern/2
]).

% decompose_chars_spec(+NormSpec, -CharSpec)
decompose_chars_spec(in(I)-out(O), in(CI)-out(CO)) :-
    term_to_chars(I, CI),
    term_to_chars(O, CO).

% term_to_chars(+Term, -CharTerm)
term_to_chars(Term, Chars) :-
    ( atom(Term) ->
        atom_chars(Term, Chars)
    ; string(Term) ->
        string_chars(Term, Chars)
    ; is_list(Term) ->
        maplist(term_to_chars, Term, Chars)
    ;
        Chars = Term
    ).

% recompose_chars(+CharList, -Atom)
recompose_chars(Chars, Atom) :-
    ( is_list(Chars) ->
        atomic_list_concat(Chars, Atom)
    ;
        Atom = Chars
    ).

% recombine_character_pattern(+Mapping, -BASICExpr)
% Given a list of char positions, produce a BASIC MID$(...) expression.
recombine_character_pattern(Mappings, Expr) :-
    maplist(mapping_to_mid, Mappings, Parts),
    atomic_list_concat(Parts, ' + ', Expr).

mapping_to_mid(copy([Idx], _), Part) :-
    format(atom(Part), 'MID$(Input$,~w,1)', [Idx]).
mapping_to_mid(constant(_, C), Part) :-
    format(atom(Part), '"~w"', [C]).
