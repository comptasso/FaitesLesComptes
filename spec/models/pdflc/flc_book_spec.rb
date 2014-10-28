#coding: utf-8

require 'spec_helper' 

RSpec.configure do |c| 
  # c.filter = {:wip=>true}
end

describe Pdflc::FlcBook do
  include OrganismFixtureBis
  
  def render_file(pdf, file_name) 
    file =  "#{File.dirname(__FILE__)}/pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end  
  
  before(:each) do
    use_test_organism
  end
  
  it 'peut créer une instance' do
    b =  Pdflc::FlcBook.new(from_account:@p.accounts.first, 
    to_account:@p.accounts[5])
    b.draw_pdf
    render_file(b.pdf, 'book')
  end
  
end