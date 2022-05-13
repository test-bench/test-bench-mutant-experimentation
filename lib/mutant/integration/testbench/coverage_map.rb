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

        def method_invoked(method_specifier, test_file)
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
          def coverage_map
            @coverage_map ||= CoverageMap.new
          end

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
            reader, writer = IO.pipe

            session = Testbench.session(output: true)

            child_process = fork do
              reader.close

              TestBench::Run.(session: session) do |run|
                current_test_file = nil

                TracePoint.trace(:call) do |trace_point|
                  trace_point(trace_point) do |method_specifier|
                    data = { test_file: current_test_file, method_specifier: method_specifier }

                    text = JSON.generate(data)
                    writer.puts(text)
                  end
                end

                test_paths.each do |test_path|
                  if File.directory?(test_path)
                    test_files = Dir[File.join(test_path, '**', '*.rb')]
                  else
                    test_files = [test_path]
                  end

                  test_files.each do |test_file|
                    current_test_file = test_file

                    run.file(test_file)
                  end
                end

                writer.puts

              ensure
                writer.close
              end
            end

            writer.close

            until reader.eof?
              text = reader.gets.chomp

              break if text.empty?

              data = JSON.parse(text, symbolize_names: true)

              method_specifier = data.fetch(:method_specifier)
              test_file = data.fetch(:test_file)

              coverage_map.method_invoked(method_specifier, test_file)
            end

            Process.wait(child_process)

            coverage_map
          end

          def trace_point(trace_point, &block)
            path = trace_point.path

            lib_dir = File.expand_path('lib')
            return unless path.start_with?(lib_dir)

            cls = trace_point.defined_class

            if cls.singleton_class?
              cls = ObjectSpace.each_object(Module).find do |mod|
                mod.singleton_class.equal?(cls)
              end

              scope_symbol = '.'
            else
              scope_symbol = '#'
            end

            class_name = cls.name

            toplevel_namespace, * = class_name.split('::')

            return if toplevel_namespace == 'TestBench'

            method_specifier = [
              class_name,           # SomeNamespace::SomeClass
              scope_symbol,         #                         .
              trace_point.method_id #                          some_method
            ]
            method_specifier = "#{class_name}#{scope_symbol}#{trace_point.method_id}"

            block.(method_specifier)
          end
        end
      end
    end
  end
end
