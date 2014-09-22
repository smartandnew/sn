module ProfileHelper
  def get_user_mail(user_id)
    return UserInfo.find_by_user_id(user_id).email
  end

  def get_buton_width
    parent_length= @parent_user.username.mb_chars.length
    if @right_user
      right_length= @right_user.username.mb_chars.length
    else
      right_length=0
    end
    if @left_user
      left_length= @left_user.username.mb_chars.length
    else
      left_length=0
    end

    width=0
    if parent_length>right_length&&parent_length>left_length
      width=parent_length*15
    elsif right_length>parent_length&&right_length>left_length
      width=right_length*15
    else
      width=left_length*15
    end
    return width
  end

  def is_first_product_completed?
    if FirstProduct.where("user_id=? and is_completed='t'", session[:user_id]).count >0
      return true
    end
    return false
  end
end
