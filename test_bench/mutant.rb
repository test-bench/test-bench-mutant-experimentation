require_relative '../load_path'

require 'mutant'
require 'mutant/integration/testbench'

test_paths = ["test_bench/automated/example.rb"]

## Build a coverage map for the given test paths
Mutant::Integration::Testbench.build_coverage_map(test_paths)

## Specify all covered methods as the subjects
mutant_matcher_config = Mutant::Matcher::Config::DEFAULT

mutant_expression_parser = Mutant::Config::DEFAULT.expression_parser
Mutant::Integration::Testbench.coverage_map.each_method_specifier do |method_specifier|
  maybe_mutant_expression = mutant_expression_parser.(method_specifier)
  mutant_expression = maybe_mutant_expression.from_right

  mutant_matcher_config = mutant_matcher_config.add(:subjects, mutant_expression)
end

## Instantiate mutant configuration with the matcher config
mutant_config = Mutant::Config.env.with(
  includes: ['lib'],
  requires: ['test_bench_mutant_experimentation'],
  integration: 'testbench',
  matcher: mutant_matcher_config,
  coverage_criteria: Mutant::Config::CoverageCriteria::DEFAULT
)

## Build a mutant environment from the mutant configuration
maybe_mutant_env = Mutant::Bootstrap.(Mutant::WORLD, mutant_config)
mutant_env = maybe_mutant_env.from_right

Mutant::Runner.(mutant_env)

Mutant::Integration::Testbench.dump_log
