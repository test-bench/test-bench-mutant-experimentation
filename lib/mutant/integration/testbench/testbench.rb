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
      def self.build_coverage_map(test_paths)
        @coverage_map = CoverageMap::Capture.(test_paths)
      end

      def self.coverage_map
        @coverage_map
      end

      def all_tests
        mutant_tests = []

        Testbench.coverage_map.each_test_file do |test_file, method_specifiers|
          mutant_expressions = method_specifiers.map do |method_specifier|
            maybe_mutant_expression = mutant_integration.expression_parser.(method_specifier)
            maybe_mutant_expression.from_right
          end

          mutant_test = Test.new(id: test_file, expressions: mutant_expressions)
          mutant_tests << mutant_tests
        end

        mutant_tests
      end

      def call(mutant_test_batch)
        session = Testbench.session

        start_time = ::Time.now

        TestBench::Run.(session: session) do |run|
          mutant_test_batch.each do |mutant_test|
            test_file = mutant_test.id

            begin
              run.file(test_file)
            ## Determine if this needs to rescue all Exception types - Sat May 07 2022
            rescue StandardError
            end
          end
        end

        passed = !session.failed?

        stop_time = ::Time.now
        elapsed_time = stop_time - start_time

        Result::Test.new(passed:, runtime: elapsed_time)
      end

      def self.session
        TestBench::Session.build.tap do |session|
          null_output = TestBench::Fixture::Output::Null.new

          session.output = null_output
        end
      end
    end
  end
end

