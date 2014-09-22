class CreateFirstProducts < ActiveRecord::Migration
  def change
    create_table :first_products do |t|
      t.float :price
      t.date :date_of_price
      t.boolean :is_completed
      t.date :date_completed
      t.boolean :is_delivered

      t.timestamps
    end
  end
end
