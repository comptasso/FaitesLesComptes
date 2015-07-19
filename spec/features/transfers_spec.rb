# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  #  c.filter = {:wip=> true }
  # c.exclusion_filter = {:js=> true }
end

describe 'vue transfer index'do 
  include OrganismFixtureBis
  
  # méthode accessoire pour création de transfer
  def create_transfer(amount = 10000, piece_number=1)
    Transfer.create!(book_id:@od.id, date:(Date.today),
        piece_number:piece_number, narration: 'création',
        :compta_lines_attributes=> {'0'=>{account_id:@baca.id, credit:amount}, 
          '1'=>{account_id:@bbca.id, debit:amount}})
  end
  
  
  before(:each) do  
    use_test_user 
    login_as('quidam')
    use_test_organism 
    @bb = find_second_bank
    @bbca = @bb.current_account(@p) # ca pour Current Account
    
  end
  
  after(:each) do
    Transfer.delete_all 
  end

  describe 'new transfer'  do
    
    it "affiche la page new" do
      visit new_transfer_path
      page.should have_content("Nouveau virement") 
      page.should have_css('form')
    end

    it 'remplir correctement le formulaire crée un nouveau transfert' do
      visit new_transfer_path
      fill_in 'transfer[date_picker]', :with=>I18n::l(Date.today, :format=>:date_picker)
      fill_in 'transfer[narration]', :with=>'Premier virement' 
      fill_in 'transfer[amount]', :with=>'123.50'
      within('#transfer_compta_lines_attributes_0_account_id') do
        select(@ba.nickname)
      end
      within('#transfer_compta_lines_attributes_1_account_id') do
        select(@bb.nickname)
      end
      click_button 'Enregistrer'
      @od.transfers.count.should == 1
      # vérification du tranfert
      t= @od.transfers.last
      t.should be_an_instance_of(Transfer)
      t.line_to.account_id.should == @bbca.id
      t.line_from.account_id.should == @baca.id
    end

    context 'le remplir incorrectement'  do

      before(:each) do
        visit new_transfer_path
        fill_in 'transfer[date_picker]', :with=>I18n::l(Date.today, :format=>:date_picker)
        fill_in 'transfer[narration]', :with=>'Premier virement'
        fill_in 'transfer[amount]', :with=>'123.50'
      
        within('#transfer_compta_lines_attributes_0_account_id') do
          select(@ba.nickname)
        end
        within('#transfer_compta_lines_attributes_1_account_id') do
          select(@bb.nickname)
        end

      end

      it 'sans montant reaffiche la vue' do
        fill_in 'transfer[amount]', :with=>'bonjour'
        click_button 'Enregistrer'
        page.should have_content 'Nouveau virement'
      end

      it 'affiche des message d erreurs' do
        fill_in 'transfer[amount]', :with=>''
        click_button 'Enregistrer'
        page.should have_content 'doit être un nombre positif'
      end
    end

  end
  
  
 
  describe 'index' do

    before(:each) do
      # création de deux transfers
      @t1 = create_transfer
      @t2 = create_transfer(999990, 53)
      
      visit transfers_path
    end
    
    after(:each) do
      Transfer.delete_all
    end

    it 'affiche une table avec deux virements' do
      page.should have_css('table tbody')
      page.all('table tbody tr').should have(2).rows
    end

    it 'dans la vue virement,un virement peut être détruit si ', :js=>true do
      # à ce stade aucun virement n'est confirmé et peut être détruit
      within 'tbody tr:nth-child(2)' do
        click_link 'Supprimer' 
      end
      alert = page.driver.browser.switch_to.alert
      alert.accept
      sleep 1
      @od.transfers(true).should have(1).virement
    end

    it 'on peut le choisir dans la vue index pour le modifier', wip:true do
      within 'tbody tr:nth-child(2)' do
        @lien =  find('a[title="Modifier"]')['href'] 
        click_link 'Modifier'
      end 
      current_url.should match /.*#{@lien}\z/
    end 

  end

  describe 'edit'  do

    before(:each) do
      @bb = find_second_bank 
      @t1 = create_transfer
    end

    it 'On peut changer les deux autres champs' do
      visit edit_transfer_path(@t1.to_param)
      fill_in 'transfer[narration]', :with=>'modif du libellé'
      click_button 'Modifier ce virement'
      current_url.should match transfers_path
    end

  end


end

