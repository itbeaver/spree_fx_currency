Spree::Admin::GeneralSettingsController.class_eval do
  after_action :create_fx_rates_for_currencies, only: :update

  def create_fx_rates_for_currencies
    Spree::FxRate.create_supported_currencies
  end
end
