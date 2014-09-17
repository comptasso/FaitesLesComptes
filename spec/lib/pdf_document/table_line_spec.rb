# coding: utf-8

require 'spec_helper' 
require 'pdf_document/table_line' 

RSpec.configure do |config|
 # config.filter = {wip:true}
end



describe PdfDocument::TableLine do

  let(:values) {['601', 'Intitulé', "6000.54", "12.1"]} 
  let(:types)  {%w(String String Numeric Numeric)}
  
  it 's instancie avec des valeurs et un tableau de types' do
    PdfDocument::TableLine.new(values, types).should be_an_instance_of(PdfDocument::TableLine)
  end
  
  describe 'prepared_values' do
    
    subject {PdfDocument::TableLine.new(values, types)}
    
    it 'prend en compte les types pour formater les valeurs' do
      subject.prepared_values.should == ['601', 'Intitulé', '6 000,54', '12,10']
    end
    
  end
end