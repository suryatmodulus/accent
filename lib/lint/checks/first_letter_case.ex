defmodule Accent.Lint.Checks.FirstLetterCase do
  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  def applicable(entry), do: !entry.is_master

  def check(entry) do
    value_has_first_letter = starts_with_letter?(entry.value)
    master_has_first_letter = starts_with_letter?(entry.master_value)
    value_capitalized = starts_with_capitalized_letter?(entry.value)
    master_capitalized = starts_with_capitalized_letter?(entry.master_value)

    cond do
      value_capitalized === master_capitalized ->
        []

      !master_has_first_letter or !value_has_first_letter ->
        []

      value_capitalized ->
        ["", first_letter, rest] = String.split(entry.value, "", parts: 3)
        fixed_text = String.downcase(first_letter) <> rest
        [to_message(entry, fixed_text)]

      master_capitalized ->
        fixed_text = String.capitalize(entry.value)
        [to_message(entry, fixed_text)]

      true ->
        []
    end
  end

  defp to_message(entry, fixed_text) do
    %Message{
      check: :first_letter_case,
      text: entry.value,
      replacement: %Replacement{value: fixed_text, label: fixed_text}
    }
  end

  defp starts_with_letter?(text) do
    Regex.match?(~r/^[\w]/i, text)
  end

  defp starts_with_capitalized_letter?(""), do: false

  defp starts_with_capitalized_letter?(text) do
    letter = String.first(text)
    String.capitalize(letter) === letter and String.downcase(letter) !== letter
  end
end
