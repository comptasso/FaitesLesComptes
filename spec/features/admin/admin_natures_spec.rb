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
    use_test_organism
    login_as(@cu, 'MonkeyMocha')
  end

  describe 'new nature' do

    it "affiche la page new"  do
      visit new_admin_organism_period_nature_path(@o, @p)
      page.should have_content("Nouvelle Nature")
      page.should have_content('Livre')
    end

    it 'reaffiche la page'  do
      pending 'à compléter'
      visit new_admin_organism_period_nature_path(@o, @p)
    end

    describe 'création d une nature' do

      before(:each) do
        n = @p.natures.where('name = ?', 'Nature test').first
        n.destroy if n
      end

      after(:each) do
        @nouvelle_nature.destroy if @nouvelle_nature #car si le test
        # suivant ne marche pas, cela crée une erreur
      end

      it 'remplir correctement le formulaire crée une nouvelle nature' do
        @nats_count = @p.natures.count
        visit new_admin_organism_period_nature_path(@o, @p)
        fill_in 'nature[name]', :with=>'Nature test'
        fill_in 'nature[comment]', :with=>'Une nature pour essayer'
        select 'Dépenses'
        click_button 'Créer la nature'
        @p.natures(true).count.should == @nats_count + 1
        @nouvelle_nature = @p.natures.order(:created_at).last
        @nouvelle_nature.book.should == OutcomeBook.first
        current_url.should match(/.*\/admin\/organisms\/#{@o.id.to_s}\/periods\/#{@p.id.to_s}\/natures\?book_id=#{@ob.id}$/)
      end

    end

  end

  describe 'vue index' do

    it 'affiche une table' do
      visit admin_organism_period_natures_path(@o, @p, book_id:@ob.id)
      page.should have_selector("tbody", :count=>1)
    end

    it 'avec autant de lignes que de natures' do
      visit admin_organism_period_natures_path(@o, @p, book_id:@ob.id)
      page.all('tbody tr').size.should == @ob.natures.within_period(@p).count
    end

    it 'dans la vue index,une nature peut être détruite', :js=>true do
      find_second_nature
      nb_nats = @ob.natures.within_period(@p).count
      visit admin_organism_period_natures_path(@o, @p, book_id:@ob.id)
      # save_and_open_page
      within("table#depenses tbody tr:last-child") do
        page.should have_content('deuxieme nature')
        page.click_link 'Supprimer'
      end
      alert = page.driver.browser.switch_to.alert
      alert.accept
      current_url.should match(/.*\/admin\/organisms\/#{@o.id.to_s}\/periods\/#{@p.id.to_s}\/natures\?book_id=#{@ob.id}$/)
      page.all("tbody tr").size.should == (nb_nats - 1)
    end

    it 'cliquer sur modifier une nature affiche la vue edit'do
      visit admin_organism_period_natures_path(@o, @p, book_id:@ob.id)
      click_link("icon_modifier_#{@n.id}")
      current_url.should match(/.*natures\/#{@n.id.to_s}\/edit$/) # retour à la vue index
    end

  end

  describe 'edit' do

    it 'On peut changer les deux autres champs' do
      @n = @p.natures.first
      visit edit_admin_organism_period_nature_path(@o, @p, @n)
      fill_in 'nature[name]', :with=>'modif du titre'
      click_button 'Mettre à jour'
      current_url.should match(/natures\?book_id=\d*$/)
    end

  end

  describe 'changement d exercice' do
    before(:each) do
      @np = find_second_period
      visit admin_organism_period_natures_path(@o, @p, book_id:@ob.id)
    end

    it 'on est dans la vue nature', wip:true do
      puts @o.inspect
      puts @p.inspect
      puts @np.inspect
      page.should have_content('Exercice 2016')
      page.find('h3').should have_content('Natures du livre')
      click_link('Exercice 2016')
      page.should have_content('Natures du livre')
    end

    it 'reaffiche correctement la vue index si on change d exercice', wip:true do
      click_link @np.long_exercice
      page.all('h3').each {|h| puts h.text }
      page.find('h3').should have_content('Natures du livre Dépenses')
    end
  end


end

