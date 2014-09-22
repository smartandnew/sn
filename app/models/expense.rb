class Expense < ActiveRecord::Base
  belongs_to :code
  belongs_to :user
  belongs_to :sale

  validates :date ,:presence=>true
  validates :value,:presence=>true
  validates :user_id,:presence=>true
end
