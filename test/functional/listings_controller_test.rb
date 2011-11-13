require 'test_helper'

class ListingsControllerTest < ActionController::TestCase
  setup do
    @listing = listings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:listings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create listing" do
    assert_difference('Listing.count') do
      post :create, listing: @listing.attributes
    end

    assert_redirected_to listing_path(assigns(:listing))
  end

  test "should show listing" do
    get :show, id: @listing.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @listing.to_param
    assert_response :success
  end

  test "should update listing" do
    put :update, id: @listing.to_param, listing: @listing.attributes
    assert_redirected_to listing_path(assigns(:listing))
  end

  test "should destroy listing" do
    assert_difference('Listing.count', -1) do
      delete :destroy, id: @listing.to_param
    end

    assert_redirected_to listings_path
  end
end
