# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe "menus/_guide.html.haml" do   
  include JcCapybara 
  
  let(:mask1) {mock_model(Mask, title:'masque un', comment:'le masque numéro un') } 
  let(:mask2) {mock_model(Mask, title:'masque deux', comment:'no comment')}
  let(:twomasks) {[mask1, mask2]}
  
  let(:o) {mock_model(Organism, name:'jcl')}
  
  before(:each) do
    assign(:organism, o)
    
  end
  
  context 'sans masque' do
    before(:each) do
      o.stub(:masks).and_return []
      render
    end
    
    it 'le partial n affiche rien' do
      page.all('li').should have(0).elements
    end
  end
  
  context 'avec deux masques' do
    
    
  before(:each) do
    o.stub(:masks).and_return twomasks
    render
  end
  
  it 'affiche 4 balises li' do
      page.all('li').should have(4).elements
  end
  
  it 'la premiere est un divider' do
    page.find('li:first')[:class].should == 'divider'
  end
  
  it 'le second affiche le sous titre' do
    expect(page.find('li:nth-child(2)').text).to match("Modèles d'écriture")
  end
  
  it 'puis des liens avec le titre du masque comme texte' do
    page.find('li:nth-child(3) a').text.should == mask1.title
  end
  
  it 'le commentaire comme title' do
    page.find('li:nth-child(3) a')[:title].should == mask1.comment
  end
  
  it 'et pointe sur new_mask_writing_path' do
    page.find('li:nth-child(3) a')[:href].should == new_mask_writing_path(mask1)
  end
  
 
  
    
  
  end
end