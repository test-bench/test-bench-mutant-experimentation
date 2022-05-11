module Mutant
  class Integration
    class Testbench
      class Adapter
        attr_reader :mutant_tests
        attr_reader :mutant_subjects

        def initialize(mutant_tests, mutant_subjects)
          @mutant_tests = mutant_tests
          @mutant_subjects = mutant_subjects
        end

        def self.build(mutant_integration, *paths)
          if paths.empty?
            ## Get TestBench CLI's path arguments, e.g. bundle exec bench --mutant test/some_dir test/other_dir - Sat May 07 2022
            paths = ["test_bench/automated/example.rb"]
          end

          mutant_subjects = []

          mutant_expression_parser = mutant_integration.expression_parser

          TraceMethodCalls.(paths) do |method_text|
            maybe_mutant_subject = mutant_expression_parser.(method_text)
            mutant_subject = maybe_mutant_subject.from_right

            mutant_subjects << mutant_subject
          end

          mutant_tests = mutant_tests(paths, mutant_subjects)

          new(mutant_tests, mutant_subjects)
        end

        def self.mutant_tests(paths, mutant_expressions)
          paths.flat_map do |path|
            if File.directory?(path)
              test_files = Dir[File.join(path, '**/*.rb')]
            else
              test_files = [path]
            end

            test_files.map do |test_file|
              Test.new(id: test_file, expressions: mutant_expressions)
            end
          end
        end

        def self.session
          TestBench::Session.build.tap do |session|
            null_output = TestBench::Fixture::Output::Null.new

            session.output = null_output
          end
        end

        def run(mutant_test_batch)
          session = self.class.session

          start_time = ::Time.now

          TestBench::Run.(session: session) do |run|
            mutant_test_batch.each do |mutant_test|
              test_file = mutant_test.id

              begin
                run.path(test_file)
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
      end
    end
  end
end
