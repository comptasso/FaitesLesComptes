# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|  
  #  config.filter =  {wip:true}
end


describe ImportedBel do   
  include OrganismFixtureBis  
  
  
  describe 'complete?' do
    subject {ImportedBel.new(destination_id:1, nature_id:1, payment_mode:'CB')}
    
    it {subject.should be_complete}
    it {subject.destination_id = nil; subject.should_not be_complete}
    it {subject.nature_id = nil; subject.should_not be_complete}
    it {subject.payment_mode = nil; subject.should_not be_complete}
  end
  
  
  
  
  
end
  