class CreateProductHasSales < ActiveRecord::Migration
  def change
    create_table :product_has_sales do |t|
      t.integer :product_id
      t.integer :sale_id
      t.float :price
      t.float :real_price
      t.integer :amount

      t.timestamps
    end
  end
end
