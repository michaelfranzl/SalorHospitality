require 'test_helper'

class RolesControllerTest < ActionController::TestCase
  setup do
    @role = roles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:roles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create role" do
    assert_difference('Role.count') do
      post :create, :role => @role.attributes
    end

    assert_redirected_to role_path(assigns(:role))
  end

  test "should show role" do
    get :show, :id => @role.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @role.to_param
    assert_response :success
  end

  test "should update role" do
    put :update, :id => @role.to_param, :role => @role.attributes
    assert_redirected_to role_path(assigns(:role))
  end

  test "should destroy role" do
    assert_difference('Role.count', -1) do
      delete :destroy, :id => @role.to_param
    end

    assert_redirected_to roles_path
  end
end
