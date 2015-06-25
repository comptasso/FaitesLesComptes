# coding: utf-8

require 'spec_helper' 

describe "bank_extracts/lines_to_point" do
  include OrganismFixtureBis
  include JcCapybara 

  before(:each) do
    use_test_organism
    assign(:period, @p)
    assign(:bank_account, @ba)
    
    
  end
  
  context 'sans écritures - et donc sans écriture à pointer' do
  
    it 'peut rendre la vue' do
      assign(:lines_to_point, 
        @ba.not_pointed_lines(@p.close_date))
      render
    end
  
  end
  
  context 'avec une écriture à pointer' do
    
    before(:each) {create_outcome_writing}
    
    after(:each) {erase_writings}
    
    it 'peut rendre la vue' do
      assign(:lines_to_point, 
        @ba.not_pointed_lines(@p.close_date))  
      render
    end
  end

end
