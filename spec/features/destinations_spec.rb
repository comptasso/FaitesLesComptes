# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  #  c.exclusion_filter = {:js=> true }
end

describe 'Statistiques par activités' do 
  include OrganismFixtureBis
  

  before(:each) do
    use_test_user
    login_as('quidam')
    use_test_organism  
  end

  
    
  context 'sans écriture' do
    before(:each) do
      visit organism_period_destinations_path(@o, @p) 
    end

    it 'should be a succes' do
      page.should have_content('Statistiques par activités')
    end
    
    it 'sans écriture, affiche un flash' do
      page.should have_content('Aucune donnée à afficher') 
    end
  end
    
  context 'avec une écriture' do
    
    before(:each) do
      create_cash_income
      visit organism_period_destinations_path(@o, @p)     
    end
      
    after(:each) do
      Writing.delete_all
    end
    
    it 'affiche la table avec les bonnes données' do
      page.find('h3').text.should == 'Statistiques par activités'
      page.find('thead tr').text.should == 'Natures Aucune Total'
      page.find('tbody tr:first').text.should == "#{@n.name} 59,00 59,00"
      page.find('tfoot tr').text.should == "Total 59,00 59,00"
      
    end
    
      
  end  
end
