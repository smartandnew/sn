class Governorate < ActiveRecord::Base
  # attr_accessor :country_name
  belongs_to :country
  has_many :regions
  validates :name, :presence => true, :length => {:maximum => 60}
  validates :country_id,:presence=>true
  COUNTRIES=Country.pluck(:name)
end
