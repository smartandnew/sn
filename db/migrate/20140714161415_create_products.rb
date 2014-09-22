class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.float :price
      t.text :description
      t.integer :quantity
      t.float :real_price
      t.float :offer
      t.date :offer_expired_date

      t.timestamps
    end
  end
end
