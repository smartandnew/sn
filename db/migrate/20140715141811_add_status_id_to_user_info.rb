class AddStatusIdToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :status_id, :integer
  end
end
