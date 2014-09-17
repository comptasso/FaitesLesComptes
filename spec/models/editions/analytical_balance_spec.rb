# coding: utf-8

require'spec_helper'

describe Editions::AnalyticalBalance do
  include OrganismFixtureBis
  
  before(:each) do
    use_test_organism
    @cab = Compta::AnalyticalBalance.with_default_values(@p)
  end
  
  subject {Editions::AnalyticalBalance.new(@cab)}
  
  
  describe 'render' do
    
    it 'ne renvoie pas d erreur' do
      expect {subject.render}.not_to raise_error 
    end
    
  end
  
  
  
  
end