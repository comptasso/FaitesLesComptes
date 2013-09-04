require 'spec_helper'

describe Mask do
  
  before(:each) do
    @m = Mask.new(title:'Le masque', comment:'Avec un commentaire')
    @m.organism_id = 1
  end
  
  it 'creéation d un masque' do
    
    expect {@m.save}.to change {Mask.count}.by(1) 
  end
  
  describe 'validations' do
    
    it 'un masque doit avoir un titre' do
      @m.title = nil
      @m.should_not be_valid
    end
    
    it 'et un organisme' do
      @m.organism_id = nil
      @m.should_not be_valid
    end
    
    describe 'le titre doit' do
      it 'commencer par une lettre' do
        @m.title = '- bien'
        @m.should_not be_valid
      end
      
      it 'ne pas être trop court' do
        @m.title = 'a'
        @m.should_not be_valid
      end
      
      it 'ni trop long' do
        @m.title = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
        @m.should_not be_valid
      end
    end
    
  end
  
end
