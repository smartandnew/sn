class AddCodeIdToExpense < ActiveRecord::Migration
  def change
    add_column :expenses, :code_id, :integer
  end
end
