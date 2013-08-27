require 'spec_helper'

describe Admin::BridgesController do
  include SpecControllerHelper
    
  before(:each) do
    minimal_instances
    sign_in(@cu)
    
  end
  
  
  describe "GET 'show'" do 
    it "returns http success" do
      @o.stub(:bridge).and_return 'bonjour'
      get :show, {:organism_id=>@o.id.to_s}, valid_session
      response.should be_success
    end
    
    it 'assigns bridge' do
      @o.stub(:bridge).and_return 'bonjour'
      get :show, {:organism_id=>@o.id.to_s}, valid_session
      assigns[:bridge].should == 'bonjour'
    end
  end
  
  describe "GET edit" do 
    
    before(:each) do
      @o.stub(:bridge).and_return(@bridge = mock_model(Adherent::Bridge))
      get :edit, {:organism_id=>@o.id.to_s, :id=>@bridge.to_param}, valid_session
    end
    
    it 'return http success' do
      response.should be_success
    end
    
    it 'assigns @bridge' do
      assigns[:bridge].should == @bridge
    end
    
    it 'rend la vue edit' do
      response.should render_template 'edit'
    end
    
  end

end
