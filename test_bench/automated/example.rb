require_relative 'automated_init'

context "Example" do
  example = Example.new

  now = Time.utc(2000, 1, 1, 11, 11, 11)
  example.clock.now = now

  context "Number is divisible by 3 and 5" do
    number = 15
    control_result = "FizzBuzz"

    result = example.(number)

    comment result
    detail "Control: #{control_result.inspect}"

    test do
      assert(result == control_result)
    end
  end

  context "Number is divisible by 5" do
    number = 10
    control_result = "Buzz"

    result = example.(number)

    comment result
    detail "Control: #{control_result.inspect}"

    test do
      assert(result == control_result)
    end
  end

  context "Number is divisible by 3" do
    number = 6
    control_result = "Fizz"

    result = example.(number)

    comment result
    detail "Control: #{control_result.inspect}"

    test do
      assert(result == control_result)
    end
  end

  context "Number is divisible by neither 3 nor 5" do
    number = 7
    control_result = now.iso8601

    result = example.(number)

    comment result
    detail "Control: #{control_result.inspect}"

    test do
      assert(result == control_result)
    end
  end
end
