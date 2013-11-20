# To change this template, choose Tools | Templates
# coding: utf-8

require 'spec_helper'

RSpec.configure do |config| 
    config.filter =  {wip:true}
end

# Classe de test ayant pour objet d'écrire concrètement un fichier pdf 
describe 'Edition PDF des MonthlyExtract' do
  
  def extract_lines
    100.times.collect do |t|
      mock_model(ComptaLine, 
        nature:double(Object, name:'Cotisations'), 
        destination:double(Object, name:'Adhérents'),
        w_date:I18n::l(Date.today), w_ref:'Pièce 27', w_narration:'une écriture',
        debit:12,
        credit:0)  
    end
  end
  
  
  def render_file(pdf, file_name)
    file =  "#{File.dirname(__FILE__)}/test_pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end
   
  
  before(:each) do
    @period = mock_model(Period, 
      start_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year,
      exercice:'Exercice 2013')
    @cash = mock_model(Cash, :extract_lines=>extract_lines, title:'La caisse')
  end
  
  it 'peut produire un MonthlyExtract' do
    Extract::Cash.new(@cash, @period).should be_an_instance_of(Extract::Cash) 
  end
  
  it 'peut le rendre sous forme de pdf' do
    Extract::Cash.new(@cash, @period).to_pdf
  end
  
  it 'peut le rendre sous forme de pdf' , wip:true do
    @pdf = Extract::Cash.new(@cash, @period).to_pdf
    @pdf.stub(:nb_pages).and_return 5
    @pdf.stub(:organism_name).and_return 'Asso test'
    @pdf.stub(:fetch_lines).and_return extract_lines.slice(0, 21)
    @pdf.stub(:stamp).and_return 'Test - test'
    render_file(@pdf, 'cash_lines')
    
    
  end
  
end