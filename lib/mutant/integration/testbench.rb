require 'test_bench'

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
      def all_tests
        ## Need to resolve a list of files - Sat May 07 2022
        test_file = "test_bench/automated/example.rb"

        id = test_file

        ## Run the list of files with a code coverage detector in order to derive a list of expressions - Sat May 07 2022
        expressions = [expression_parser.("TestBenchMutantExperimentation*").from_right]

        mutant_test = Test.new(id:, expressions:)
        [mutant_test]
      end

      def call(tests)
        test_bench_session = TestBench::Session.build

        start_time = ::Time.now

        TestBench::Run.(session: test_bench_session) do |run|
          tests.each do |test|
            test_file = test.id

            begin
              run.path(test_file)
            rescue Exception => _exception
            end
          end
        end

        passed = !test_bench_session.failed?

        stop_time = ::Time.now
        elapsed_time = stop_time - start_time

        Result::Test.new(passed:, runtime: elapsed_time)
      end
    end
  end
end
