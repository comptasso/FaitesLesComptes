# coding: utf-8

require 'spec_helper'
require 'pdf_document/base.rb'
require 'pdf_document/page'
require 'pdf_document/base_prawn'

describe PdfDocument::Base do
  
  let(:obj) {double(Object, name:'BOURDON', forname:'Jean')}
  
  def valid_collection
    100.times.collect {|i| obj}
  end
  
  def valid_options
    {title:'Ma spec', columns_methods:['name', 'forname']}
  end
  
  subject {PdfDocument::BasePrawn.new(:page_size => 'A4', :page_layout => :landscape)}
  
  # TODO faire les spec de BasePrawn
  
  it 'est un BasePrawn' do
    subject.should be_an_instance_of PdfDocument::BasePrawn
  end
  
  describe 'stamp_rotation' do
    
    it 'vaut 30 pour un landscape' do
      subject.send(:stamp_rotation).should == 30
    end
    
    it 'et 65 pour un portrait' do
      pdf = PdfDocument::BasePrawn.new(:page_size => 'A4', :page_layout => :portrait)
      pdf.send(:stamp_rotation).should == 65
    end
    
    
  end
  
  
end