defmodule PasswordGenerator do
  @moduledoc """
  Module to generate passwords
  """

  @type options :: %{
          :length => non_neg_integer(),
          :numbers => boolean,
          :uppercase => boolean,
          :symbols => boolean
        }

  @allowed_keys [:length, :numbers, :uppercase, :symbols]

  @doc """
  Generates a password based on the options provided
  Options:
    - length: integer
    - numbers: boolean
    - uppercase: boolean
    - symbols: boolean
  """
  @spec generate(options :: options) :: {:ok, bitstring()} | {:error, bitstring()}
  def generate(options) do
    options =
      options
      |> Map.put_new(:length, 10)
      |> Map.put_new(:numbers, false)
      |> Map.put_new(:uppercase, false)
      |> Map.put_new(:symbols, false)

    #  verify if has option not allowed
    options_keys = Map.keys(options)

    unless Enum.any?(options_keys, fn key -> key not in @allowed_keys end) do
      case options do
        %{length: length} when not is_integer(length) ->
          {:error, "Length must be an integer"}

        %{length: length} when length < 6 ->
          {:error, "Length must be greater or equals than 5"}

        %{numbers: numbers} when not is_boolean(numbers) ->
          {:error, "Numbers must be a boolean"}

        %{uppercase: uppercase} when not is_boolean(uppercase) ->
          {:error, "Uppercase must be a boolean"}

        %{symbols: symbols} when not is_boolean(symbols) ->
          {:error, "Symbols must be a boolean"}

        %{length: _, numbers: _, uppercase: _, symbols: _} ->
          generate_password(options)

        _ ->
          {:error, "Invalid options"}
      end
    else
      {:error, "Invalid options"}
    end
  end

  @spec generate_password(options :: options()) :: {:ok, bitstring()}
  defp generate_password(options) do
    length = options.length
    numbers = options.numbers
    uppercase = options.uppercase
    symbols = options.symbols

    possible_characters =
      [
        {"abcdefghijklmnopqrstuvwxyz", true},
        {"0123456789", numbers},
        {"ABCDEFGHIJKLMNOPQRSTUVWXYZ", uppercase},
        {"!#$%&()*+,-./:;<=>?@[]^_{|}~", symbols}
      ]
      |> Enum.filter(fn {_, include?} -> include? end)
      |> Enum.map(fn {chars, _} -> chars end)
      |> Enum.join()

    password =
      possible_characters
      |> String.graphemes()
      |> Enum.shuffle()
      |> Enum.take(length)
      |> Enum.join()

    valid_password =
      verify_password(password, options)

    if valid_password do
      {:ok, password}
    else
      generate_password(options)
    end
  end

  @spec verify_password(password :: String.t(), options :: options()) :: boolean()
  def verify_password(password, options) do
    [
      has_lowercase?(password),
      has_numbers?(password),
      has_uppercase?(password),
      has_symbols?(password)
    ]
    |> Enum.zip([true, options.numbers, options.uppercase, options.symbols])
    |> Enum.all?(fn {result, expected} -> result == expected end)
  end

  @spec has_numbers?(String.t()) :: boolean()
  defp has_numbers?(password) do
    String.contains?(password, Enum.map(?0..?9, &<<&1>>))
  end

  @spec has_lowercase?(String.t()) :: boolean()
  defp has_lowercase?(password) do
    String.contains?(password, Enum.map(?a..?z, &<<&1>>))
  end

  @spec has_uppercase?(String.t()) :: boolean()
  defp has_uppercase?(password) do
    String.contains?(password, Enum.map(?A..?Z, &<<&1>>))
  end

  @spec has_symbols?(String.t()) :: boolean()
  defp has_symbols?(password) do
    String.contains?(password, String.split("!#$%&()*+,-./:;<=>?@[]^_{|}~", "", trim: true))
  end
end
