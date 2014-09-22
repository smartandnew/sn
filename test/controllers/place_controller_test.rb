require 'test_helper'

class PlaceControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get add_country" do
    get :add_country
    assert_response :success
  end

  test "should get add_governorate" do
    get :add_governorate
    assert_response :success
  end

  test "should get add_region" do
    get :add_region
    assert_response :success
  end

end
