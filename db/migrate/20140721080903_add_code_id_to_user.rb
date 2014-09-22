class AddCodeIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :code_id, :integer
  end
end
