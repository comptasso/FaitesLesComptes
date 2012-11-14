# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true} 
end


describe Compta::Nomenclature do  
  include OrganismFixture

  it 'se crée à partir d un fichier' do
   cn =  Compta::Nomenclature.new('good.yml')
   cn.should be_an_instance_of(Compta::Nomenclature)
  end

  it 'sait renvoyer une page' do
    cn =  Compta::Nomenclature.new('good.yml')
    cn.document(:actif).should be_an_instance_of(Hash)
  end

  context 'qui est  valide' do
  before(:each) do
    @cn =  Compta::Nomenclature.new('good.yml')
  end

  it 'valid? renvoie true' do 
    @cn.should be_valid
  end

    it 'sais si tous les comptes sont pris pour actif et passif' do
      @o=Organism.create!(title:'test balance sans table', database_name:'assotest1')
      @p= Period.create!(organism_id:@o.id, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
      @cn.bilan_complete?(@p).should be_true
    end

    it 'visualisation des messages' do 
      @cn.valid?
      puts @cn.errors.messages 
    end

  end

  context 'qui est non valide' do

    before(:each) do
      @cn =  Compta::Nomenclature.new('bad.yml')
    end

    it 'indique ses erreurs par des messages' do
      @cn.valid?
      @cn.errors.messages[:exploitation].should == ['Pas de document Exploitation']
    end

    it 'doit avoir un actif, un passif' do
      @cn.stub(:actif).and_return nil
      @cn.stub(:passif).and_return nil
      @cn.valid?
      @cn.errors.messages[:actif].should == ['Pas de document Actif']
      @cn.errors.messages[:passif].should == ['Pas de document Passif']
    end

    it 'tous les comptes sont pris en compte pour actif et passif' do
      pending
    end




  end





  it 'une nomenclature sait créer un sheet'





end