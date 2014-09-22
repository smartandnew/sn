class CreateCheques < ActiveRecord::Migration
  def change
    create_table :cheques do |t|
      t.float :value
      t.date :date

      t.timestamps
    end
  end
end
