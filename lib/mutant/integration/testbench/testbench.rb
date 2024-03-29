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
      def self.coverage_map
        ## Would need to be test/automated to match TestBench default
        @coverage_map ||= build_coverage_map("test_bench/automated")
      end

      def self.build_coverage_map(test_paths)
        @coverage_map = CoverageMap::Capture.(test_paths)
      end

      def self.log_path
        '/tmp/mutant.log'
      end

      def self.open_log(&block)
        unless ENV['DEBUG'] == 'on'
          return
        end

        File.open(log_path, 'a+', &block)
      end

      def self.log(text)
        open_log do |log|
          log.puts text
        end
      end

      def self.dump_log
        open_log do |log|
          log.rewind
          puts log.gets until log.eof?
        end

        File.unlink(log_path) if File.exist?(log_path)
      end

      def all_tests
        mutant_tests = []

        Testbench.coverage_map.each_test_file do |test_file, method_specifiers|
          mutant_expressions = method_specifiers.map do |method_specifier|
            maybe_mutant_expression = expression_parser.(method_specifier)
            maybe_mutant_expression.from_right
          end

          mutant_test = Test.new(id: test_file, expressions: mutant_expressions)
          mutant_tests << mutant_test
        end

        mutant_tests
      end

      def call(mutant_test_batch)
        #output = TestBench::Fixture::Output::Null.new
        output = TestBench::Output.build
        session = TestBench::Session.build(output:)

        start_time = ::Time.now

        TestBench::Run.(session:) do |run|
          mutant_test_batch.each do |mutant_test|
            test_file = mutant_test.id

            begin
              run.file(test_file)
            ## Determine if this needs to rescue all Exception types - Sat May 07 2022
            rescue StandardError
            end

            Testbench.log("Mutation finished (File: %s, PID: %d, Passed: %s)" % [test_file, Process.pid, !session.failed?])
          end
        end

        passed = !session.failed?

        stop_time = ::Time.now
        elapsed_time = stop_time - start_time

        Result::Test.new(passed:, runtime: elapsed_time)
      end
    end
  end
end
