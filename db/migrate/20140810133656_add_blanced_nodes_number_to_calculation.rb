class AddBlancedNodesNumberToCalculation < ActiveRecord::Migration
  def change
    add_column :calculations, :blanced_nodes_number, :integer
  end
end
