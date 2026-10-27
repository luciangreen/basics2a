#!/bin/sh
set -eu

cd "$(dirname "$0")/.."
export LC_ALL=C.UTF-8

for test_file in tests/test_*.pl; do
    suite=${test_file#tests/test_}
    suite=${suite%.pl}
    printf '\n==> %s\n' "$test_file"
    swipl -q -s "$test_file" \
        -g "(run_tests($suite) -> halt(0) ; halt(1))"
done
