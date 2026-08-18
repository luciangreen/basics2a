% basic_generator.pl — Generate BASIC source from algorithm IR
%
% String operations used by the generic dialect:
%   MID$(s$, start, len)  — extract substring
%   LEN(s$)               — string length
%   +                     — string concatenation

:- module(basic_generator, [
    basic_generate/2,
    basic_generate/3
]).

:- use_module(correspondence).

% basic_generate(+IR, -BasicSource)
basic_generate(IR, Source) :-
    basic_generate(IR, [dialect(generic)], Source).

% basic_generate(+IR, +Options, -BasicSource)
basic_generate(IR, _Options, Source) :-
    IR = algorithm(Name, IShape, OShape, Instructions),
    upcase_atom(Name, NameUp),
    format_input_params(IShape, InParam),
    format_output_params(OShape, OutParam),
    format(atom(Header), 'SUB ~w(~w, ~w)', [NameUp, InParam, OutParam]),
    maplist(instruction_to_basic_line, Instructions, Lines),
    atomic_list_concat(['END SUB'], Footer),
    atomic_list_concat([Header|Lines], '\n', Body),
    atomic_list_concat([Body, '\n', Footer], Source).

format_input_params(scalar, 'Input') :- !.
format_input_params(_, 'Input()').

format_output_params(scalar, 'Output') :- !.
format_output_params(_, 'Output()').

instruction_to_basic_line(copy(IAddr, OAddr), Line) :-
    addr_to_basic_ref('Input', IAddr, IRef),
    addr_to_basic_ref('Output', OAddr, ORef),
    format(atom(Line), '    ~w = ~w', [ORef, IRef]).
instruction_to_basic_line(constant(OAddr, Val), Line) :-
    addr_to_basic_ref('Output', OAddr, ORef),
    ( atom(Val) ->
        format(atom(Line), '    ~w = "~w"', [ORef, Val])
    ; string(Val) ->
        format(atom(Line), '    ~w = "~w"', [ORef, Val])
    ;
        format(atom(Line), '    ~w = ~w', [ORef, Val])
    ).

addr_to_basic_ref(Var, [], Var) :- !.
addr_to_basic_ref(Var, [Idx], Ref) :-
    format(atom(Ref), '~w(~w)', [Var, Idx]).
addr_to_basic_ref(Var, [I1,I2|_], Ref) :-
    format(atom(Ref), '~w(~w,~w)', [Var, I1, I2]).
