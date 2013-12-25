require 'spec_helper'

describe Subscription do
  
  describe 'validations' do
    subject {Subscription.new(mask_id:1, title:'un abonnement', day:5)}
    
    it 'test' do
      puts subject.inspect
    end
  
    it('est valide') {subject.should be_valid}  
  
    describe 'invalide' do
    
      it 'sans le jour' do
        subject.day = nil
        subject.should_not be_valid
      end
    
      it 'ni le mask_id' do
        subject.mask_id = nil
        subject.should_not be_valid
      end
    
      it 'ni le title' do
        subject.title = nil
        subject.should_not be_valid
      end
    
    
    end
  
  end
end
