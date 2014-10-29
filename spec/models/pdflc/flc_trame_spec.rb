#coding: utf-8

require 'spec_helper' 

RSpec.configure do |c| 
    # c.filter = {:wip=>true}
end

describe Pdflc::FlcTrame do

  def render_file(pdf, file_name) 
    file =  "#{File.dirname(__FILE__)}/pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end  
  


  before(:each) do
    @pdf = Prawn::Document.new
    @trame = Pdflc::FlcTrame.new(title:'Le titre', 
      subtitle:'Ici le sous titre', 
      organism_name:'Ma petite entreprise', 
      exercice:'Exercice 2015')
  end
  
  it 'définit un tampon qui sera utilisé par le pdf' do
    @trame.trame_stamp(@pdf)
    @pdf.stamp('trame')
    @pdf.start_new_page
    @pdf.stamp('trame')
    render_file(@pdf, 'essai')
  end
  
  
  
  
  
  
end 