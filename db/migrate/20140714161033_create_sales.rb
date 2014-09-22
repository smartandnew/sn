class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.date :date

      t.timestamps
    end
  end
end
