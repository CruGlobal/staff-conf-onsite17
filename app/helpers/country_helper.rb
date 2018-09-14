module CountryHelper
  # The country to appear at the very top of the selection list.
  FIRST_CODE = 'US'.freeze

  # @return [Array<[name, code]>] a map of country names and their two-letter,
  #   ISO 3166-1 country code
  def country_select
    @country_select =
      begin
        countries = ISO3166::Country.translations.dup
        first_name = countries.delete(FIRST_CODE)

        countries.
          map { |code, name| [name, code] }.
          tap { |c| c.unshift([first_name, FIRST_CODE], ['---', nil]) }
      end
  end

  # @return [String] the name of the country corresponding to the given
  #   two-letter, ISO 3166-1 country code
  def country_name(code)
    ISO3166::Country.translations[code]
  end
end
