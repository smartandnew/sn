require 'securerandom'

class Code < ActiveRecord::Base
  belongs_to :admin
  has_one :expense
  validates :code, :presence => true, :length => {:in => 10..30},
  :uniqueness=> {:case_sensitive => true}
  validates :date_released, :presence => true
  validates :expired_date, :presence => true
  validates :value,:presence => true
  has_one :user
  def self.user_generate_code
    begin
      code= SecureRandom.base64
      c=Code.find_by(:code=>code)
    end while c!=nil
    calculate=Calculation.first
    return cc=Code.create!(:code=>code,:date_released=>Time.now,:expired_date=>(Date.today+3.month),:value=>calculate.code_value,:valid=>true,:verify=>true)
  end
  
end
