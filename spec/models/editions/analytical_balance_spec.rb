# coding: utf-8

require'spec_helper'

describe Editions::AnalyticalBalance do
  include OrganismFixtureBis
  
  before(:each) do
    use_test_organism
    @cab = Compta::AnalyticalBalance.with_default_values(@p)
  end
  
  subject {Editions::AnalyticalBalance.new(@cab)}
  
  describe 'les lignes' do
    
  before(:each) do
    create_in_out_writing
  end
  
  after(:each) {Writing.delete_all}
  
  it 'ses lignes ne sont que des PdfDocument::TableLine' do
    subject.nb_pages.should == 1
    leslignes = subject.fetch_lines(1)
    leslignes.each {|l| l.should be_an_instance_of(PdfDocument::TableLine)}
    leslignes.size.should == 5
   
  end
  
  end
  
  describe 'render' do
     
    it 'ne renvoie pas d erreur' do
      expect {subject.render}.not_to raise_error 
    end
    
  end
  
end