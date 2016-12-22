class FixerClient
  attr_reader :uri

  def initialize(base, symbols)
    symbols_formatted = [*symbols].select { |s| s.is_a? String }.map(&:upcase).join(',')
    raise ArgumentError, 'Symbols are blank' if symbols_formatted.blank?
    raise ArgumentError, 'Base currency is blank' if base.blank?
    base_formatted = base.upcase
    @uri = URI(
      "http://api.fixer.io/latest?base=#{base_formatted}&symbols=#{symbols_formatted}"
    )
  end

  def fetch
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)
    return if parsed_response['rates'].blank?
    rates = parsed_response['rates']
    rates.count == 1 ? rates.first[1] : rates
  rescue StandardError => _e
    nil
  end
end
