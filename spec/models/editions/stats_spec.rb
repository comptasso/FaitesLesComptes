# coding: utf-8

require'spec_helper'

describe Editions::Stats do

  let(:p) {double(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)}
  let(:source) {double(Object, :stats=>nil)}

  def list_months
    ListMonths.new(p.start_date, p.close_date) 
  end

  def stub_lines(n, taille)
    n.times.collect {|i| Array.new(taille)}
  end

  before(:each) do
    p.stub(:list_months).and_return list_months
  end

  it 'se construit avec un exercice' do
    Editions::Stats.new(p, source).should be_an_instance_of(Editions::Stats)
  end

  it 'appelle ses lignes avec un numéro de page' do
    source.should_receive(:lines).and_return(stub_lines(30,14))
    sts = Editions::Stats.new(p, source)
    sts.fetch_lines(1).should be_an Array
  end

  it 'la première page à 22 lignes' do
    source.stub(:lines).and_return(stub_lines(30,14))
    sts = Editions::Stats.new(p, source)
    sts.fetch_lines(1).should have(22).lines

  end

  it 'et la deuxième les 8 denières lignes' do
    source.stub(:lines).and_return(stub_lines(30,14))
    sts = Editions::Stats.new(p, source)
    sts.fetch_lines(2).should have(8).lines
  end

  
  it 'si les lignes ont plus de 14 colonnes ne garde que les douze derniers mois' do
    source.should_receive(:lines).at_least(1).times.and_return(stub_lines(30,18))
    sts = Editions::Stats.new(p, source)
    sts.fetch_lines(1).should be_an Array
    sts.fetch_lines(1).first.size.should == 14 # le titre plus 12 mois plus le total
  end

  it 'sait rendre un pdf' do
    p.stub(:organism).and_return(double(title:'Ma petite affaire'))
    p.stub(:exercice).and_return('Exercice 2013')
    source.stub(:lines).at_least(1).times.and_return(stub_lines(30,14))
    source.stub(:stats).and_return(stub_lines(30,14))
    sts = Editions::Stats.new(p, source)
    sts.render

  end


end
