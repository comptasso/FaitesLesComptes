# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|
  #  c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true }
end

describe 'Cash Control Requests' do 
  include OrganismFixture 

  before(:each) do
    create_user
    create_minimal_organism
    login_as('quidam')
  end
  
  describe 'new cash_control' do  
    before(:each) do
      
      visit new_cash_cash_control_path(@c)  
    end


    it "affiche la page new" do
      current_url.should match new_cash_cash_control_path(@c)
      page.should have_content("Enregistrement d'un contrôle de la caisse")
      all('form div.control-group').should have(2).elements # date et amount

    end  

    it 'remplir correctement le formulaire cree une nouvelle ligne' do

      fill_in 'cash_control[date_picker]', :with=> '05/05/2012'
      fill_in 'cash_control[amount]', :with=>20.52
      click_button "Enregistrer"
      current_url.should match cash_cash_controls_path(@c)
      all('tbody tr').should have(1).rows

    end

    context 'remplir incorrectement le formulaire' do

      it 'test amount' do
        fill_in 'cash_control[date_picker]', :with=> '01/01/2012'
        fill_in 'cash_control[amount]', :with=>-20.52
        click_button "Enregistrer"
        page.should have_content('doit être positif ou nul')
        @c.should have(0).cash_controls
      end

      it  'test date' do
        fill_in 'cash_control[date_picker]', :with=> '01/01/1990'
        fill_in 'cash_control[amount]', :with=>20.52
        click_button "Enregistrer"
        page.should have_content('Pas d\'exercice')
      end

    end


  end

  describe 'index' do

   before(:each) do
     @c.cash_controls.create!(amount: 20, date: Date.today)
     @cc = @c.cash_controls.first
   end

    it 'on peut le choisir dans la vue index pour le modifier', :wip=>true do
      @c.should have(1).cash_controls
      visit cash_cash_controls_path(@c)  
      click_link "icon_modifier_cash_control_#{@cc.id.to_s}"
      current_url.should match(edit_cash_cash_control_path(@c,@cc)) 
    end

  end

  describe 'edit' do 

    before(:each) do
     @c.cash_controls.create!(amount: 20, date: Date.today)
     @cc = @c.cash_controls.first 
   end

    it 'On peut changer les deux autres champs et revenir à la vue index' do

      visit edit_cash_cash_control_path(@c, @cc)
      fill_in 'cash_control[amount]', :with=> 22.12
      click_button 'Enregistrer'
      current_url.should match cash_cash_controls_path(@c)
      find('tbody tr td:nth-child(2)').text.should == '22,12'

    end

  end

end