Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :fx_rates do
      collection do
        get :fetch_all
      end

      member do
        get :fetch
      end
    end
  end
end
