# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|  
  #  config.filter =  {wip:true}
end


describe ImportedBel do   
  include OrganismFixtureBis  
  
  def valid_attributes
    {date:Date.today,
    cat:'D',
    narration:'une ibel',
    debit:56.25,
    credit:0,
    payment_mode:'CB'}
    
    
  end
  
  describe 'complete?' do
    subject {ImportedBel.new(destination_id:1, nature_id:1, payment_mode:'CB')}
    
    it {subject.should be_complete}
    it {subject.destination_id = nil; subject.should_not be_complete}
    it {subject.nature_id = nil; subject.should_not be_complete}
    it {subject.payment_mode = nil; subject.should_not be_complete}
  end
  
  describe 'reset du payment_mode si changement de catégorie' do
    
    before(:each) {@ibel = ImportedBel.create!(valid_attributes)}
    
    after(:each) {ImportedBel.delete_all}
    
    subject {@ibel}
    
    it 'changer la catégorie et appeler valid met payment_mode à nil' do
      subject.cat = 'R'
      subject.valid?
      subject.payment_mode.should be_nil
    end
    
  end
  
  
  
  
  
end
  