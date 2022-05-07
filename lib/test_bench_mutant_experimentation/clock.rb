module TestBenchMutantExperimentation
  module Clock
    # mutant:disable
    def self.configure(receiver)
      receiver.clock = ::Time
    end

    module Substitute
      def self.build
        Clock.new
      end

      class Clock
        attr_accessor :now
      end
    end
  end
end
