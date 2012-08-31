require 'spec_helper'

describe BottomController do
  include SpecControllerHelper

  before(:each) do
    minimal_instances
  end
  

  describe "GET 'credit'" do
    it "returns http success" do
      get 'credit', {}, valid_session
      response.should be_success 
    end
  end

  describe "GET 'apropos'" do
    it "returns http success" do
      get 'apropos', {}, valid_session
      response.should be_success  
    end
  end

end
