class CreateSpreeFxRates < ActiveRecord::Migration
  def change
    create_table :spree_fx_rates do |t|
      t.string :currency
      t.float :rate, default: 1.00

      t.timestamps null: false
    end
  end
end
