class AddIsFeaturedToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_featured, :boolean
  end
end
