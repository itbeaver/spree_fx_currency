Spree::Variant.class_eval do
  after_save :update_prices

  def update_prices
    Spree::FxRate.all.each { |r| r.update_prices_for_variant(self) }
  end
end
