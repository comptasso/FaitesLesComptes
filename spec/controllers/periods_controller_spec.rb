# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PeriodsController do



  context 'testing with 2 periods how to change form one to another period' do

    before(:each) do

      ActiveRecord::Base.stub!(:use_org_connection).and_return(true)  # pour éviter
      # l'appel d'establish_connection dans le before_filter find_organism

      @cu =  mock_model(User) # cu pour current_user
      @o = mock_model(Organism, title:'le titre', database_name:'assotest')
      @p1 = mock_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year )
      @p2 = mock_model(Period, start_date:@p1.start_date.years_since(1), close_date:@p1.close_date.years_since(1))
      @b = mock_model(Book)

      Organism.stub(:first).and_return(@o)
      User.stub(:find_by_id).with(@cu.id).and_return @cu
      Period.stub(:find_by_id).with(@p1.id).and_return @p1
      Period.stub(:find).with(@p2.id.to_s).and_return @p2
      @o.stub_chain(:periods, :find).and_return @p1
    end

    describe 'GET change' do

      # HTTP_REFERER sert à résourdre la question du lien vers back
      it "should change session[:period]"  do
        request.env["HTTP_REFERER"]=organisms_url
        get :change, {:organism_id=>@o.id, :id=>@p2.id},  {user:@cu.id, period:@p1.id, org_db:'test'}
        session[:period].should == @p2.id
      end

      it "should render the right template"  do
        request.env["HTTP_REFERER"]=organisms_url
        get :change, {:organism_id=>@o.id, :id=>@p2.id},  {user:@cu.id, period:@p1.id, org_db:'test'}
        response.should redirect_to organisms_url
      end
 


    end
  end
end

