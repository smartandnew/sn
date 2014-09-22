class CreateUserInfos < ActiveRecord::Migration
  def change
    create_table :user_infos do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.text :address1
      t.text :address2
      t.integer :mobile
      t.integer :land_phone
      t.integer :postal_code
      t.integer :national_id
      t.float :longtude
      t.float :latitude
      t.boolean :gender
      t.date :birthdate
      t.string :image_url

      t.timestamps
    end
  end
end
