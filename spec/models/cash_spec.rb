# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BankAccount do
  include OrganismFixture

  before(:each) do
    create_minimal_organism
    @c=@o.cashes.new(:name=>'Magasin')
  end

  it "should be valid" do
    @c.should be_valid
  end

  it 'should not be_valid without name' do
    @c.name = nil
    @c.should_not be_valid
  end

  
  it "should have a unique number in the scope of bank and organism" do
    @o.cashes.create!(name: 'Magasin')
    @c.should_not be_valid 
  end

  

end

