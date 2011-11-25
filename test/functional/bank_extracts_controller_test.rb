require 'test_helper'

class BankExtractsControllerTest < ActionController::TestCase
  setup do
    @bank_extract = bank_extracts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bank_extracts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bank_extract" do
    assert_difference('BankExtract.count') do
      post :create, bank_extract: @bank_extract.attributes
    end

    assert_redirected_to bank_extract_path(assigns(:bank_extract))
  end

  test "should show bank_extract" do
    get :show, id: @bank_extract.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bank_extract.to_param
    assert_response :success
  end

  test "should update bank_extract" do
    put :update, id: @bank_extract.to_param, bank_extract: @bank_extract.attributes
    assert_redirected_to bank_extract_path(assigns(:bank_extract))
  end

  test "should destroy bank_extract" do
    assert_difference('BankExtract.count', -1) do
      delete :destroy, id: @bank_extract.to_param
    end

    assert_redirected_to bank_extracts_path
  end
end
