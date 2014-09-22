class CreateTrees < ActiveRecord::Migration
  def change
    create_table :trees do |t|
      t.integer :parent
      t.integer :left
      t.integer :right
      t.integer :virtual_right_count
      t.integer :virtual_left_count
      t.integer :total_left
      t.integer :total_right
      t.integer :virtual_credit
      t.integer :total_cheque_count
      t.integer :level

      t.timestamps
    end
  end
end
