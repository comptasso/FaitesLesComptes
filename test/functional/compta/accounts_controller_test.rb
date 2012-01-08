require 'test_helper'

class Compta::AccountsControllerTest < ActionController::TestCase
  setup do
    @compta_account = compta_accounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:compta_accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create compta_account" do
    assert_difference('Compta::Account.count') do
      post :create, compta_account: @compta_account.attributes
    end

    assert_redirected_to compta_account_path(assigns(:compta_account))
  end

  test "should show compta_account" do
    get :show, id: @compta_account.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @compta_account.to_param
    assert_response :success
  end

  test "should update compta_account" do
    put :update, id: @compta_account.to_param, compta_account: @compta_account.attributes
    assert_redirected_to compta_account_path(assigns(:compta_account))
  end

  test "should destroy compta_account" do
    assert_difference('Compta::Account.count', -1) do
      delete :destroy, id: @compta_account.to_param
    end

    assert_redirected_to compta_accounts_path
  end
end
