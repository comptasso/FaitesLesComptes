require 'spec_helper'

describe BottomController do

  describe "GET 'credit'" do
    it "returns http success" do
      get 'credit'
      response.should be_success
    end
  end

  describe "GET 'apropos'" do
    it "returns http success" do
      get 'apropos'
      response.should be_success
    end
  end

end
