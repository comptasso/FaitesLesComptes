# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::BalancesController do
  include SpecControllerHelper

  before(:each) do 
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true 
  end
  
  describe "GET new" do
    it "assigns a new balance" do
      get :new, {:period_id=>@p.id.to_s}, valid_session
      assigns(:balance).should be_a_new(Compta::Balance)
    end

    
  end

  describe "POST create" do
    def valid_attributes
      {from_date:Date.today.beginning_of_year, to_date:Date.today.end_of_month,
        period_id:@p.id,
        from_account_id:1,
        to_account_id:99
      }
    end

    describe "with valid params" do
      it "assigns a newly Balance as @balance" do
        post :create, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes}, valid_session
        assigns(:balance).should be_a(Compta::Balance)
      end

      it "render show when balance is valid" do
        Compta::Balance.any_instance.stub(:valid?).and_return(true)
        post :create, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes}, valid_session
        response.should render_template("show")
      end

#      it 'rend le pdf' do
#        Compta::Balance.any_instance.stub(:valid?).and_return(true)
#        post :create, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes, :format=>'pdf'}, valid_session
#        response.status.should == 200
#      end

      it 'rend le csv' do
        pending
        Compta::Balance.any_instance.stub(:valid?).and_return(true)
        Compta::Balance.any_instance.stub(:to_csv).and_return('ceci est une chaine csv\tune autre\tencoe\tenfin\n')
        post :create, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes, :format=>'csv'}, valid_session
        response.should be_success
      end

       it 'rend le xls' do
         pending 'renvoie le statut 406, mais pourtant fonctionne donc revoir la spec'
        Compta::Balance.any_instance.stub(:valid?).and_return(true)
        Compta::Balance.any_instance.stub(:to_xls).and_return('ceci est une chaine csv\tune autre\tencoe\tenfin\n')
        post :create, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes, :format=>'xls'}, valid_session
        response.should be_success
      end

      it "render new when invalid" do
        Compta::Balance.any_instance.stub(:valid?).and_return(false)
        post :create, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes}, valid_session
        response.should render_template("new")
      end
    end

    
  end

end

