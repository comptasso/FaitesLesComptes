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
  
  let(:p) {double(Period, exercice:'Exercice 2013')}
  
  before(:each) do
    
    @stn = Stats::StatsNatures.new(p)
    p.stub(:start_date).and_return Date.today.beginning_of_year
    p.stub(:close_date).and_return Date.today.end_of_year
    p.stub(:list_months).and_return ListMonths.new p.start_date, p.close_date
  #  p.stub(:natures).and_return(25.times.collect {|t| "Nature n° #{t}"})
    @stn.stub(:stats).and_return stub_stats(25, 12)
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
    File.open("#{File.dirname(__FILE__)}/test_pdf_files/stats.pdf", 'wb') do |f|
      f << es.render 
    end
  end
  
  
end   