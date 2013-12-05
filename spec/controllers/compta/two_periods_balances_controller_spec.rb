  # coding: utf-8 

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::TwoPeriodsBalancesController do 
  include SpecControllerHelper
  
    before(:each) do
      minimal_instances 
      controller.stub(:check_natures).and_return true 
    end
  
    describe 'GET show' do
      it 'crée une instance de Compta::TwoPeriodsBalance' do
        Compta::TwoPeriodsBalance.should_receive(:new).with(@p).and_return(@ctpb = double(Compta::TwoPeriodsBalance))
        @ctpb.should_receive(:lines).and_return
        get :show, {period_id:@p.id}, valid_session
      end
      
      it 'et assigne les lignes' do
        Compta::TwoPeriodsBalance.stub_chain(:new, :lines).and_return(@arr = double(Array))
        get :show, {period_id:@p.id}, valid_session
        assigns(:detail_lines).should == @arr
      end 
      
      it 'rend le template show' do
        Compta::TwoPeriodsBalance.stub_chain(:new, :lines).and_return(@arr = double(Array))
        get :show, {period_id:@p.id}, valid_session
        response.should render_template 'show'
      end
    end
end