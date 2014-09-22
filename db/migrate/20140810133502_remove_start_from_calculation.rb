class RemoveStartFromCalculation < ActiveRecord::Migration
  def change
    remove_column :calculations, :start, :integer
  end
end
