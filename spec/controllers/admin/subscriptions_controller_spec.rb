# -*- encoding : utf-8 -*-

require 'spec_helper'

describe Admin::SubscriptionsController do
  include SpecControllerHelper
  
  before(:each) do
    minimal_instances
    sign_in(@cu)
    @o.stub(:subscriptions).and_return @a = double(Arel) 
  end
  
  describe "GET new" do
    it "assigns a new subscription as @subscription" do
      @a.should_receive(:new).and_return mock_model(Subscription).as_new_record
      get :new, {organism_id:@o.to_param}, valid_session
      assigns(:subscription).should be_a_new(Subscription)  
    end
    
    it 'rend le template new' do
      @a.stub(:new).and_return mock_model(Subscription).as_new_record
      get :new, {organism_id:@o.to_param}, valid_session
      response.should render_template('new')
    end
  end
  
  
  
end