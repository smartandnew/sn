class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.decimal :master_credit
      t.decimal :product_credit

      t.timestamps
    end
  end
end
