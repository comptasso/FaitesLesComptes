# coding: utf-8

require 'spec_helper'

require 'pdf_document/totalized_prawn'

describe PdfDocument::TotalizedPrawn do
 
  let(:obj) {double(Object, name:'BOURDON')}
  let(:valid_collection) {100.times.collect {|i| [obj.name, i*10.25]} }
  
  def stub_pages
    5.times.collect do |i|
      double(Object, top_left:'le texte de gauche',
        title:'Un pdf totalisé',
        subtitle:'le sous titre',
        top_right:'Le texte de droite',
        table_title:['Nom', 'Valeur'],
        table_lines:valid_collection.slice(22*i, 21),
        table_lines_depth:valid_collection.size.times.collect { 0 }, 
     #   total_columns_widths:[60,40],
        table_report_line:['Un nombre fictif', 10000],
        table_to_report_line:['Encore un nombre bidon', 5421.98],
        table_total_line:['Un total fictif', 100000])
    end
  end
  
  def doc 
    double(Object, stamp:'Test test',
      columns_widths:[40, 60], 
      columns_alignements:[:left, :right],
      nb_pages:5,
      total_columns_widths:[60,40],
      pages:stub_pages)
  end

  def render_file(pdf, file_name) 
    file =  "#{File.dirname(__FILE__)}/pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end  
  

  
  subject {PdfDocument::TotalizedPrawn.new(:page_size => 'A4', :page_layout => :landscape)}
    
  it 'est une instance' do
    subject.should be_an_instance_of(PdfDocument::TotalizedPrawn)
  end

  it 'que l on peut remplir' do
    subject.fill_pdf(doc)
  end
  
  it 'rendre' do
    subject.fill_pdf(doc)
    subject.render
  end
 
  it 'et écrire dans un fichier' do
    subject.fill_pdf(doc)
    render_file(subject, 'totalized')
  end
   
  
end
