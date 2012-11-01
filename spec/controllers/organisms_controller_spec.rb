# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 
   
RSpec.configure do |c|
  # c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true }  
end

describe OrganismsController do 

  include SpecControllerHelper 

  before(:each) do
    minimal_instances 
  end

  
  describe 'GET index', wip:true do 
   
   
    it 'find current user then calls rooms and collect' do
      User.should_receive(:find_by_id).with(@cu.id).and_return(@cu)
      @cu.should_receive(:rooms).and_return a = []
      a.should_receive(:collect).and_return([ {:organism=>@o, :room=>@r, :archive=>nil }])
      get :index, {}, {:user=>@cu.id}
       
    end


    it 'should assign @room_organisms' do
      @cu.stub_chain(:rooms, :collect).and_return('bizarre')
      get :index, {}, {:user=>@cu.id}
      assigns(:room_organisms).should == 'bizarre'
    end
   end

  describe 'GET show' do
    
    let(:c) {mock_model(Cash)}
    let(:ba1) {mock_model(BankAccount)} 
    let(:ib) {mock_model(IncomeBook) }
    let(:ob) {mock_model(OutcomeBook) }
    let(:bab) {mock_model(BankAccountBook) }

    before(:each) do
      
      @o.stub_chain(:bank_accounts, :map).and_return([ba1])
      @o.stub_chain(:cashes, :map).and_return([c])
      @o.stub_chain(:books, :all).and_return([ib,ob])
      ba1.stub(:bank_extracts).and_return([])
      
    end
    
    it 'doit rendre la vue show' do
      get :show, {:id=>@o.id}, {:org_db=>'assotest', :period=>@p.id, :user=>@cu.id}
      response.should render_template('show')
    end

    it 'assigns the user' do
      get :show, {:id=>@o.id}, {:org_db=>'assotest', :period=>@p.id, :user=>@cu.id}
      assigns(:current_user).should == @cu
    end

    it 'doit assigner l organisme' do
      get :show, {:id=>@o.id},  {:org_db=>'assotest', :period=>@p.id, :user=>@cu.id}
      assigns(:organism).should == @o
    end

     it 'check_session' do
        get :show, {:id=>@o.id},  {:org_db=>'assotest', :period=>@p.id, :user=>@cu.id}
        session[:org_db].should == 'assotest'
        session[:period].should == @p.id
        session[:user].should == @cu.id
     end

      
    it 'assign l array pave' do
      get :show,  {:id=>@o.id},  {:org_db=>'assotest', :period=>@p.id, :user=>@cu.id}
      assigns[:paves].should be_an_instance_of(Array)
    end

    it 'paves doit avoir 5 éléments' do
      # tous les livres sauf OD_Book plus résultat
      get :show, {:id=>@o.id},  {:org_db=>'assotest', :period=>@p.id, :user=>@cu.id}
      assigns[:paves].size.should == [ib,ob, c, ba1].size + 1
    end

  

  end

end
