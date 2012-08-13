# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true }
end




describe OrganismsController do

  let(:cu) {mock_model(User)} # cu pour current_user
   let(:o) {mock_model(Organism, title:'le titre', database_name:'assotest')}

  before(:each) do
    Organism.stub(:find).with(o.id.to_s).and_return(o)
    User.stub(:find_by_id).with(cu.id).and_return cu
  end

  describe 'GET index', wip:true do
   
   
    let(:r) {mock_model(Room)}

    it 'find current user then calls rooms and collect' do
      User.should_receive(:find_by_id).with(cu.id).and_return(cu)
      cu.should_receive(:rooms).and_return a = []
      a.should_receive(:collect).and_return([ {:organism=>o, :room=>r, :archive=>nil }])
      get :index, {}, {:user=>cu.id}
       
    end


    it 'should assign @room_organisms' do
      cu.stub_chain(:rooms, :collect).and_return('bizarre')
      
      get :index, {}, {:user=>cu.id}
      assigns(:room_organisms).should == 'bizarre'
    end
   end

  describe 'GET show' do

   
    let(:pe) {mock_model(Period, :start_date=>Date.civil(2012,1,1), :close_date=>Date.civil(2012,12,31))}
    let(:c) {mock_model(Cash)}
    let(:ba1) {mock_model(BankAccount)} 
    let(:ib) {mock_model(IncomeBook) }
    let(:ob) {mock_model(OutcomeBook) }

    before(:each) do
      Period.stub(:find).with(pe.id).and_return(pe)
      o.stub(:periods).and_return([pe])
      o.stub_chain(:bank_accounts, :all).and_return([ba1])
      o.stub_chain(:cashes, :all).and_return([c])
      o.stub_chain(:books, :all).and_return([ib,ob])
      o.stub_chain(:periods, :empty?).and_return(false)
      o.stub_chain(:periods, :order, :last, :id).and_return(pe.id)
      ba1.stub(:bank_extracts).and_return([])
      
    end
    
    it 'doit rendre la vue show' do
      get :show, {:id=>o.id}, {:org_db=>'assotest', :period=>pe.id, :user=>cu.id}
      response.should render_template('show')
    end

    it 'assigns the user' do
      get :show, {:id=>o.id}, {:org_db=>'assotest', :period=>pe.id, :user=>cu.id}
      assigns(:current_user).should == cu 
    end

    it 'doit assigner l organisme' do
      get :show, {:id=>o.id},  {:org_db=>'assotest', :period=>pe.id, :user=>cu.id}
      assigns(:organism).should == o
    end

     it 'check_session' do
        get :show, {:id=>o.id},  {:org_db=>'assotest', :period=>pe.id, :user=>cu.id}
        session[:org_db].should == 'assotest'
        session[:period].should == pe.id
        session[:user].should == cu.id
     end

      
    it 'assign l array pave' do
      get :show,  {:id=>o.id},  {:org_db=>'assotest', :period=>pe.id, :user=>cu.id}
      assigns[:paves].should be_an_instance_of(Array)
    end

    it 'paves doit avoir 4 éléments' do
      # income et outcomme books, résultat, cash, mais pas bank_account car il n(y a pas de bak_extract
      get :show, {:id=>o.id},  {:org_db=>'assotest', :period=>pe.id, :user=>cu.id}
      assigns[:paves].size.should == 4
    end

    it 'lorsque bank_account a un bank_extract il y a 5 pavés' do
      ba1.stub_chain(:bank_extracts, :any?).and_return(true)
      get :show, {:id=>o.id},  {:org_db=>'assotest', :period=>pe.id, :user=>cu.id}
      assigns[:paves].size.should == 5
    end


  end

end
