module Spree
  module Admin
    class FxRatesController < ResourceController
      after_action :update_all_prices, only: [:update, :create]

      def fetch_all
        if Spree::FxRate.fetch_fixer
          flash[:notice] = 'Rates was successfuly fetched'
        else
          flash[:alert] = 'Something was wrong'
        end
        redirect_to :admin_fx_rates
      end

      def fetch
        if @fx_rate.fetch_fixer
          flash[:notice] = 'Rate was successfuly fetched'
        else
          flash[:alert] = 'Something was wrong'
        end
        redirect_to :admin_fx_rates
      end

      private

      def update_all_prices
        @fx_rate.update_all_prices
      end
    end
  end
end
