class CreateGovernorates < ActiveRecord::Migration
  def change
    create_table :governorates do |t|
      t.string :name

      t.timestamps
    end
  end
end
