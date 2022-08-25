module TestBenchMutantExperimentation
  class Example
    module Logger
      # mutant:disable
      def logger
        @logger ||= ::Logger.new(STDERR)
      end
      attr_writer :logger
    end
  end
end
