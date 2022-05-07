#!/usr/bin/env sh

set -eu

irb \
  -r ./test_bench/test_init.rb \
  --readline \
  --prompt simple \
  $@
