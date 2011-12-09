require 'test_helper'

class CheckDepositsControllerTest < ActionController::TestCase
  setup do
    @check_deposit = check_deposits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:check_deposits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create check_deposit" do
    assert_difference('CheckDeposit.count') do
      post :create, check_deposit: @check_deposit.attributes
    end

    assert_redirected_to check_deposit_path(assigns(:check_deposit))
  end

  test "should show check_deposit" do
    get :show, id: @check_deposit.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @check_deposit.to_param
    assert_response :success
  end

  test "should update check_deposit" do
    put :update, id: @check_deposit.to_param, check_deposit: @check_deposit.attributes
    assert_redirected_to check_deposit_path(assigns(:check_deposit))
  end

  test "should destroy check_deposit" do
    assert_difference('CheckDeposit.count', -1) do
      delete :destroy, id: @check_deposit.to_param
    end

    assert_redirected_to check_deposits_path
  end
end
