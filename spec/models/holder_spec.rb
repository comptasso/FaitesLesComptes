require 'spec_helper'

describe Holder do
  
  def holder_valid_attributes
    {user_id:1, room_id:1, status:'owner'}
  end
  describe 'validations' do
    subject {Holder.new(holder_valid_attributes)}
    
    it {subject.should be_valid}
    
    it 'non valide sans user' do
      subject.user_id = nil
      subject.should_not be_valid
    end
    
    it 'non valide sans room' do
      subject.room_id = nil
      subject.should_not be_valid
    end
    
    it 'status peut aussi être guest' do
      subject.status = 'guest'
      subject.should be_valid
    end
    
    it 'mais pas autre choses' do
      subject.status = 'proprio'
      subject.should_not be_valid
    end
  end
end
