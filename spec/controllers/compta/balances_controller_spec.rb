# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::BalancesController do
    let(:o) {mock_model(Organism)}
    let(:p) {mock_model(Period, start_date:Date.today.beginning_of_month,
                close_date:Date.today.end_of_month,
                all_natures_linked_to_account?:true,
                organism:o  )}
            

   before(:each) do
     Period.stub(:find).with(p.id).and_return p
   end
  
  describe "GET new" do
    it "assigns a new balance" do
      get :new, {:period_id=>p.id.to_s}, {:organism=>o.id, :period=>p.id}
      assigns(:balance).should be_a_new(Compta::Balance)
    end

    
  end

   describe "POST create" do
    def valid_attributes
      {from_date:Date.today.beginning_of_year, to_date:Date.today.end_of_month,
        period_id:p.id,
        from_account_id:1,
        to_account_id:99
      }
    end

    describe "with valid params" do
      it "assigns a newly Balance as @balance" do
        post :create, {:period_id=>p.id.to_s, :compta_balance=>valid_attributes}, {:organism=>o.id, :period=>p.id}
        assigns(:balance).should be_a(Compta::Balance)
      end

      it "render show when balance is valid" do
        Compta::Balance.any_instance.stub(:valid?).and_return(true)
        post :create, {:period_id=>p.id.to_s, :compta_balance=>valid_attributes}, {:organism=>o.id, :period=>p.id}
        response.should render_template("show")
      end

      it "render new when invalid" do
        Compta::Balance.any_instance.stub(:valid?).and_return(false)
        post :create, {:period_id=>p.id.to_s, :compta_balance=>valid_attributes}, {:organism=>o.id, :period=>p.id}
        response.should render_template("new")
      end
    end

    
  end

end

