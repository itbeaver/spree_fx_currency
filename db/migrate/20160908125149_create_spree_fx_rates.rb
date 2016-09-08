class CreateSpreeFxRates < ActiveRecord::Migration
  def change
    create_table :spree_fx_rates do |t|
      t.string :currency
      t.decimal :value, precision: 10, scale: 2, default: 1.00

      t.timestamps null: false
    end
  end
end
