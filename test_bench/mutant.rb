require_relative '../load_path'

require 'rubygems'
require 'mutant'
require 'mutant/integration/testbench'

test_paths = ["test_bench/automated/example.rb"]

## Build a coverage map for the given test paths
coverage_map = Mutant::Integration::Testbench.build_coverage_map(test_paths)

## Specify all covered methods as the subjects
mutant_matcher_config = Mutant::Matcher::Config::DEFAULT

mutant_expression_parser = Mutant::Config::DEFAULT.expression_parser
Mutant::Integration::Testbench.coverage_map.each_method_specifier do |method_specifier|
  maybe_mutant_expression = mutant_expression_parser.(method_specifier)
  mutant_expression = maybe_mutant_expression.from_right

  mutant_matcher_config = mutant_matcher_config.add(:subjects, mutant_expression)
end

## Mutant reporter
mutant_reporter = Mutant::Integration::Testbench::Reporter.build(STDOUT)

## Instantiate mutant configuration with the matcher config
mutant_env = Mutant::Env.empty(Mutant::WORLD, Mutant::Config::DEFAULT)

mutant_config = Mutant::Config.load_config_file(mutant_env).from_right.with(
  reporter: mutant_reporter,
  matcher: mutant_matcher_config
)

mutant_config = Mutant::Config.env.merge(mutant_config)
mutant_env = mutant_env.with(config: mutant_config)

mutant_env = Mutant::Bootstrap.(mutant_env).from_right

Mutant::Runner.(mutant_env)

Mutant::Integration::Testbench.dump_log
