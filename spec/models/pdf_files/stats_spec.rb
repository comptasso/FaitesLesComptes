# coding: utf-8

require 'spec_helper'

RSpec.configure do |config| 
  #  config.filter =  {wip:true}
end

# Classe de test ayant pour objet d'écrire concrètement un fichier pdf 
describe Editions::Stats do
  
  def stub_stats(nb_lines, nb_values)
    values = nb_values.times.collect {|i| i}
    nb_lines.times.collect do |t|
      ["Nature n° #{t}"] + values + [values.sum] 
    end
  end
  
  def render_file(pdf, file_name)
    file =  "#{File.dirname(__FILE__)}/test_pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
  end
  
  let(:p) {double(Period, long_exercice:'Exercice 2013')}
  
  before(:each) do
    
    @stn = Stats::Natures.new(p)
    p.stub(:start_date).and_return Date.today.beginning_of_year
    p.stub(:close_date).and_return Date.today.end_of_year
    p.stub(:list_months).and_return ListMonths.new p.start_date, p.close_date
    #  p.stub(:natures).and_return(25.times.collect {|t| "Nature n° #{t}"})
    @stn.stub(:lines).and_return stub_stats(25, 12)
    @stn.stub(:organism_name).and_return 'Pages de  statistiques'
  end
  
  it 'peut créer un Editions::Stats' do
    Editions::Stats.new(p, @stn) 
  end
  
  it 'peut rendre le fichier' do
    es = Editions::Stats.new(p, @stn) 
    es.stub(:organism_name).and_return 'Pages de  statistiques'
    es.render
  end
  
  it 'peut créer le fichier' do 
    es = Editions::Stats.new(p, @stn) 
    es.stub(:organism_name).and_return 'Pages de  statistiques'
    render_file es, 'stats'
  end
  
  describe 'avec un exercice de 6 mois seulement' do
    before(:each) do
      p.stub(:close_date).and_return(p.start_date.months_since(5).end_of_month)
      p.stub(:list_months).and_return ListMonths.new p.start_date, p.close_date
      @stn.stub(:lines).and_return stub_stats(25, 6)
      @es = Editions::Stats.new(p, @stn) 
      @es.stub(:organism_name).and_return 'Pages de  statistiques'  
    end
    
    it 'rend le fichier correctement' do
      render_file @es, 'stats6mois'
    end 
  end
  
  describe 'avec un exercice de 18 mois seulement' do   
    before(:each) do
      p.stub(:close_date).and_return(p.start_date.months_since(17).end_of_month)
      p.stub(:list_months).and_return ListMonths.new p.start_date, p.close_date
      @stn.stub(:lines).and_return stub_stats(25, 18)
      @es = Editions::Stats.new(p, @stn) 
      @es.stub(:organism_name).and_return 'Pages de  statistiques' 
    end
    
    it 'rend le fichier correctement' do
      render_file @es, 'stats18mois'
    end 
  end
  
  
end   