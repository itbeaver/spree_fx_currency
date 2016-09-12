module Spree
  class FxRate < Spree::Base
    validates :from_currency, presence: true
    validates :to_currency, presence: true

    validates :rate, numericality: {
      greater_than_or_equal_to: 0
    }

    after_save :update_all_prices

    def self.create_supported_currencies
      return unless table_exists?
      main_currency = Spree::Config.currency
      currencies = Spree::Config.supported_currencies.try(:split, ', ') || []
      ids = currencies.reject { |c| main_currency.to_s == c.upcase }.map do |c|
        find_or_create_by(
          from_currency: main_currency, to_currency: c.upcase
        ).id
      end
      where.not(id: ids).destroy_all if ids.present?
      fetch_fixer if Rails.env.production?
    end

    def self.fetch_fixer
      base = Spree::Config.currency
      symbols = pluck(:to_currency).map(&:upcase).join(',')
      uri = URI("http://api.fixer.io/latest?base=#{base}&symbols=#{symbols}")
      response = Net::HTTP.get(uri)
      parsed_response = JSON.parse(response)
      return false if parsed_response['rates'].blank?
      parsed_response['rates'].each do |currency, value|
        find_by(to_currency: currency).try(:update_attributes, rate: value)
      end
      true
    end

    def fetch_fixer
      base = from_currency.upcase
      symbol = to_currency.upcase
      uri = URI("http://api.fixer.io/latest?base=#{base}&symbols=#{symbol}")
      response = Net::HTTP.get(uri)
      parsed_response = JSON.parse(response)
      new_rate = parsed_response['rates'].try(:[], symbol)
      update_attributes(rate: new_rate)
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
      from_price = product.price_in(from_currency.upcase)

      return if from_price.new_record?

      new_price = product.price_in(to_currency.upcase)
      new_price.amount = from_price.amount * rate
      new_price.save if new_price.changed?
    end
  end
end
