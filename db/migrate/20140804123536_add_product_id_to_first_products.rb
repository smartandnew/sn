class AddProductIdToFirstProducts < ActiveRecord::Migration
  def change
    add_column :first_products, :product_id, :integer
  end
end
