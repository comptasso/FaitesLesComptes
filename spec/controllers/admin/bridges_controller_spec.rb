require 'spec_helper'

describe Admin::BridgesController do
  include SpecControllerHelper
    
  before(:each) do
    minimal_instances
    sign_in(@cu)
    @o.stub(:bridge).and_return 'bonjour'
  end
  
  
  describe "GET 'show'" do
    it "returns http success" do
      get :show, {:organism_id=>@o.id.to_s}, valid_session
      response.should be_success
    end
    
    it 'assigns bridge' do
      
      get :show, {:organism_id=>@o.id.to_s}, valid_session
      assigns[:bridge].should == 'bonjour'
    end
  end

end
