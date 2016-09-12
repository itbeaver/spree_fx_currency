namespace :spree_fx_currency do
  namespace :update do
    desc 'Updates all prices according to FX Rates'
    task prices: :environment do
      Spree::FxRate.all.each(&:update_all_prices)
      puts 'Done!'
    end

    desc 'Updates all rates from fixer.io'
    task rates: :environment do
      Spree::FxRate.fetch_fixer
      puts 'Done!'
    end

    desc 'Update supported_currencies'
    task currencies: :environment do
      Spree::FxRate.create_supported_currencies
      puts 'Done!'
    end
  end
end
