#!/usr/bin/env sh

set -eu

irb \
  -r ./test/test_init.rb \
  --readline \
  --prompt simple \
  $@
