module TestBenchMutantExperimentation
  module Clock
    def self.configure(receiver)
      receiver.clock = ::Time
    end

    module Substitute
      def self.build
        Substitute::Clock.new
      end

      class Clock
        attr_accessor :now
      end
    end
  end
end
