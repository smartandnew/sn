class AddIsDeliveredToSale < ActiveRecord::Migration
  def change
    add_column :sales, :is_delivered, :boolean
  end
end
