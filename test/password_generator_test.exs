defmodule PasswordGeneratorTest do
  use ExUnit.Case
  doctest PasswordGenerator

  setup do
    options = %{
      :length => 10,
      :numbers => false,
      :uppercase => false,
      :symbols => false
    }

    options_type = %{
      lowercase: Enum.map(?a..?z, &<<&1>>),
      numbers: Enum.map(?0..?9, &<<&1>>),
      uppercase: Enum.map(?A..?Z, &<<&1>>),
      symbols: String.split("!#$%&()*+,-./:;<=>?@[]^_{|}~", "", trim: true)
    }

    {:ok, result} = PasswordGenerator.generate(options)

    %{
      options_type: options_type,
      result: result
    }
  end

  test "returns a string", %{result: result} do
    assert is_bitstring(result)
  end

  test "returns error when no length is provided" do
    options = %{"invalid" => "false"}
    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns error when length is not an integer" do
    options = %{"length" => "ab"}
    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns error when length is less than 1" do
    options = %{:length => 0}
    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "lenght of returned string is the option provided" do
    options = %{:length => 6}
    {:ok, result} = PasswordGenerator.generate(options)
    assert 6 == String.length(result)
  end

  test "returns a lowercase string just with the length", %{options_type: options} do
    length_option = %{:length => 6}

    {:ok, result} = PasswordGenerator.generate(length_option)

    assert String.contains?(result, options.lowercase)

    refute String.contains?(result, options.numbers)
    refute String.contains?(result, options.uppercase)
    refute String.contains?(result, options.symbols)
  end

  test "returns a lowercase string with numbers", %{options_type: options} do
    options_with_number = %{
      :length => 6,
      :numbers => true
    }

    {:ok, result} = PasswordGenerator.generate(options_with_number)

    assert String.contains?(result, options.lowercase)
    assert String.contains?(result, options.numbers)

    refute String.contains?(result, options.uppercase)
    refute String.contains?(result, options.symbols)
  end

  test "returns a lowercase string with uppercase", %{options_type: options} do
    options_with_uppercase = %{
      :length => 6,
      :uppercase => true
    }

    {:ok, result} = PasswordGenerator.generate(options_with_uppercase)

    assert String.contains?(result, options.lowercase)
    assert String.contains?(result, options.uppercase)

    refute String.contains?(result, options.numbers)
    refute String.contains?(result, options.symbols)
  end

  test "returns a lowercase string with symbols", %{options_type: options} do
    options_with_symbols = %{
      :length => 6,
      :symbols => true
    }

    {:ok, result} = PasswordGenerator.generate(options_with_symbols)

    assert String.contains?(result, options.lowercase)
    assert String.contains?(result, options.symbols)

    refute String.contains?(result, options.numbers)
    refute String.contains?(result, options.uppercase)
  end

  test "returns a lowercase string with numbers, uppercase and symbols", %{options_type: options} do
    options_with_all = %{
      :length => 10,
      :numbers => true,
      :uppercase => true,
      :symbols => true
    }

    {:ok, result} = PasswordGenerator.generate(options_with_all)

    assert String.contains?(result, options.lowercase)
    assert String.contains?(result, options.numbers)
    assert String.contains?(result, options.uppercase)
    assert String.contains?(result, options.symbols)
  end

  test "returns error when options values are note booleans" do
    options = %{
      "length" => 10,
      "numbers" => "invalid",
      "uppercase" => "0",
      "symbols" => "false"
    }

    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns error when options not allowed" do
    options = %{
      "length" => "5",
      "invalid" => "true"
    }

    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns error when 1 option not allowed" do
    options = %{
      "length" => "5",
      "numbers" => "true",
      "invalid" => "true"
    }

    assert {:error, _error} = PasswordGenerator.generate(options)
  end
end
