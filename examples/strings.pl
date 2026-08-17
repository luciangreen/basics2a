% examples/strings.pl — Character/string example with chars(on)

:- use_module('../basic_s2a').

:- initialization(main, main).

main :-
    writeln('=== Character Reversal (2-char) with chars(on) ==='),
    spec_to_basic(reverse_two,
        [ ab-ba,
          cd-dc,
          ef-fe
        ],
        [chars(on)],
        Basic),
    writeln(Basic), nl,

    writeln('=== Report ==='),
    spec_to_basic_report(
        [ ab-ba,
          cd-dc,
          ef-fe
        ],
        Report),
    writeln(Report).
