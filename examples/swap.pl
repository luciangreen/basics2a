% examples/swap.pl — Two-item swap example

:- use_module('../basic_s2a').

:- initialization(main, main).

main :-
    writeln('=== Swap Example ==='),
    spec_to_basic(swap,
        [ [1,2]-[2,1],
          [3,4]-[4,3],
          [5,6]-[6,5]
        ],
        Basic),
    writeln(Basic), nl,

    writeln('=== Structured Input Form ==='),
    spec_to_basic(swap,
        [ [[input,[['A',[1,2]]]],[output,[['B',[2,1]]]]],
          [[input,[['A',[3,4]]]],[output,[['B',[4,3]]]]],
          [[input,[['A',[5,6]]]],[output,[['B',[6,5]]]]]
        ],
        [chars(off),dialect(generic),verify(on)],
        Basic2),
    writeln(Basic2).
