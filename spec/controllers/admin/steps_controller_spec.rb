require 'spec_helper'

describe Admin::StepsController do

  describe "GET 'show'" do
    it "returns http success" do 
      get 'show'
      response.should be_success
    end
 
    it 'assign step with 1' do
      get 'show'
      assigns[:step].should == 1
      assigns[:organism].should be_an_instance_of(Organism)
    end
  end

  describe "GET 'new'" do
    it "returns http success" do 
      get 'new' 
      response.should be_success
    end
  end

end
