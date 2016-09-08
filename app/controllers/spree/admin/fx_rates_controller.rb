module Spree
  module Admin
    class FxRatesController < ResourceController
      def create_supported_currencies
        Spree::FxRate.create_supported_currencies

        redirect_to :admin_fx_rates
      end
    end
  end
end
