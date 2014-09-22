class AddCodeValueToCalculation < ActiveRecord::Migration
  def change
    add_column :calculations, :code_value, :integer
  end
end
