# coding: utf-8

require 'spec_helper'



describe Admin::SubscriptionsHelper do 

  subject {Subscription.new(title:'Un abonnement')}
  
  describe 'date_de_fin' do
    
    
    it 'affiche Permanent si end_date est nil' do
      date_de_fin(subject).should == 'Permanent'
    end
    
    it 'ou la date internationalisée sinon' do
      subject.end_date = Date.civil(2014,1,1)
      date_de_fin(subject).should == '01/01/2014'
    end
    
  end
  
 
  

end
