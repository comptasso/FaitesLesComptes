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

  end

  context 'qui est non valide' do

    before(:each) do
      @cn =  Compta::Nomenclature.new('bad.yml')
    end

    it 'indique ses erreurs par des messages' do
      @cn.valid?
      @cn.errors.messages.should == 'Pas de document Résultat'
    end



  end





  it 'une nomenclature sait créer un sheet'





end