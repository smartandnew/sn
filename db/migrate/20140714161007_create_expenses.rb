class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.date :date
      t.float :value
      t.boolean :is_master
      t.boolean :is_money

      t.timestamps
    end
  end
end
