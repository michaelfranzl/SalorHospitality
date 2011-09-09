require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  setup do
    @reservation = reservations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reservations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reservation" do
    assert_difference('Reservation.count') do
      post :create, :reservation => @reservation.attributes
    end

    assert_redirected_to reservation_path(assigns(:reservation))
  end

  test "should show reservation" do
    get :show, :id => @reservation.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @reservation.to_param
    assert_response :success
  end

  test "should update reservation" do
    put :update, :id => @reservation.to_param, :reservation => @reservation.attributes
    assert_redirected_to reservation_path(assigns(:reservation))
  end

  test "should destroy reservation" do
    assert_difference('Reservation.count', -1) do
      delete :destroy, :id => @reservation.to_param
    end

    assert_redirected_to reservations_path
  end
end
