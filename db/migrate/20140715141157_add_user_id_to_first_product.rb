class AddUserIdToFirstProduct < ActiveRecord::Migration
  def change
    add_column :first_products, :user_id, :integer
  end
end
