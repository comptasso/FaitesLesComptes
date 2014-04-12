require 'spec_helper'


describe Admin::BridgesHelper do
  
  let(:o) {mock_model(Organism)}
  let(:p) {mock_model(Period, organism:o)}
  let(:b) {double(Adherent::Bridge, nature_name:'Cotisations')}
  let(:natures) {3.times.map {|i| mock_model(Nature, name:"Nature n° #{i}")}}
  
  
  context 'Avec un seul livre de recettes' do
  
    before(:each) do
      o.stub(:income_books).and_return(@ar = double(Arel, count:1))
      @ar.stub(:first).and_return(double(IncomeBook, natures:natures))
    end
    it 'donne les options' do
      n = natures.first
      bridge_nature_options(p,b).should match "<option value=\"#{n.name}\">"
    end
  
  end
  
  context 'avec plusieurs livres de recettes' do
    
    before(:each) do
      o.stub(:income_books).and_return([mock_model(IncomeBook, title:'Livre 1', natures:natures),
          mock_model(IncomeBook, title:'Livre 2', natures:natures)])
      end
    
    
    # TODO faire des spec plus complètes deux optgroup, 6 options, ...
    it 'il y a des optgroup' do
      bridge_nature_options(p,b).should match('optgroup')
      
    end
    
    
  end
end
