# coding: utf-8

require 'spec_helper'
require 'pdf_document/base.rb'
require 'pdf_document/page'
require 'pdf_document/base_prawn'

describe PdfDocument::Base do
  
  let(:obj) {double(Object, name:'BOURDON', forname:'Jean')}
  let(:valid_collection) {100.times.collect {|i| [obj.name, obj.forname]} }
  
  def render_file(pdf, file_name) 
    file =  "#{File.dirname(__FILE__)}/pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end
  
  def stub_pages
    5.times.collect do |i|
      double(Object, top_left:'le texte de gauche',
      title:'Un pdf de base',
      subtitle:'le sous titre',
      top_right:'Le texte de droite',
      table_title:['Nom', 'Prénom'],
      table_lines:valid_collection.slice(22*i, 21))
    end
  end
  
  def valid_options
    {title:'Ma spec', columns_methods:['name', 'forname']}
  end
  
  def doc 
    double(Object, stamp:'Test test',
      columns_widths:[40, 60], 
      columns_alignements:[:left, :left],
      nb_pages:5,
      pages:stub_pages)
  end
  
  subject {PdfDocument::BasePrawn.new(:page_size => 'A4', :page_layout => :landscape)}
  
  it 'est un BasePrawn' do
    subject.should be_an_instance_of PdfDocument::BasePrawn
  end
  
  describe 'fill_pdf' do
    it 'peut remplir le pdf' do 
      expect {subject.fill_pdf(doc)}.not_to raise_error
    end
    
    it 'et le rendre' do
      subject.fill_pdf(doc)
      expect {subject.render}.not_to raise_error
    end
    
    it 'et l écrire dans un fichier' do
      subject.fill_pdf(doc)
      render_file(subject, 'base')
    end
    
    
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