% examples/constants.pl — Output constants example

:- use_module('../basic_s2a').

:- initialization(main, main).

main :-
    writeln('=== Output Constants ==='),
    % 1 -> [answer,1], 2 -> [answer,2]
    spec_to_basic(label,
        [ [1]-[answer,1],
          [2]-[answer,2],
          [3]-[answer,3]
        ],
        Basic),
    writeln(Basic), nl,

    writeln('=== Duplicate Input Value ==='),
    % [X,Y] -> [X,X,Y]
    spec_to_basic(dup,
        [ [1,2]-[1,1,2],
          [3,4]-[3,3,4],
          [5,6]-[5,5,6]
        ],
        Basic2),
    writeln(Basic2), nl,

    writeln('=== Omitted Input Component ==='),
    % [1,2,3] -> [3,1] : position 2 unused
    spec_to_basic(extract2,
        [ [1,2,3]-[3,1],
          [4,5,6]-[6,4]
        ],
        Basic3),
    writeln(Basic3).
