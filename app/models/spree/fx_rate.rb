module Spree
  class FxRate < Spree::Base
    def self.create_supported_currencies
      return unless table_exists?
      main_currency = Spree::Config.currency
      supported_currencies = Spree::Config.supported_currencies
      return if supported_currencies.blank?
      currencies = supported_currencies.split(', ')
      currencies.each do |c|
        find_or_create_by(from_currency: main_currency, to_currency: c.upcase)
      end
    end
  end
end
