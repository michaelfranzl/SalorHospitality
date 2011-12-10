require 'test_helper'

class PartialsControllerTest < ActionController::TestCase
  test "should get delete" do
    get :delete
    assert_response :success
  end

  test "should get update" do
    get :update
    assert_response :success
  end

end
