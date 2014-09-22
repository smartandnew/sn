require 'test_helper'

class StoreControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get add_category" do
    get :add_category
    assert_response :success
  end

  test "should get add_sub_category" do
    get :add_sub_category
    assert_response :success
  end

  test "should get add_product" do
    get :add_product
    assert_response :success
  end

end
