require 'test_helper'

class NaturesControllerTest < ActionController::TestCase
  setup do
    @nature = natures(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:natures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nature" do
    assert_difference('Nature.count') do
      post :create, nature: @nature.attributes
    end

    assert_redirected_to nature_path(assigns(:nature))
  end

  test "should show nature" do
    get :show, id: @nature.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nature.to_param
    assert_response :success
  end

  test "should update nature" do
    put :update, id: @nature.to_param, nature: @nature.attributes
    assert_redirected_to nature_path(assigns(:nature))
  end

  test "should destroy nature" do
    assert_difference('Nature.count', -1) do
      delete :destroy, id: @nature.to_param
    end

    assert_redirected_to natures_path
  end
end
