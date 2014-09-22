class Category < ActiveRecord::Base
  has_many :sub_categories
  attr_accessor :category_image
  validates :name, :presence=>true,:length =>{:maximum=>60},
            :uniqueness=> {:case_sensitive => false}
end
