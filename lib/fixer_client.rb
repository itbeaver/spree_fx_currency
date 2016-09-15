class FixerClient
  attr_reader :uri

  def initialize(base_raw, symbols_raw)
    symbols = symbols_raw.map(&:upcase).join(',')
    base = base_raw.upcase
    @uri = URI("http://api.fixer.io/latest?base=#{base}&symbols=#{symbols}")
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
