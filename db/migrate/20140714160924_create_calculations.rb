class CreateCalculations < ActiveRecord::Migration
  def change
    create_table :calculations do |t|
      t.integer :start
      t.integer :max_out
      t.integer :renew
      t.float :user_profit
      t.float :first_year
      t.float :minimum_product_price

      t.timestamps
    end
  end
end
