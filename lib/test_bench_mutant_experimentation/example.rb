module TestBenchMutantExperimentation
  class Example
    include Logger

    def clock
      @clock ||= Clock::Substitute.build
    end
    attr_writer :clock

    ## Needed for rspec/minitest
    # mutant:disable
    def self.build
      instance = new
      Clock.configure(instance)
      instance
    end

    def call(number)
      ## Uncomment when ignore patterns work
      #logger.debug { "Calculating result (Number: #{number.inspect})" }

      result = String.new

      if (number % 3).zero?
        result << "Fizz"
      end

      if (number % 5).zero?
        result << "Buzz"
      end

      if result.empty?
        now = clock.now

        result << now.iso8601
      end

      ## Uncomment when ignore patterns work
      #logger.info { "Calculated result (Number: #{number.inspect}, Result: #{result.inspect})" }

      result
    end
  end
end
