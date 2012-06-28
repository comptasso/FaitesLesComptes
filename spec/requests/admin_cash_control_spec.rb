# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  #  c.exclusion_filter = {:js=> true }
end 

# spec request for testing admin cashes

describe 'admin cash_control' do
  include OrganismFixture
  
  
  before(:each) do
    Cash.count.should == 0
    create_minimal_organism 
  end

  it 'check minimal organism' do
    Organism.count.should == 1
    Cash.count.should == 1
  end



end

