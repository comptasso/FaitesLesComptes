# coding: utf-8

require 'spec_helper'

RSpec.configure do |c| 
  # c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true }
end

describe "Writings" do
  include OrganismFixtureBis
  
  def create_od_writing(montant = 1, date= Date.today)
    compte1 = @p.accounts.classe_7.first
    compte2 = @p.accounts.classe_7.first
    
    ecriture = @od.writings.new({date:date, narration:'ligne créée par la méthode create_od_writing',
        :compta_lines_attributes=>{'0'=>{account_id:compte1.id, credit:montant},
          '1'=>{account_id:compte2.id, debit:montant}
        }
      })
    puts ecriture.errors.messages unless ecriture.valid?
    ecriture.save!
    ecriture
  end


  before(:each) do
    use_test_user
    use_test_organism 
    login_as('quidam')
    # visit admin_room_path(@r)    
  end
  
  after(:each) do
    Writing.delete_all
  end

  describe "GET compta/writings" do

    before(:each) do
      visit compta_book_writings_path(@od)
    end

    it "affiche le titre" do
      page.find('h3').should have_content 'Journal Opérations diverses : Liste d\'écritures'
    end
    
    it "le titre contient les liens vers les autres mois" do
      page.find('h3').should have_content 'fév.'
      page.find('h3').should have_content 'juil.'
    end

    
  end
  
  
  context 'avec une écriture' do
      
    before(:each) do
      create_od_writing(101)
    end
       
    describe "GET compta/writings" do
       
      it 'la table contient une écriture' do
        visit compta_book_writings_path(@od)
        page.all('.writing').count.should == 1
      end
    end
      
  end
  
  context 'avec deux écritures qui ne sont pas dans le même mois' do
      
    before(:each) do
      create_od_writing(101, @p.start_date >> 1)
      create_od_writing('9.95', @p.start_date >> 3)
    end
       
    describe "GET compta/writings" do
      
      before(:each) do
        visit compta_book_writings_path(@od)
      end
       
      it 'le mois de janvier contient une écriture' do
        click_link('fév.') unless Date.today.month == 2 # puisque la page
        # affichée est celle du mois courant, fév. n'est pas un lien si on est en février
        page.all('.writing').count.should == 1
      end
      
      it 'le mois de mars aussi' do
        click_link('avr.') unless Date.today.month == 4 # puisque la page
        # affichée est celle du mois courant, avril n'est pas un lien si on est en avril
        page.all('.writing').count.should == 1
      end
      
      it 'tous affiche les deux écritures' do
        click_link('tous')
        page.all('.writing').count.should == 2
      end
      
      it 'cliquer sur l icone de verrou global verrouille les deux lignes' do
        Writing.find_each {|w| w.should_not be_locked_at}
        click_link('tous')
        within('.horizontal_icons') {click_link('Verrouiller')} 
        Writing.find_each {|w| w.should be_locked_at}
      end
    end
      
  end
  
  
  
end
