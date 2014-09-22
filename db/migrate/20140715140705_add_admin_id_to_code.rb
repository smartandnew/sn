class AddAdminIdToCode < ActiveRecord::Migration
  def change
    add_column :codes, :admin_id, :integer
  end
end
