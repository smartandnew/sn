class AddSaleIdToExpense < ActiveRecord::Migration
  def change
    add_column :expenses, :sale_id, :integer
  end
end
