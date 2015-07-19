# coding: utf-8

require 'spec_helper'

describe "transfers/show" do 
  include JcCapybara 
  
  before(:each) do
    @tr = stub_model(Transfer,
      :narration => "Premier transfert", 
      :date=> Date.today,
      piece_number:1101,
      amount:125.14
      
    )    
    @tr.stub_chain(:line_from, :account, :accountable, :nickname).and_return('le compte')
    @tr.stub_chain(:line_to, :account, :accountable, :nickname).and_return('la caisse')
    assign(:transfer, @tr)
    render
  end
  
  it 'le titre est détail du transfert' do
    page.find('.champ h3').should have_content ('Détail du transfert')
  end
  
  it 'avec une table de deux lignes' do
    page.all('table tr').should have(2).lines
  end
  
  it 'rendant la ligne de titre' do
    page.first('table tr').text.should == "\nDate\nPièce\nLibellé\nMontant\nDe\nVers\nActions\n"
  end
    
  it 'et la ligne de détail du transfert' do
    page.find('tbody tr').text.should ==
      "\n#{I18n.l(Date.today)}\n1101\nPremier transfert\n125,14\nle compte\nla caisse\n\n\n\n\n"
  end
  
  
  
end
