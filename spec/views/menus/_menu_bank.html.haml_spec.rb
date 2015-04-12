# coding: utf-8

require 'spec_helper'

RSpec.configure do |c| 
  # c.filter = {:wip=>true}
end
  
  
describe "menus/_menu_bank.html.erb" do 
  include JcCapybara 
  
  let(:o) {mock_model Organism}
  let(:sect) {mock_model(Sector)}
  let(:ba) {mock_model(BankAccount, sector:sect)}
    
  before(:each) do
    view.stub('user_signed_in?').and_return true
    view.stub('menu_bank').and_return(ba)
    assign(:organism, o)
  end
    
  describe 'Partie Banques du menu' do

    context 'sans extrait ni chèques à déposer' do
      
      before(:each) do
        ba.stub(:check_deposits).and_return([])
        ba.stub('unpointed_bank_extract?').and_return false 
        ba.stub(:bank_extracts).and_return([])
        
      end

      
     
      
      it 'affiche A pointer' do
        render :template=>'menus/_menu_bank'
        page.find_link("A pointer") 
      end
      
      it 'affiche Liste remise si des remises de chèques' do
        ba.stub(:check_deposits).and_return([double(Object)])
        render :template=>'menus/_menu_bank'
        page.find_link("Liste remises") 
      end
      
      it 'affiche Nlle Remise si des chèques sont à déposer' do
        CheckDeposit.stub(:nb_to_pick).and_return 1
        render :template=>'menus/_menu_bank'
        page.find_link("Nlle Remise") 
      end
      
      # TODO faire des spec pour la sectorisation des remises de chèques
      
      it 'affiche Pointage si des un extrait est à pointer' do
        ba.stub(:unpointed_bank_extract?).and_return true
        ba.stub(:first_bank_extract_to_point).and_return mock_model(BankExtract)
        render :template=>'menus/_menu_bank'
        page.find_link("Pointage") 
      end
      
      it 'affiche Extraits de comptes' do
        render :template=>'menus/_menu_bank'
        page.find_link("Extraits de comptes") 
      end
      
      
      
      
# TODO faire des specs qui valident le lien et non seulement le texte du lien
    end

  end
    
end