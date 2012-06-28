# coding: utf-8

require 'spec_helper'

#RSpec.configure do |c|
#  c.filter = {:wip=>true}
#end

include OrganismFixture
 
describe "BankExtracts" do

  def retry_on_timeout(n = 3, &block)
  block.call
rescue Capybara::TimeoutError, Capybara::ElementNotFound => e
  if n > 0
    puts "Catched error: #{e.message}. #{n-1} more attempts." 
    retry_on_timeout(n - 1, &block)
  else
    raise
  end
end


  before(:each) do
    create_minimal_organism
    visit organism_path(@o)
  end

  describe "GET /new_bank_extract" do  
 
    it 'the page has a form with 6 input fields' do
      visit new_bank_account_bank_extract_path(@ba)
      page.all('form').should have(1).element
      # 9 inputs dont 1 caché, 1 pour le bouton, 6 pour la saisie et le dernier
      # non disponible pour afficher le solde final
      page.find('form').all('input').should have(9).elements
      page.all(:xpath, '//input[@disabled]').should have(1).element
    end

    it 'filling the elements and click button create a bank_extract and redirect to index' do
      visit new_bank_account_bank_extract_path(@ba)
      fill_in('bank_extract_reference', :with=>'Folio 124')
      fill_in('bank_extract_begin_date_picker', :with=>(I18n.l Date.today))
      click_button('Créer')
      page.should have_content("L'extrait de compte a été créé")
      page.find('.champ h3').should have_content "Liste des extraits de compte" 
    end

    it 'filling numeric value met a jour le solde final', :js=>true do
      visit new_bank_account_bank_extract_path(@ba)
      retry_on_timeout do

        end_sold = page.find(:xpath, '//input[@disabled]')
        end_sold.value.should == '0.00'
        fill_in('bank_extract_begin_sold', with:'2.50')
        fill_in('bank_extract_total_debit', with:'1.20')
        # on fait le deuxième remplissage car end_sold est mis à jour par on_change
        # et fill_in ne fait déclenche pas on_change à lui tout seul
        sleep 0.5
        end_sold.value.should == '2.50'
        fill_in('bank_extract_total_credit', with:'3.15')
        end_sold.value.should == '1.30'
        fill_in('bank_extract_reference', :with=>'Folio 124')
        end_sold.value.should == '4.45'
      end
    end

   
  end

  describe 'GET bank_extracts' do

    it 'sans extrait la page renvoie sur new' do
      visit bank_account_bank_extracts_path(@ba)
      page.find('.champ h3').should have_content "Création d'un extrait de compte"
    end

    context 'avec un extrait de compte' do

      before(:each) do
        @be = @ba.bank_extracts.create!(begin_date:Date.today.beginning_of_month, end_date:Date.today.end_of_month,
          reference:'Folio 1', begin_sold:0.00, total_credit:1.20, total_debit:0.55)
        visit bank_account_bank_extracts_path(@ba)
      end

      it 'affiche une table avec un extrait' do
        page.find('.champ h3').should have_content "Liste des extraits de compte"
        page.should have_css('table')
        page.all('table tbody tr').should have(1).row
      end

      it 'les actions proposent edit, pointage, afficher et suppression' do
        page.find('tbody tr:first td:last').should have_icon('modifier', href:"#{edit_bank_account_bank_extract_path(@ba, @be)}")
        page.find('tbody tr:first td:last').should have_icon('pointer', href:"#{pointage_bank_extract_bank_extract_lines_path(@be)}")
        page.find('tbody tr:first td:last').should have_icon('afficher', href:"#{bank_account_bank_extract_path(@ba, @be)}")
        page.find('tbody tr:first td:last').should have_icon('supprimer', href:"#{bank_account_bank_extract_path(@ba, @be)}")
      end

      it 'cliquer sur l icone edit mène à la page edit' do
        click_link('Modifier')
        page.should have_content("Modification de relevé bancaire")
      end

      it 'cliquer sur l icone afficher mène à la page affichage' do
        click_link('Afficher')
        page.find('.champ h3').should have_content("liste des écritures")
      end

      it 'cliquer sur l icone afficher mène à la page affichage' do
        click_link('Pointer')
        page.find('.champ h3').should have_content("Relevé bancaire")
      end

      it 'cliquer sur l icone afficher mène à la page affichage' do
        BankExtract.count.should == 1
        click_link('Supprimer')
        BankExtract.count.should == 0
      end

    end

    context 'quand le bank_extract est pointe' , :wip=>true do
      it 'affiche seulement les icones afficher et supprimer' do
        @be = @ba.bank_extracts.create!(begin_date:Date.today.beginning_of_month, end_date:Date.today.end_of_month,
          reference:'Folio 1', begin_sold:0.00, total_credit:1.20, total_debit:0.55)
        @be.update_attribute(:locked, true)
        visit bank_account_bank_extracts_path(@ba)
        page.find('tbody tr:first td:last').should_not have_icon('modifier', href:"#{edit_bank_account_bank_extract_path(@ba, @be)}")
        page.find('tbody tr:first td:last').should_not have_icon('pointer', href:"#{pointage_bank_extract_bank_extract_lines_path(@be)}")
      end
    end

    context 'avec deux bank_extracts', :wip=>true do

      before(:each) do
        @be1 = @ba.bank_extracts.create!(begin_date:Date.today.beginning_of_month, end_date:Date.today.end_of_month,
          reference:'Folio 1', begin_sold:0.00, total_credit:1.20, total_debit:0.55)
        @be1.update_attribute(:locked, true)
        @be2 = @ba.bank_extracts.new(reference:'Folio 2',
          begin_date:(@be1.end_date + 1),
          end_date:(@be1.end_date.months_since(1)),
          begin_sold:@be1.end_sold,
          total_debit:3.01, total_credit:1.99)
        @be2.save!

      end


      it 'la page index affiche une table avec deux lignes' do
         visit bank_account_bank_extracts_path(@ba)
        page.all('table tbody tr').should have(2).rows
      end

      it 'détruire le premier bank_extract laisse une ligne', :js=>true do
         visit bank_account_bank_extracts_path(@ba)
        click_link('Supprimer')
        alert = page.driver.browser.switch_to.alert
        alert.accept
        sleep 1
        page.all('table tbody tr').should have(1).row 
      end
    
    end
    
  end


  
end
