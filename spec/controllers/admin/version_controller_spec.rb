require 'spec_helper'

describe Admin::VersionController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
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
