class Status < ActiveRecord::Base
  has_many :user_infos
  validates :name,  :presence => true, :length => {:maximum => 20}
end
