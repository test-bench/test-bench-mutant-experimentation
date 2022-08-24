module Mutant
  class Integration
    class Testbench
      class CoverageMap
        def logger
          @logger ||= Logger.new(STDERR)
        end
        attr_writer :logger

        def method_specifier_index
          @method_specifier_index ||= Hash.new do |index, method_specifier|
            logger.info { "New method invocation: #{method_specifier}" }

            index[method_specifier] = Set.new
          end
        end

        def test_file_index
          @test_file_index ||= Hash.new do |index, test_file|
            logger.info { "New test_file: #{test_file}" }

            index[test_file] = Set.new
          end
        end

        def method_invoked(invocation)
          method_specifier = invocation.method_specifier
          test_file = invocation.test_file

          method_specifier_index[method_specifier] << test_file

          test_file_index[test_file] << method_specifier
        end

        def each_method_specifier(&block)
          method_specifier_index.each_key(&block)
        end

        def each_test_file(&block)
          test_file_index.each do |test_file, method_specifiers|
            block.(test_file, method_specifiers.to_a)
          end
        end

        class Capture
          attr_reader :test_paths

          def initialize(test_paths)
            @test_paths = test_paths
          end

          def self.build(test_paths)
            new(test_paths)
          end

          def self.call(test_paths, &block)
            instance = build(test_paths)
            instance.(&block)
          end

          def call(&block)
            coverage_map = CoverageMap.new

            TestBench::DetectCoverage.(*test_paths) do |invocation|
              coverage_map.method_invoked(invocation)
            end

            coverage_map
          end
        end
      end
    end
  end
end
