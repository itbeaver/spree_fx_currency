Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :fx_rates do
      collection do
        post 'create_supported_currencies'
      end
    end
  end
end
