# coding: utf-8

require 'spec_helper'
require 'pdf_document/base.rb'
require 'pdf_document/page'
require 'pdf_document/prawn_base'

describe PdfDocument::Base do
  
  let(:obj) {double(Object, name:'BOURDON', forname:'Jean')}
  
  def valid_collection
    100.times.collect {|i| obj}
  end
  
  def valid_options
    {title:'Ma spec', columns_methods:['name', 'forname']}
  end
  
  let(:pdf) {PdfDocument::Base.new(valid_collection, valid_options)}
  
  describe 'stamp_rotation' do
    
    it 'vaut 30 pour un landscape' do
      pdf_base =   PdfDocument::PrawnBase.new(:page_size => 'A4', :page_layout => :landscape)
      pdf_base.send(:stamp_rotation).should == 30
    end
    
    it 'et 65 pour un portrait' do
      pdf_base =   PdfDocument::PrawnBase.new(:page_size => 'A4', :page_layout => :portrait)
      pdf_base.send(:stamp_rotation).should == 65
    end
    
    
  end
  
  
end