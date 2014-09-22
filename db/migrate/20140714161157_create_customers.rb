class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.integer :phone
      t.text :address
      t.string :email

      t.timestamps
    end
  end
end
