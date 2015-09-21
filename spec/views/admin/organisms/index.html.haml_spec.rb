# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/organisms/index'  do

include JcCapybara

  let(:o1) {mock_model(Organism, :title=>'Organisme Test')}
  let(:o2) {mock_model(Organism, :title=>'Deuxième compte')}

  before(:each) do
    @organisms = [o1, o2]
    view.stub(:holder_status).and_return 'Propriétaire'
    view.stub(:current_user).and_return(@u = mock_model(User, 'allowed_to_create_organism?'=>true))
  end

  it 'le titre h3 est Liste des organismes' do
    render
    page.find('h3').text.should == 'Liste des organismes'
  end

  it 'afficher la table des bases' do
    render
    page.all('tbody tr' ).should have(2).rows
  end

    it 'et rend 2 icones dans la dernière colonne' do
      render
      page.all('tr:last td:last img').should have(2).icons
    end

  describe 'l icone de création' do

    before(:each) do
      view.stub('user_signed_in?').and_return true
      view.stub(:saisie_consult_organism_list).and_return("<li>Unebase</li><li>Deuxbases</li>")
    end

    it 's affiche si User peut créer une base' do
      @u.stub('allowed_to_create_organism?').and_return true
      render :template=>'admin/organisms/index', :layout=>'layouts/application'
      page.find('li.horizontal_icons > a')[:href].should == '/admin/organisms/new'
    end

    it 'mais ne s affiche pas dans le cas contraire' do
      @u.stub('allowed_to_create_organism?').and_return false
      render :template=>'admin/organisms/index', :layout=>'layouts/application'
      page.all('li.horizontal_icons > a').should have(0).element
    end
  end

end
