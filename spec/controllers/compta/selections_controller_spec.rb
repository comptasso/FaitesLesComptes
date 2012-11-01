require 'spec_helper'

describe Compta::SelectionsController do
  include SpecControllerHelper

  before(:each) do
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true
  end

  describe "GET 'index'" do 
    it "returns http success" do
      get :index,{ :period_id=>@p.to_param, :scope_condition=>'unlocked'}, valid_session
      response.should be_success 
    end

    it 'Writing receive period and scope_condition' do
      Writing.should_receive(:period).with(@p).and_return(@ar = double(Arel))
      @ar.should_receive(:send).with('unlocked').and_return [1,2]
      get :index,{ :period_id=>@p.to_param, :scope_condition=>'unlocked'}, valid_session
    end

    it 'assigns @writings' do
      Writing.stub_chain(:period, :send).and_return [1,2]
      get :index,{ :period_id=>@p.to_param, :scope_condition=>'unlocked'}, valid_session
      assigns(:writings).should == [1,2]
    end

    it 'quand le scope_condition  n est pas reconnu redirige vers back' do
      request.env['HTTP_REFERER'] = admin_organisms_path
      get :index,{ :period_id=>@p.to_param, :scope_condition=>'inconnu'}, valid_session
      response.should be_redirect
    end

  end

end
