require 'date'

class Cheque < ActiveRecord::Base
  belongs_to :user
  validates :value ,:presence=>true
  validates :date,:presence=>true
  validates :user_id,:presence=>true

  after_create :credit_update
  def credit_update
    calculations=Calculation.first
    user=User.find_by(:id=>self.user_id)
    node=Tree.find_by(:id=>self.user_id)
    now = Date.today
    seven_days_ago = (now -7)
    cheques=Cheque.where("date >= :start_date AND date <= :end_date And user_id = :user_id",
    {start_date: seven_days_ago, end_date: now,user_id: self.user_id})
    puts  "cheque user_id= #{user.id} count= #{cheques.count}"
    if cheques.count <=calculations.max_out
      puts "check cheque count #{node.total_cheque_count}"
      if (node.total_cheque_count % calculations.number_of_product_credit_cheques_)==0 && user.master_credit >0
      user.product_credit+= self.value
      else
        old_master=user.master_credit
        user.master_credit+= self.value
        if old_master<0 && user.master_credit>=0
          first_product=FirstProduct.find_by_user_id(user.id)
          if first_product
            first_product.update_attribute(:is_completed ,true)
            Thread.new do
              user_info=UserInfo.find_by_user_id(user.id)
              first_product=FirstProduct.find_by_user_id(user.id)
              product=Product.find(first_product.product_id)
              UserMailer.confirm_first_product(user_info.email, product).deliver
            end

          end
        end
      end
      user.update_attribute(:product_credit, user.product_credit)
      user.update_attribute(:master_credit, user.master_credit)
    end

  end
end

