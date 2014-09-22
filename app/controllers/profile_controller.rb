class ProfileController < ApplicationController
  include SessionHelper
  before_filter :authenticate

  def index
    @user=User.find_by_id(session[:user_id])
    if session[:parent_id]==nil
      session[:parent_id]=session[:user_id]
    end
    generated_code
    update_tree
  end

  def generated_code
    @user=User.find_by_id(session[:user_id])
    @expenses=Expense.where("user_id=? and code_id!=?", @user.id, "")
    @codes=Array.new
    for n in 0...@expenses.length
      code=Code.find_by_id(@expenses[n].code_id)
      if code!=nil &&code.valid
        @codes.push(code)
      end
    end
    return @codes
  end

  def generate_code
    if User.authenticate(session[:user_name],_logged_in_user_params[:user_conf_pass_for_gen_code])
      @code= Code.user_generate_code
      @user=User.find(session[:user_id])
      master=@user.master_credit-@code.value
      if @user.update_attribute(:master_credit,master)
        @expenses=Expense.create!(:user_id=>@user.id,:code_id=>@code.id,:value=>@code.value,:date=>Time.now,:is_master=>true,:is_money=>false)
      end
      @codes=generated_code
      respond_to do |format|
          format.html
          format.js
          format.json
      end
      return
    else
      flash.now[:error]="Invalid password"
      @codes=generated_code
      respond_to do |format|
          format.html
          format.js
          format.json
      end
      return
    end
  end

  def get_right
    @parent=Tree.find(session[:parent_id])
    if @parent.right!=0
      @right=Tree.find(@parent.right)
      session[:parent_id]=@right.id
    end
    update_tree
  end

  def get_parent
    @parent=Tree.find(session[:parent_id])
    if @parent.id!=session[:user_id]
      @super_parent=Tree.find(@parent.parent)
      session[:parent_id]=@super_parent.id
    end
    update_tree
  end

  def get_left
    @parent=Tree.find(session[:parent_id])
    if @parent.left!=0
      @left=Tree.find(@parent.left)
      session[:parent_id]= @left.id
    end
    update_tree
  end

  def update_tree
    @parent=nil
    @parent_user=nil
    @parent_user_info=nil

    @right=nil
    @right_user=nil
    @right_user_info=nil

    @left=nil
    @left_user=nil
    @left_user_info=nil

    @parent=Tree.find(session[:parent_id])
    @parent_user=User.find(session[:parent_id])
    @parent_user_info=UserInfo.find_by_user_id(session[:parent_id])

    if @parent.right!=0
      @right=Tree.find(@parent.right)
      @right_user=User.find(@parent.right)
      @right_user_info=UserInfo.find_by_user_id(@parent.right)
    end
    if @parent.left!=0
      @left=Tree.find(@parent.left)
      @left_user=User.find(@parent.left)
      @left_user_info=UserInfo.find_by_user_id(@parent.left)
    end
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end
  
def product_credit_order
    total_price=0;
    if session[:product_ids] != nil
      for i in 0...session[:product_ids].length
        pro_id=session[:product_ids].fetch(i)["product_id"]
        pro_counts=session[:product_ids].fetch(i)["count"]
        pro=Product.find(pro_id)
        total_price+=(pro.price*pro_counts)
      end
    else
      flash[:error]="You did not select any product"
      redirect_to profile_path
      return
    end
    product_sale=Array.new
    @user=User.find_by_id(session[:user_id])
    @user_info=UserInfo.find_by_user_id(@user.id)
    if @user.product_credit>=total_price
      sale=Sale.new(:date => Time.now, :customer_id => nil,:is_delivered=>false)
      if sale.save
        expenses = Expense.new(:date => Time.now, :code_id => nil, :is_master => false, :is_money => false, :user_id => @user.id, :sale_id => sale.id, :value => 0)
        if expenses.save
          for p in 0...session[:product_ids].length
            product_id_= session[:product_ids].fetch(p)["product_id"]
            count=session[:product_ids].fetch(p)["count"]
            product=Product.find_by_id(product_id_)
            ProductHasSale.create!(:sale_id => sale.id, :product_id => product.id, :price => product.price, :real_price => product.real_price, :amount => count)
            # product.quantity= product.quantity-count
            if product.update_attribute(:quantity, product.quantity-count)
              product_money=(count*product.price)
              @user.update_attribute(:product_credit, (@user.product_credit-product_money))
              expenses.update_attribute(:value, (expenses.value+product_money))
              product_sale.push({:prodduct_name=>product.name,:quantity=>count,:price=>product.price})

            end
          end
          session[:product_ids]=nil
          Thread.new do
            puts "sent email"
            begin
           UserMailer.confirm_order_mail_user(@user_info,product_sale).deliver
            rescue Exception => e

            end
          end
          flash[:success]="Checkout completed succesffully and email sent to #{@user_info.email} "
          redirect_to profile_path
        else
          Sale.delete(sale.id)
          flash[:error]="Sorry you an error occure please try again later"
          redirect_to profile_path
          return

        end
      else
        flash[:error]="Sorry you an error occure please try again later sale"
        redirect_to profile_path
        return
      end
      session[:product_ids]=nil
    else
      flash[:error]="Sorry you have not enough product credit"
      session[:product_ids]=nil
      redirect_to profile_path
    end
  end



  def _logged_in_user_params
    params.require(:user).permit(:user_conf_pass_for_gen_code)
  end

end
