class AddPasswordHashToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :password_hash, :string
  end
end
