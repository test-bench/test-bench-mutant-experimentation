#!/bin/sh

set -eu -o pipefail

TEST_FRAMEWORK=${1:-test_bench}

echo
echo "Mutation Test"
echo "= = ="
echo
echo "Framework: $TEST_FRAMEWORK"
echo

echo "List Tests"
echo "- - -"
echo

if [ $TEST_FRAMEWORK = "test_bench" ]; then
  list_test_framework="testbench"
else
  list_test_framework=$TEST_FRAMEWORK
fi

bundle exec mutant environment test list --include lib --require test_bench_mutant_experimentation --use $list_test_framework

echo
echo "Running Tests"
echo "- - -"
echo

if [ $TEST_FRAMEWORK = "test_bench" ]; then
  run_cmd="ruby test_bench/mutant.rb"
else
  run_cmd="bundle exec mutant run --include lib --require test_bench_mutant_experimentation --use $TEST_FRAMEWORK -- TestBenchMutantExperimentation*"
fi

echo "Command: $run_cmd"
echo

if [ "${DRY_RUN:-off}" = "on" ]; then
  echo "(dry run; command not run)"
else
  $run_cmd
fi

echo
