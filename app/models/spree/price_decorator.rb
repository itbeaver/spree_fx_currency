Spree::Price.class_eval do
  def amount
    currency_rate = Spree::FxRate.find_by(currency: currency).try(:rate) || 1
    self[:amount] * currency_rate
  end
end
