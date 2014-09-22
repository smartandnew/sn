class Region < ActiveRecord::Base
  attr_accessor :country_id
  belongs_to :governorate
  has_many :user_infos
  validates :name, :presence=> true
  validates :governorate_id,:presence=>true
  GOVERNORATES =Governorate.pluck(:name)
end
