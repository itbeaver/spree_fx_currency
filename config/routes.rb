Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :fx_rates do
      member do
        get :update_all_prices
      end

      collection do
        get :create_supported_currencies
      end
    end
  end
end
