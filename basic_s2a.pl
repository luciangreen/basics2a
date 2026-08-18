% basic_s2a.pl — BASIC Spec to Algorithm: top-level public API
%
% Public predicates:
%   spec_to_basic(+Name, +Specs, -Basic)
%   spec_to_basic(+Name, +Specs, +Options, -Basic)
%   spec_to_basic_report(+Specs, -Report)
%
% Default options: [chars(off), dialect(generic), verify(on)]

:- module(basic_s2a, [
    spec_to_basic/3,
    spec_to_basic/4,
    spec_to_basic_report/2
]).

:- use_module(spec_parser).
:- use_module(addresses).
:- use_module(generalise).
:- use_module(correspondence).
:- use_module(pattern).
:- use_module(algorithm_ir, [build_algorithm_ir/4, execute_ir/3]).
:- use_module(basic_generator).
:- use_module(basic_verify).
:- use_module(chars).

default_options([chars(off), dialect(generic), verify(on)]).

% spec_to_basic(+Name, +Specs, -Basic)
spec_to_basic(Name, Specs, Basic) :-
    default_options(Opts),
    spec_to_basic(Name, Specs, Opts, Basic).

% spec_to_basic(+Name, +Specs, +Options, -Basic)
spec_to_basic(Name, Specs, Options, Basic) :-
    ( Specs = [] -> throw(error(no_specs)) ; true ),
    normalise_specs(Specs, NormSpecs),
    resolve_options(Options, ResolvedOpts),
    maybe_check_insufficient(NormSpecs),
    ( member(chars(on), ResolvedOpts) ->
        maplist(decompose_chars_spec, NormSpecs, WorkSpecs),
        exclude(=(chars(on)), ResolvedOpts, IROptions)
    ;
        WorkSpecs = NormSpecs,
        IROptions = ResolvedOpts
    ),
    build_algorithm_ir(Name, WorkSpecs, IROptions, IR),
    ( member(verify(on), ResolvedOpts) ->
        verify_specs(WorkSpecs, IR)
    ; true ),
    basic_generate(IR, ResolvedOpts, Basic).

resolve_options(Opts, Resolved) :-
    default_options(Defaults),
    merge_options(Opts, Defaults, Resolved).

merge_options([], Defaults, Defaults).
merge_options([H|T], Defaults, Merged) :-
    functor(H, Key, _Arity),
    exclude(has_key(Key), Defaults, Stripped),
    merge_options(T, [H|Stripped], Merged).

has_key(Key, Term) :- functor(Term, Key, _).

maybe_check_insufficient(Specs) :-
    length(Specs, N),
    ( N < 2 ->
        print_message(warning, warning(insufficient_examples_for_generalisation))
    ; true ).

% spec_to_basic_report(+Specs, -Report)
spec_to_basic_report(Specs, Report) :-
    normalise_specs(Specs, NormSpecs),
    length(NormSpecs, Count),
    pairs_keys_values(NormSpecs, InW, OutW),
    unwrap_ins(InW, Inputs),
    unwrap_outs(OutW, Outputs),
    find_constants(Inputs, _, _),
    find_constants(Outputs, _, _),
    generalise_terms(Inputs, InputPattern, _),
    generalise_terms(Outputs, OutputPattern, _),
    discover_correspondences(NormSpecs, [], Corrs),
    include(is_copy_corr, Corrs, Copies),
    include(is_const_corr, Corrs, Constants),
    maplist(copy_to_mapping_pair, Copies, Mappings),
    maplist(const_to_pair, Constants, ConstPairs),
    build_algorithm_ir(report, NormSpecs, [], IR),
    ( catch(verify_specs(NormSpecs, IR), _, fail) ->
        Verif = passed
    ;
        Verif = unverified
    ),
    Report = report(
        examples(Count),
        input_pattern(InputPattern),
        output_pattern(OutputPattern),
        mappings(Mappings),
        constants(ConstPairs),
        verification(Verif)
    ).

unwrap_ins([], []).
unwrap_ins([in(X)|T], [X|R]) :- unwrap_ins(T, R).

unwrap_outs([], []).
unwrap_outs([out(X)|T], [X|R]) :- unwrap_outs(T, R).

is_copy_corr(copy(_,_)).
is_const_corr(constant(_,_)).

copy_to_mapping_pair(copy(IA,OA), IA-OA).
const_to_pair(constant(OA,V), OA-V).

:- multifile prolog:message//1.
prolog:message(warning(insufficient_examples_for_generalisation)) -->
    ['WARNING: Only one example provided; generalisation has low evidence.'].
