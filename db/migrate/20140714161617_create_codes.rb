class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.string :code
      t.float :value
      t.date :date_released
      t.date :expired_date
      t.boolean :verify
      t.boolean :valid

      t.timestamps
    end
  end
end
