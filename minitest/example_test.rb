require_relative 'minitest_init'

class ExampleTest < Minitest::Test
  def setup
    @now = Time.utc(2000, 1, 1, 11, 11, 11)

    @example = Example.new
    @example.clock.now = @now
  end

  def test_number_is_divisible_by_3_and_5
    number = 15
    control_result = "FizzBuzz"

    result = @example.(number)

    assert_equal(control_result, result)
  end

  def test_number_is_divisible_by_5
    number = 10
    control_result = "Buzz"

    result = @example.(number)

    assert_equal(control_result, result)
  end

  def test_number_is_divisible_by_3
    number = 6
    control_result = "Fizz"

    result = @example.(number)

    assert_equal(control_result, result)
  end

  def test_number_is_divisible_by_neither_3_nor_5
    number = 7
    control_result = @now.iso8601

    result = @example.(number)

    assert_equal(control_result, result)
  end
end
