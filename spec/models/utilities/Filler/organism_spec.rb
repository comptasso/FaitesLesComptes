# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec_helper'

describe Utilities::Filler::Organism do
  
  before(:each) do
    @o = mock_model(Organism)
  end
  
  it 'on peut créer un Filler' do
    Utilities::Filler::Organism.new(@o)
  end 
  
  
end
