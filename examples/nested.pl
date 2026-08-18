% examples/nested.pl — Nested structure example

:- use_module('../basic_s2a').

:- initialization(main, main).

main :-
    writeln('=== Nested Input Example ==='),
    % [[1,2],[3,4]] -> [4,1] : Output[1]=Input[2][2], Output[2]=Input[1][1]
    spec_to_basic(extract,
        [ [[1,2],[3,4]]-[4,1],
          [[5,6],[7,8]]-[8,5]
        ],
        Basic),
    writeln(Basic), nl,

    writeln('=== Three-item Permutation ==='),
    spec_to_basic(perm,
        [ [1,2,3]-[3,1,2],
          [4,5,6]-[6,4,5],
          [7,8,9]-[9,7,8]
        ],
        Basic2),
    writeln(Basic2).
