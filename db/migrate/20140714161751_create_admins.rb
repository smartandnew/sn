class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string :username
      t.string :password
      t.boolean :is_super_admin
      t.string :email
      t.integer :mobile
      t.string :first_name
      t.string :last_name
      t.text :address
      t.string :privilages

      t.timestamps
    end
  end
end
