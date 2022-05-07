# Test Bench Mutant Experimentation

## Setup

Install gem dependencies:

``` sh
> ./install-gems.sh
```

Run tests with TestBench:

``` sh
> bundle exec bench test_bench/automated
```

Run tests with RSpec:

``` sh
> bundle exec rspec
```

Run tests with Minitest:

``` sh
> ruby test/run.rb
```

IRB console:

``` sh
> ./console.sh
```

## Running Mutant

RSpec:

``` sh
> ./test.sh rspec
```

Minitest:

``` sh
> ./test.sh minitest
```

Test Bench:

``` sh
> ./test.sh testbench
```
