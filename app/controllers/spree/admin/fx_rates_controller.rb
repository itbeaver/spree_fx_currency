module Spree
  module Admin
    class FxRatesController < ResourceController
      # after_action :update_all_prices, only: [:update, :create]

      def create_supported_currencies
        Spree::FxRate.create_supported_currencies

        redirect_to :admin_fx_rates
      end

      def update_all_prices
        @fx_rate.update_all_prices

        redirect_to :admin_fx_rates
      end
    end
  end
end
