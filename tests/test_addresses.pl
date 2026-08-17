% test_addresses.pl — Tests for the address system

:- use_module(library(plunit)).
:- use_module('../addresses').

:- begin_tests(addresses).

test(leaf_addresses_list) :-
    leaf_addresses([1,2,3], Addrs),
    msort(Addrs, Sorted),
    msort([[1],[2],[3]], Sorted).

test(leaf_addresses_scalar) :-
    leaf_addresses(hello, Addrs),
    Addrs = [[]].

test(leaf_addresses_nested) :-
    leaf_addresses([[1,2],[3,4]], Addrs),
    msort(Addrs, Sorted),
    msort([[1,1],[1,2],[2,1],[2,2]], Sorted).

test(address_value_top) :-
    address_value([], foo, foo).

test(address_value_list) :-
    address_value([2], [a,b,c], b).

test(address_value_nested) :-
    address_value([2,1], [[1,2],[3,4]], 3).

test(set_address_value_scalar) :-
    set_address_value([], _, 42, 42).

test(set_address_value_list) :-
    set_address_value([1], [a,b], x, [x,b]).

test(set_address_value_nested) :-
    set_address_value([2,1], [[1,2],[3,4]], 99, [[1,2],[99,4]]).

test(term_addresses_includes_all) :-
    term_addresses([a,b], Pairs),
    member([1]-a, Pairs),
    member([2]-b, Pairs).

:- end_tests(addresses).

:- run_tests(addresses).
