require 'spec_helper'

describe Admin::VersionsController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'migrate'" do
    it "returns http success" do
      get 'migrate'
      response.should be_success
    end
  end

end
