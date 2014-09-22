class SubCategory < ActiveRecord::Base
  # attr_accessor :category_name
  belongs_to :category
  attr_accessor :sub_category_image
  has_many :products
  validates :name, :presence => true, :length => {:maximum => 60}
  validates :category_id, :presence=>true
  CATEGORIES=Category.pluck(:name)
end
