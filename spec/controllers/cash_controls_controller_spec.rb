# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
 #   c.filter = {:wip => true }
  #  c.exclusion_filter = {:js=> true }
end

describe CashControlsController do
   include OrganismFixture

  let(:o) {mock_model(Organism)}
  let(:p) {mock_model(Period, :organism=>o)}

  let(:ca) {mock_model(Cash, :organism=>o)}
  let(:ccs) { [ mock_model(CashControl, :date=>Date.today, amount: 3), mock_model(CashControl, :date=>Date.today - 1.day, amount: 1) ] }
  
  before(:each) do
    @mois = Date.today.month - 1
    o.stub(:periods).and_return { mock(Arel, :order=>[p], 'any?' =>true) }

    # méthode définie dans OrganismFixture et
    # permettant d'avoir les variables d'instances @organism, @period, 
    # income et outcome book ainsi qu'une nature
#    create_minimal_organism
#    @ca = @o.cashes.create!(name: 'Caisse')
  end

  before(:each) do
    Cash.should_receive(:find).with(ca.id.to_s).and_return(ca)
  end

  
  describe 'GET index'  do

    before(:each) do
       ca.stub_chain(:cash_controls, :mois).and_return(ccs)
    end

    it "should find the right cash" do
      get :index, :cash_id=>ca.id, :mois=>@mois
      assigns[:cash].should == ca
    end

    it 'should assign organism' , :wip => true do
      get :index, :cash_id=>ca.id, :mois=>@mois
      assigns[:organism].should == o
    end

    it 'should assign cash_controls' do
      get :index, :cash_id=>ca.id, :mois=>@mois
      assigns[:cash_controls].should == ccs
    end
    
    it 'should assign cash_controls' do
      get :index, :cash_id=>ca.id, :mois=>@mois
      response.should render_template 'index'
    end


  end

  describe 'GET new' do

    before(:each) do
      ca.should_receive(:cash_controls).and_return(CashControl)
      get :new, :cash_id=>ca.id, :mois=>@mois
    end

    it 'assigns a new cash control' do
      assigns[:cash_control].should be_an_instance_of CashControl
    end

    it 'intialized with Date.today' do
      assigns[:cash_control].date.should == Date.today
    end

    it 'and render new view' do
      response.should render_template 'new'
    end

  end

  describe 'POST create' do

    before(:each) do
      
    end

    it 'should redirect to index' do
      p.stub(:guess_month).and_return(@mois)
      post :create, :cash_id=>ca.id, :cash_control=> {:date=>Date.today, :amount=>5 }
      response.should render_template 'index'
    end



  end

  

  

  

 

  
end

