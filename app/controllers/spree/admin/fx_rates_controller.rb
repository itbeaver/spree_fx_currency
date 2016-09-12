module Spree
  module Admin
    class FxRatesController < ResourceController
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
    end
  end
end
