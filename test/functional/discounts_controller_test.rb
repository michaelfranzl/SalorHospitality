require 'test_helper'

class DiscountsControllerTest < ActionController::TestCase
  setup do
    @discount = discounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:discounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create discount" do
    assert_difference('Discount.count') do
      post :create, :discount => @discount.attributes
    end

    assert_redirected_to discount_path(assigns(:discount))
  end

  test "should show discount" do
    get :show, :id => @discount.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @discount.to_param
    assert_response :success
  end

  test "should update discount" do
    put :update, :id => @discount.to_param, :discount => @discount.attributes
    assert_redirected_to discount_path(assigns(:discount))
  end

  test "should destroy discount" do
    assert_difference('Discount.count', -1) do
      delete :destroy, :id => @discount.to_param
    end

    assert_redirected_to discounts_path
  end
end
