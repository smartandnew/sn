class AddGovernorateIdToRegion < ActiveRecord::Migration
  def change
    add_column :regions, :governorate_id, :integer
  end
end
