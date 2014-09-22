class AddPasswordSaltToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :password_salt, :string
  end
end
