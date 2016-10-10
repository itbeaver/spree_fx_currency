Spree::Product.class_eval do
  after_create :update_prices

  def update_prices
    Spree::FxRate.all.each { |r| r.update_prices_for_product(self) }
  end
end
