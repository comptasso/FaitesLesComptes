# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {:js=>true}
  # c.filter = {:wip=>true}
  # c.exclusion_filter = {:js=>true} 
end

include OrganismFixture 
 
describe "BankExtracts" do 

  
  before(:each) do
    create_user
    create_minimal_organism  
    login_as('quidam')
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
        sleep 0.5
        end_sold.value.should == '4.45'
      
    end

   
  end

  describe 'GET INDEX bank_extracts'  do

    it 'sans extrait la page renvoie sur new' do
      visit bank_account_bank_extracts_path(@ba)
      page.find('.champ h3').should have_content "Compte courant : création d'un extrait de compte"
    end

    context 'avec un extrait de compte non vide' do
      before(:each) do
        @be = @ba.bank_extracts.create!(begin_date:Date.today.beginning_of_month, end_date:Date.today.end_of_month,
          reference:'Folio 1', begin_sold:0.00, total_credit:1.20, total_debit:0.55)
        BankExtract.any_instance.stub_chain(:bank_extract_lines, :empty?).and_return false
        visit bank_account_bank_extracts_path(@ba)

      end

      it 'affiche une icone modifier' , wip:true do
         page.find('tbody tr:first td:last').should have_icon('afficher', href:"#{bank_account_bank_extract_path(@ba, @be)}")
      end
      
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

      it 'les actions proposent edit, pointage, afficher et suppression' , js:true do
        page.find('tbody tr:first td:last').should have_icon('modifier', href:"#{edit_bank_account_bank_extract_path(@ba, @be)}")
        page.find('tbody tr:first td:last').should have_icon('pointer', href:"#{pointage_bank_extract_bank_extract_lines_path(@be)}")
       
        page.find('tbody tr:first td:last').should have_icon('supprimer', href:"#{bank_account_bank_extract_path(@ba, @be)}")
      end

      it 'cliquer sur l icone edit mène à la page edit' do
        click_link('Modifier')
        page.find('h3').should have_content("Compte courant : modification d'un extrait de compte")
      end

      

      it 'cliquer sur l icone afficher mène à la page affichage' do
        click_link('Pointer')
        page.find('.champ h3').should have_content("Relevé bancaire")
      end

      it 'cliquer sur l icone supprimer efface un extrait de compte', :js=>true do
        @nb = @ba.bank_extracts.count
        # save_and_open_page
        click_link('Supprimer')
        alert = page.driver.browser.switch_to.alert
        alert.accept
        sleep 1
        page.all('table tbody tr').should have(0).row
      end

    end

    context 'quand le bank_extract est pointe'  do
      it 'affiche seulement les icones afficher et supprimer' do
        @be = @ba.bank_extracts.create!(begin_date:Date.today.beginning_of_month, end_date:Date.today.end_of_month,
          reference:'Folio 1', begin_sold:0.00, total_credit:1.20, total_debit:0.55)
        @be.update_attribute(:locked, true)
        visit bank_account_bank_extracts_path(@ba)
        page.find('tbody tr:first td:last').should_not have_icon('modifier', href:"#{edit_bank_account_bank_extract_path(@ba, @be)}")
        page.find('tbody tr:first td:last').should_not have_icon('pointer', href:"#{pointage_bank_extract_bank_extract_lines_path(@be)}")
      end
    end

    context 'avec deux bank_extracts' do 

      before(:each) do
        @be1 = @ba.bank_extracts.create!(begin_date:@p.start_date, end_date:@p.start_date.end_of_month,
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

      it 'détruire le premier bank_extract laisse une ligne',  :js=>true do
        visit bank_account_bank_extracts_path(@ba)
        click_link('Supprimer')
        alert = page.driver.browser.switch_to.alert
        alert.accept
        sleep 1
        page.all('table tbody tr').should have(1).row  
      end
    
    end
    
  end 

  describe 'EDIT bank extract' do
    before(:each) do
      @be = @ba.bank_extracts.create!(begin_date:Date.today.beginning_of_month, end_date:Date.today.end_of_month,
        reference:'Folio 1', begin_sold:0.00, total_credit:1.20, total_debit:0.55)
      visit edit_bank_account_bank_extract_path(@ba, @be)
    end

    it 'affiche le formulaire' do
      f = page.find('form')
      f.find('#bank_extract_reference').value.should == 'Folio 1'
      f.find('#bank_extract_begin_sold').value.should == '0.00'
      f.find('#bank_extract_total_credit').value.should == '1.20'
      f.find('#bank_extract_total_debit').value.should == '0.55'

    end

    it 'modifier avec une donnée correcte et sauver affiche le flash et renvoie sur index' do
      fill_in('bank_extract_total_credit', with:'3.15')
      click_button('Enregistrer')
      page.should have_content("L'extrait a été modifié")
      page.find('.champ h3').should have_content "Liste des extraits de compte" 
    end

    it 'avec une valeur sauve la valeur' do
      fill_in('bank_extract_total_credit', with:'3.152')
      click_button('Enregistrer')
      page.should have_content("Des erreurs ont été trouvées") 
      page.find('.champ h3').should have_content "Compte courant : modification d'un extrait de compte"
    end

  end
 
end
