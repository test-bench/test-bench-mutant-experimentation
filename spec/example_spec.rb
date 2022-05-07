require_relative 'spec_init'

RSpec.describe Example do
  let(:example) do
    Example.new
  end

  let(:now) do
    Time.utc(2000, 1, 1, 11, 11, 11)
  end

  before do
    example.clock.now = now
  end

  specify "Number is divisible by 3 and 5" do
    number = 15
    control_result = "FizzBuzz"

    result = example.(number)

    expect(result).to eq(control_result)
  end

  specify "Number is divisible by 5" do
    number = 10
    control_result = "Buzz"

    result = example.(number)

    expect(result).to eq(control_result)
  end

  specify "Number is divisible by 3" do
    number = 6
    control_result = "Fizz"

    result = example.(number)

    expect(result).to eq(control_result)
  end

  specify "Number is divisible by neither 3 nor 5" do
    number = 7
    control_result = now.iso8601

    result = example.(number)

    expect(result).to eq(control_result)
  end
end
