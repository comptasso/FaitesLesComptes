# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe "menus/_menu.html.erb" do
  include JcCapybara

  include OrganismFixtureBis

  before(:each) do
    use_test_organism
    assign(:organism, @o)
    assign(:user, @cu)
    view.stub('user_signed_in?').and_return true
    view.stub('menu_bank').and_return(@ba)
  end

  context 'sans organisme car on se loggue' do

    before(:each) do
      view.stub('user_signed_in?').and_return false
      view.stub_chain(:devise_mapping, 'recoverable?').and_return true
      view.stub_chain(:devise_mapping, 'registerable?').and_return true
      view.stub_chain(:devise_mapping, 'rememberable?').and_return true
      view.stub(:resource_name).and_return('user')
      view.stub(:resource).and_return(@cu)
      @cu.stub(:remember_me).and_return true
    end

    it 'upper_menu ne doit pas s afficher' do
      @request.path = '/'
      render :template=>'devise/sessions/new', :layout=>'layouts/application'
      page.all('#upper_menu').count.should == 0
    end

    it 'le menu général ne doit pas s afficher' do
      @request.path = '/'
      render :template=>'devise/sessions/new', :layout=>'layouts/application'
      page.all('#main_nav').count.should == 0
    end

  end

  context 'avec organisme ayant un seul secteur' do

    # le menu Analyses avec deux secteurs est testé par un fichier spécifique
    # TODO ce fichier ne teste qu'un petit bout du menu; à compléter
    before(:each) do
      assign(:period, @p )
      assign(:paves, [@ib, @ob, @sect])
      view.stub(:current_period?).and_return(p)
      view.stub(:current_user).and_return @cu
    end

    describe 'lien adherent de l upper_menu' do
      before(:each) do
         @request.path = '/admin/organisms'
      end

      it 'une association rend le lien vers adherent' do
        render :template=>'/organisms/show', :layout=>'layouts/application'
        page.find('#upper-menu li:first a').should have_content('ADHERENTS')
      end

      it 'une non association n a que 3 liens' do
        @o.stub(:status).and_return 'Entreprise'
        render :template=>'/organisms/show', :layout=>'layouts/application'
        page.all('ul.nav-pills li').should have(3).elements
      end

    end

    describe 'Partie Virements du menu' do

      before(:each) do
#         @request.path = '/'
         render :template=>'menus/_menu' #, :layout=>'layouts/application'
      end

      it 'affiche le menu Virement' do
        page.find('ul#main_nav').should have_content ('TRANSFERTS')
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
  #      @request.path = '/'
        render :template=>'menus/_menu' #, :layout=>'layouts/application'
      end

      it 'affiche la partie Exercices du menu' do
        rendered.should match('EXERCICES')
      end

      it "affiche le sous menu exercice" do
        rendered.should match( organism_period_path(@o, @p))
      end
    end

  end

end
