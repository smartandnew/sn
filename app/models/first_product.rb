class FirstProduct < ActiveRecord::Base
  belongs_to :user
  validates :price ,:presence=>true
  validates :date_of_price ,:presence=>true
  validates :user_id,:presence=>true
  validates :product_id,:presence => true
end
