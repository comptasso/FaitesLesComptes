require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe Rubrik do
  include OrganismFixtureBis
  
  before(:each) do
    create_organism
    @r = Rubrik.find_by_name('Produits financiers')
  end
  
  it 'voyons les rubriks' do
    Rubrik.count.should == 89
    
    
  end
  
  it 'la rubrique existe' do
    @r.should be_an_instance_of(Rubrik)
  end
  
  it 'sa prefondeur est de deux' do
    @r.depth.should == 2
  end
  
  it 'title est synonime de name' do
    @r.title.should == @r.name
  end
  
  it 'sa position est respectée' do
    @r.position.should == 23
    
    
  end
end
