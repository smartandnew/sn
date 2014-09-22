class AddCountryIdToGovernorate < ActiveRecord::Migration
  def change
    add_column :governorates, :country_id, :integer
  end
end
