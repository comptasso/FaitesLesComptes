require 'test_helper'

class OrganismsControllerTest < ActionController::TestCase
  setup do
    @organism = organisms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organisms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create organism" do
    assert_difference('Organism.count') do
      post :create, organism: @organism.attributes
    end

    assert_redirected_to organism_path(assigns(:organism))
  end

  test "should show organism" do
    get :show, id: @organism.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @organism.to_param
    assert_response :success
  end

  test "should update organism" do
    put :update, id: @organism.to_param, organism: @organism.attributes
    assert_redirected_to organism_path(assigns(:organism))
  end

  test "should destroy organism" do
    assert_difference('Organism.count', -1) do
      delete :destroy, id: @organism.to_param
    end

    assert_redirected_to organisms_path
  end
end
