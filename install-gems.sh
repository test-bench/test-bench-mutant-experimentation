#!/usr/bin/env bash

set -euo pipefail

gem_dir="./gems"

echo
echo "Install Gems"
echo "= = ="

echo "Gem Directory: $gem_dir"
echo

echo "Removing bundler configuration"
echo "- - -"

cmd="rm -rfv ./.bundle"

echo $cmd
($cmd)

echo
echo "Removing Gemfile.lock"
echo "- - -"

cmd="rm -fv Gemfile.lock"

echo $cmd
($cmd)

echo
echo "Removing installed gems"
echo "- - -"

cmd="rm -rf $gem_dir"

echo $cmd
($cmd)

echo "Setting bundler path"
echo "- - -"

cmd="bundle config set --local path ./gems"

echo $cmd
($cmd)

echo
echo "Installing bundle"
echo "- - -"

cmd="bundle install --standalone"

echo $cmd
($cmd)

echo "- - -"
echo "(done)"
echo
