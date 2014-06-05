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
     use_test_user
    login_as('quidam')
    use_test_organism
    
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
    
    describe 'création d une nature' do

      after(:each) do
        @nouvelle_nature.destroy
      end
      
      it 'remplir correctement le formulaire crée une nouvelle nature' do
        @nats_count = Nature.count
        visit new_admin_organism_period_nature_path(@o, @p)
        fill_in 'nature[name]', :with=>'Nature test'
        fill_in 'nature[comment]', :with=>'Une nature pour essayer'
        select 'Dépenses'
        click_button 'Créer la nature'
        @p.natures(true).count.should == @nats_count + 1
        @nouvelle_nature = @p.natures.order(:created_at).last
        @nouvelle_nature.book.should == OutcomeBook.first
        current_url.should match /.*\/admin\/organisms\/#{@o.id.to_s}\/periods\/#{@p.id.to_s}\/natures\?book_id=#{@ob.id}$/
      end
    
    
    end

  end
 
  describe 'vue index' do
    
    it 'affiche deux tables' do
      visit admin_organism_period_natures_path(@o, @p, book_id:@ob.id)
      page.should have_selector("tbody", :count=>1)
    end
    
    it 'avec autant de lignes que de natures' do
      visit admin_organism_period_natures_path(@o, @p, book_id:@ob.id)
      page.all('tbody tr').size.should == @ob.natures.count
    end

    it 'dans la vue index,une nature peut être détruite', :js=>true do 
      
      find_second_nature
      nb_nats = @ob.natures.count
      visit admin_organism_period_natures_path(@o, @p, book_id:@ob.id)
      # save_and_open_page
      within("table#depenses tbody tr:last-child") do
        page.should have_content('deuxieme nature')
        page.click_link 'Supprimer'  
      end
      alert = page.driver.browser.switch_to.alert
      alert.accept
      current_url.should match /.*\/admin\/organisms\/#{@o.id.to_s}\/periods\/#{@p.id.to_s}\/natures\?book_id=#{@ob.id}$/
      page.all("tbody tr").size.should == (nb_nats - 1)
    
    end

    it 'cliquer sur modifier une nature affiche la vue edit'do
      visit admin_organism_period_natures_path(@o, @p, book_id:@ob.id)
      click_link("icon_modifier_#{@n.id}")
      current_url.should match /.*natures\/#{@n.id.to_s}\/edit$/ # retour à la vue index
    end

  end

  describe 'edit' do 

    it 'On peut changer les deux autres champs' do
      @n = @p.natures.first
      visit edit_admin_organism_period_nature_path(@o, @p, @n)
      fill_in 'nature[name]', :with=>'modif du titre'
      click_button 'Mettre à jour'
      current_url.should match /natures\?book_id=\d*$/
    end

  end


end

