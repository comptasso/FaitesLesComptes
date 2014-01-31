# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec_helper'

describe Utilities::Filler::Organism do
  include OrganismFixtureBis
  
  
  describe 'remplissage des différentes tables' do
  
    before(:each) do
      create_organism
    end
  
    subject {@o}
  
    it {should have(2).destinations} 
  
    describe 'les destinations' do
      
      subject {@o.destinations}  
    
      it {subject.order('name').first.name.should == 'Adhérents'}
      it {subject.order('name').last.name.should == 'Non affecté'}
    
    end
    
  end
end
