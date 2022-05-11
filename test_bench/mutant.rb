require_relative '../load_path'

require 'mutant'

mutant_config = Mutant::Config.env.with(
  includes: ['lib'],
  requires: ['test_bench_mutant_experimentation'],
  integration: 'testbench'
)

maybe_mutant_env = Mutant::Bootstrap.(Mutant::WORLD, mutant_config)
mutant_env = maybe_mutant_env.from_right

test_bench_adapter = mutant_env.integration.test_bench_adapter

mutant_matcher = mutant_config.matcher
test_bench_adapter.mutant_subjects.each do |mutant_subject|
  mutant_matcher = mutant_matcher.add(:subjects, mutant_subject)
end

mutant_config = mutant_config.with(matcher: mutant_matcher)

maybe_mutant_env = Mutant::Bootstrap.(Mutant::WORLD, mutant_config)
mutant_env = maybe_mutant_env.from_right

Mutant::Runner.(mutant_env)
