class Country < ActiveRecord::Base
  has_many :governorates
  validates :name, :presence=>true,:length =>{:maximum=>60},
  :uniqueness=> {:case_sensitive => false}
end
