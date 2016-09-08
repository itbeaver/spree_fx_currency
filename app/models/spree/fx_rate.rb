module Spree
  class FxRate < Spree::Base
    def self.create_supported_currencies
      currencies = Spree::Config.supported_currencies.split(', ')
      currencies.each { |c| find_or_create_by(currency: c.upcase) }
    end
  end
end
