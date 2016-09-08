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

    # @todo: implement force option for only applying
    #        fx rate changes to blank prices
    def update_all_prices
      Spree::Product.all.each do |product|
        from_price = if from_currency.blank?
                       product.master.price
                     else
                       product.price_in(from_currency.upcase)
                     end
        raise 'from_price is new_record' if from_price.new_record?

        new_price = product.price_in(to_currency.upcase)
        new_price.amount = from_price.amount * rate
        new_price.save if new_price.changed?

        product.variants.each do |variant|
          new_price = variant.price_in(to_currency.upcase)
          new_price.amount = from_price.amount * rate
          new_price.save if new_price.changed?
        end
      end
    end
  end
end
