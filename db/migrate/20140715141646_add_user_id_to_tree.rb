class AddUserIdToTree < ActiveRecord::Migration
  def change
    add_column :trees, :user_id, :integer
  end
end
