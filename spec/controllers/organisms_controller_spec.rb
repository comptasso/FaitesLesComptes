# coding: utf-8

require 'spec_helper'
require 'support/spec_controller_helper'

RSpec.configure do |c|
  # c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true }
end

describe OrganismsController do

  include SpecControllerHelper

  before(:each) do
    minimal_instances
  end

  describe 'GET show' do

    let(:c) {mock_model(Cash)}
    let(:ba1) {mock_model(BankAccount)}

    before(:each) do
      @o.stub_chain(:bank_accounts, :map).and_return([ba1])
      @o.stub_chain(:cashes, :map).and_return([c])
      @o.stub_chain(:sectors).and_return([mock_model(Sector, paves:['un', 'deux', 'trois'])])
      @o.stub(:cash_books).and_return []
      @o.stub(:bank_books).and_return []
      ba1.stub(:bank_extracts).and_return([])
    end
    context 'en l\'absence d\'exercice' do

      before(:each) do
        @controller.stub(:current_period).and_return nil
      end

      it 'remplit un flash d alerte' do
        get :show, {:id=>@o.id}, {:org_id=>@o.id, :user=>@cu.id}
        flash[:alert].should == 'Vous devez créer au moins un exercice pour cet organisme'
      end

      it 'et redirige vers la création d\'exercice' do
        get :show, {:id=>@o.id}, {:org_id=>@o.id, :user=>@cu.id}
        response.should redirect_to new_admin_organism_period_url(@o)
      end

    end

    it 'doit rendre la vue show' do
      get :show, {:id=>@o.id}, {:org_id=>@o.id, :period=>@p.id, :user=>@cu.id}
      response.should render_template('show')
    end

    it 'assigns the user' do
      get :show, {:id=>@o.id}, {:org_id=>@o.id, :period=>@p.id, :user=>@cu.id}
      assigns(:current_user).should == @cu
    end

    it 'doit assigner l organisme' do
      get :show, {:id=>@o.id},  {:org_id=>@o.id, :period=>@p.id, :user=>@cu.id}
      assigns(:organism).should == @o
    end

    it 'check_session' do
      get :show, {:id=>@o.id},  {:org_id=>@o.id, :period=>@p.id, :user=>@cu.id}
      session[:org_id].should == @o.id
      session[:period].should == @p.id
      session[:user].should == @cu.id
    end


    it 'assign l array pave' do
      get :show,  {:id=>@o.id},  {:org_id=>@o.id, :period=>@p.id, :user=>@cu.id}
      assigns[:paves].should be_an_instance_of(Array)
    end

    it 'paves doit avoir 3 éléments (car on stub les cash books et bank_books' do
      # tous les livres sauf OD_Book plus résultat
      get :show, {:id=>@o.id},  {:org_id=>'assotest', :period=>@p.id, :user=>@cu.id}
      assigns[:paves].size.should == 3
    end

  end

end
