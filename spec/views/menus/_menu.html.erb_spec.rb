# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe "menus/_menu.html.erb" do   
  include JcCapybara 

  let(:o) {mock_model(Organism, main_bank_id:1, status:'Association') }
  let(:ibook) {stub_model(IncomeBook, :title=>'Recettes') } 
  let(:obook) { stub_model(OutcomeBook, title: 'Dépenses')}
  let(:p2012) {stub_model(Period, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))}
  let(:p2011) {stub_model(Period, start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31)) }
  let(:cu) {mock_model(User, name:'jcl')}

  before(:each) do
    assign(:user, cu)
    view.stub('user_signed_in?').and_return true
  end

  context 'sans organisme car on se loggue' do

    before(:each) do
      view.stub('user_signed_in?').and_return false
      view.stub_chain(:devise_mapping, 'recoverable?').and_return true
      view.stub_chain(:devise_mapping, 'registerable?').and_return true
      view.stub_chain(:devise_mapping, 'rememberable?').and_return true
      view.stub(:resource_name).and_return('user')
      view.stub(:resource).and_return(cu)
      cu.stub(:remember_me).and_return true
      
    end

    it 'upper_menu ne doit pas s afficher' do
      @request.path = '/'
      render :template=>'devise/sessions/new', :layout=>'layouts/application'
      page.all('#upper_menu').count.should == 0 
    end

    it 'le menu général ne doit pas s afficher' do
      @request.path = '/'
      render :template=>'devise/sessions/new', :layout=>'layouts/application'
      page.all('#menu_general').count.should == 0
    end

  end

  context 'avec organisme' do

    before(:each) do
    
      assign(:organism, o)
      assign(:user, cu)
      o.stub(:periods).and_return([p2011,p2012])
      o.stub(:bank_accounts).and_return([@ba = mock_model(BankAccount, bank_extracts:[], :check_deposits=>[], 'unpointed_bank_extract?'=>false)])
      o.stub(:cashes).and_return([mock_model(Cash, cash_controls:[])])
      o.stub(:in_out_books).and_return [ibook,obook]
      o.stub('can_write_line?').and_return true

      o.stub(:find_period).and_return(p2012)
      p2012.stub(:previous_period?).and_return(true)
      p2012.stub(:previous_period).and_return(p2011)
      ibook.stub(:organism).and_return(o)
      obook.stub(:organism).and_return(o)
      assign(:books, [ibook,obook])
      assign(:period, p2012 )
      o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque))
      assign(:paves, [ibook, obook, p2012])
     
      @ba.stub_chain(:bank_extracts, :period, :unlocked).and_return []


      view.stub(:current_period?).and_return(p)
      view.stub(:current_user?).and_return true
      view.stub(:current_user).and_return cu
      view.stub(:saisie_consult_organism_list).and_return 'liste des organismes avec lien'
      
      
    end
    
    describe 'lien adherent de l upper_menu' do
      before(:each) do
         @request.path = '/admin/oragnisms'
      end
      
      it 'une association rend le lien vers adherent' do 
        render :template=>'/organisms/show', :layout=>'layouts/application'
        page.find('#upper-menu li:first a').should have_content('ADHERENTS')
      end
      
      it 'une non association n a que 3 liens' do
        o.stub(:status).and_return 'Entreprise'
        render :template=>'/organisms/show', :layout=>'layouts/application'
        page.all('ul.nav-pills li').should have(3).elements
      end
                    
    end

    describe 'Partie Virements du menu' do 

      before(:each) do
         @request.path = '/'
         render :template=>'organisms/show', :layout=>'layouts/application'
      end

      it 'affiche le menu Virement' do
        page.find('ul#menu_general').should have_content ('TRANSFERTS')
      end

      it 'affiche le sous menu Afficher' do
        page.find('li#menu_transfer').should have_content('Afficher')
      end

      it 'affiche la sous rubrique Nouveau' do
        page.find('li#menu_transfer').should have_content('Nouveau')
      end
    end

    describe 'Partie Exercices du menu' do

      before(:each) do
        @request.path = '/'
        render :template=>'organisms/show', :layout=>'layouts/application'
      end

      it 'affiche la partie Exercices du menu' do
        rendered.should match('EXERCICES')
      end

      it "affiche le sous menu exercice" do
        rendered.should match( organism_period_path(o, p2011))
      end



    end
  end
end
