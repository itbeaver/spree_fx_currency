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
        proccess_master(product)
        proccess_variants(product)
      end
    end

    private

    def proccess_variants(product)
      product.variants.each do |variant|
        from_price = variant.price_in(from_currency.upcase)
        next if from_price.new_record?
        new_price = variant.price_in(to_currency.upcase)
        new_price.amount = from_price.amount * rate
        new_price.save if new_price.changed?
      end
    end

    def proccess_master(product)
      from_price = if from_currency.blank?
                     product.master.price
                   else
                     product.price_in(from_currency.upcase)
                   end

      return if from_price.new_record?

      new_price = product.price_in(to_currency.upcase)
      new_price.amount = from_price.amount * rate
      new_price.save if new_price.changed?
    end
  end
end
