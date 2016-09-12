FactoryGirl.define do
  # Define your Spree extensions Factories within this file to enable applications,
  # and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_fx_currency/factories'

  factory :fx_rate, class: Spree::FxRate do
    from_currency 'USD'
    to_currency 'EUR'
    rate 1.0
  end
end
