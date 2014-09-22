class AddRegionIdToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :region_id, :integer
  end
end
