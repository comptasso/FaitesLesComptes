# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|  
#  c.filter = {wip:true}
#  c.filter = {:js=> true } 
#  c.exclusion_filter = {:js=> true }  
end

# spec request for testing admin books  

describe 'vue natures index' do  
  include OrganismFixtureBis 

  before(:each) do
    create_user
    create_minimal_organism 
    login_as('quidam')
  end


  it 'check minimal organism' do
    Organism.count.should == 1
    Nature.count.should == 16 # les natures par défaut pour natures_asso.yml
    # on commence par les natures de recettes
    Book.first.should have(6).natures
  end



  describe 'new nature' do
    
    it "affiche la page new"  do
      visit new_admin_organism_period_nature_path(@o, @p) 
      page.should have_content("Nouvelle Nature")
      page.should have_content('Livre')
      
    end

    it 'reaffiche la page'  do
      visit new_admin_organism_period_nature_path(@o, @p)
    end

    it 'remplir correctement le formulaire crée une nouvelle nature', wip:true  do
      visit new_admin_organism_period_nature_path(@o, @p)
      fill_in 'nature[name]', :with=>'Nature test'
      fill_in 'nature[comment]', :with=>'Une nature pour essayer'
      select 'Dépenses'
      click_button 'Créer la nature'
      @p.natures(true).count.should == 17
      @p.natures.last.book.should == OutcomeBook.first
      current_url.should match /.*\/admin\/organisms\/#{@o.id.to_s}\/periods\/#{@p.id.to_s}\/natures$/
    end

  end
 
  describe 'index' do

    before(:each) do
      @n = @p.natures.new(:name=>'deuxième nature')
      @n.book_id = OutcomeBook.first.id; @n.save!
      @nb_natures = @p.natures.count
      @nb_depenses = @p.depenses_natures.count
      @n = @p.natures.second
    end

    it 'affiche deux tables' do
      visit admin_organism_period_natures_path(@o, @p)
      page.should have_selector("tbody", :count=>2)
    end

    it 'dans la vue index,une nature peut être détruite', :js=>true, wip:true do 
      
      
      visit admin_organism_period_natures_path(@o, @p)
      page.all('tbody tr').size.should == @nb_natures
      within "tbody:last tr:nth-child(#{@nb_depenses})" do
        page.should have_content('deuxième nature')
        page.click_link 'Supprimer'
      end
      alert = page.driver.browser.switch_to.alert
      alert.accept
      current_url.should match /.*\/admin\/organisms\/#{@o.id.to_s}\/periods\/#{@p.id.to_s}\/natures$/
      page.all("tbody tr").size.should == (@nb_natures - 1)
    
    end

    

    it 'on peut le choisir dans la vue index pour le modifier'  do
      visit admin_organism_period_natures_path(@o, @p)
      page.should have_selector "img", :title=>'Modifier'
      click_link("icon_modifier_#{@n.id}")
      current_url.should match /.*natures\/#{@n.id.to_s}\/edit$/ # retour à la vue index
    end

  end

  describe 'edit' do

    it 'On peut changer les deux autres champs', wip:true do
      @n = @p.natures.third
      visit edit_admin_organism_period_nature_path(@o, @p, @n)
      fill_in 'nature[name]', :with=>'modif du titre'
      click_button 'Mettre à jour'
      current_url.should match /natures$/
    end

  end


end

