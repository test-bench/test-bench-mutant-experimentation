require_relative '../load_path'

require 'mutant'
require 'mutant/integration/testbench'

test_paths = ["test_bench/automated/example.rb"]

## Build a coverage map for the given test paths
Mutant::Integration::Testbench.build_coverage_map(test_paths)

## Instantiate mutant configuration
mutant_config = Mutant::Config.env.with(
  includes: ['lib'],
  requires: ['test_bench_mutant_experimentation'],
  integration: 'testbench'
)

## Append each invoked method to mutant matcher's subjects
mutant_matcher = mutant_config.matcher

Mutant::Integration::Testbench.coverage_map.each_method_specifier do |method_specifier|
  maybe_mutant_subject = mutant_config.expression_parser.(method_specifier)
  mutant_subject = maybe_mutant_subject.from_right

  mutant_matcher.add(:subjects, mutant_subject)
end

mutant_config = mutant_config.with(matcher: mutant_matcher)

## Build a mutant environment from the mutant configuration
maybe_mutant_env = Mutant::Bootstrap.(Mutant::WORLD, mutant_config)
mutant_env = maybe_mutant_env.from_right

Mutant::Runner.(mutant_env)
