module Mutant
  class Integration
    class Testbench
      class TraceMethodCalls
        def logger
          @logger ||= Logger.new(STDERR)
        end
        attr_writer :logger

        def session
          @session ||= Adapter.session
        end
        attr_writer :session

        def traced_methods
          @traced_methods ||= Set.new
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

          child_process = fork do
            TestBench::Run.(session: session) do |run|
              TracePoint.trace(:call) do |trace_point|
                trace_point(trace_point) do |method_text|
                  logger.info { "Traced method call: #{method_text.inspect}" }

                  writer.puts(method_text)
                end
              end

              test_paths.each do |path|
                run.path(path)
              end

              writer.puts
              writer.close
            end
          end

          until reader.eof?
            method = reader.gets.chomp

            break if method.empty?

            block.(method)
          end

          Process.wait(child_process)
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

          method_text = [
            class_name,           # SomeNamespace::SomeClass
            scope_symbol,         #                         .
            trace_point.method_id #                          some_method
          ]
          method_text = "#{class_name}#{scope_symbol}#{trace_point.method_id}"

          unless traced_methods.include?(method_text)
            traced_methods << method_text

            block.(method_text)
          end
        end
      end
    end
  end
end
