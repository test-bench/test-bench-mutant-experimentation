module Mutant
  class Integration
    ## Mutant's constant resolution is insufficient for TestBench, it merely
    ## capitalizes the first character of the framework name
    ##
    ## mutant run --use test_bench would cause:
    ##   - require "mutant/integration/test_bench"
    ##   - Mutant::Integration.const_get(:Test_bench)
    ##
    ## - Sat May 07 2022
    class Testbench < self
      def test_bench_adapter
        Adapter.build(self)
      end
      memoize :test_bench_adapter

      def all_tests
        test_bench_adapter.mutant_tests
      end

      def call(tests)
        mutant_test_batch = tests

        test_bench_adapter.run(mutant_test_batch)
      end
    end
  end
end

