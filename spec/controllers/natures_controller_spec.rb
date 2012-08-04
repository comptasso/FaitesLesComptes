require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe NaturesController do

  
  describe "GET index" do

    let(:o) {mock_model(Organism)}
    let(:p) {mock_model(Period, organism_id:o.id)}
    let(:nr1) {mock_model(Nature, period_id:p.id, income_outcome:true)}
    let(:nr2) {mock_model(Nature, period_id:p.id, income_outcome:true)}
    let(:nd1) {mock_model(Nature, period_id:p.id, income_outcome:false)}
    let(:nd2) {mock_model(Nature, period_id:p.id, income_outcome:false)}
    let(:nd3) {mock_model(Nature, period_id:p.id, income_outcome:false)}

    describe 'Check assigns' do

      before(:each) do
        Organism.stub(:find).with(o.id.to_s).and_return o
        o.stub_chain(:periods, :order).and_return([p])
        o.stub_chain(:periods, :any?).and_return(true)
        p.stub_chain(:natures, :recettes).and_return [nr1, nr2]
        p.stub_chain(:natures, :depenses).and_return [nd1, nd2, nd3]
  
      end


      it 'assigns @organism and @period' do
      
        get :stats, :organism_id=>o.id.to_s, :period_id=>p.id.to_s
        assigns(:organism).should == o
        assigns(:period).should == p
        response.should be_success
      
      
      end

      it 'redirect without @organism or period' do
        expect { get :stats}.to raise_error ActionController::RoutingError
      end

      it 'assigns @filter with 0 if no params[:filter]' do
    
        get :stats, :organism_id=>o.id.to_s, :period_id=>p.id.to_s
        assigns(:filter).should == 0
      end

      it 'assigns sn (StatsNatures)' do
        Stats::StatsNatures.should_receive(:new).with(p, 0).and_return('sn')
        get :stats, :organism_id=>o.id.to_s, :period_id=>p.id.to_s
        assigns(:sn).should == 'sn'
      end

      it 'with filter' do
        filt = 1
        Destination.should_receive(:find).with(filt).and_return(double(Object, :name=>'mock'))
        Stats::StatsNatures.should_receive(:new).with(p, 1).and_return('sn')
        
        get :stats, :organism_id=>o.id.to_s, :period_id=>p.id.to_s, :destination=>filt.to_s
        assigns(:filter).should == filt
      end 
    
    end



  end

end
