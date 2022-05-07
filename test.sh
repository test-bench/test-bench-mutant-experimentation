#!/bin/sh

set -eu -o pipefail

TEST_FRAMEWORK=${1:-testbench}

echo
echo "Mutation Test"
echo "= = ="
echo
echo "Framework: $TEST_FRAMEWORK"
echo

bundle exec mutant run --include lib --require test_bench_mutant_experimentation --use $TEST_FRAMEWORK -- 'TestBenchMutantExperimentation*'
