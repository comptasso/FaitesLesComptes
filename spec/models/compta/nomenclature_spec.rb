# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
   # c.filter = {:wip=>true}
end


describe Compta::Nomenclature do  
  include OrganismFixture

  before(:each) do
    @o = Organism.create!(title:'test balance sans table', database_name:'assotest1') 
    @p = Period.create!(organism_id:@o.id, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
  end

  it 'se crée à partir d un fichier' do
    cn =  Compta::Nomenclature.new(@p, 'good.yml')
    cn.should be_an_instance_of(Compta::Nomenclature)
  end

  it 'sait renvoyer une page' do
    cn =  Compta::Nomenclature.new(@p, 'good.yml')
    cn.document(:actif).should be_an_instance_of(Hash)
  end

  context 'qui est  valide' do
    before(:each) do
      @cn =  Compta::Nomenclature.new(@p, 'good.yml')
    end

    it 'valid? renvoie true' do
      @cn.should be_valid
    end

    it 'sait si tous les comptes sont pris pour actif et passif' do
      @cn.should be_bilan_complete
    end

    it 'sait si tous les comptes C ont un compte D et vice vera' do
      @cn.bilan_balanced.should be_true
    end

    it 'le compte de resultats ne comprend que des comptes 6 et 7'  do 
      @cn.resultats_67.should be_true
    end

    it 'visualisation des messages' do  
      @cn.valid?
      puts @cn.errors.messages 
    end

  end

  context 'qui est non valide' do

    before(:each) do
      @cn =  Compta::Nomenclature.new(@p, 'bad.yml')
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

  context 'tous les comptes ne sont pas repris (43D sans 43C)' do
    
    it 'cn bilan_complete return false' do
      @cn = Compta::Nomenclature.new(@p, 'one_account_missing.yml')
      @cn.bilan_complete?.should be_false
      @cn.should_not be_valid
    end
  end

  context 'un compte de bilan C qui n a pas son D' do
    before(:each) {@cn = Compta::Nomenclature.new(@p, 'one_C_missing.yml')}
    
    it 'fait que la nomenclature n est pas valide' do
      @cn.should_not be_valid
    end

    it 'avec une erreur sur le bilan' do
      @cn.should have(1).errors_on(:bilan)
    end

    it 'qui identifie le numéro de compte' do
      @cn.valid?
      @cn.errors.messages[:bilan].should ==  ['Comptes D sans comptes C correspondant: 43']
    end

  end

  context 'un compte de resultat a un compte 4' , wip:true do
    before(:each) {@cnf = Compta::Nomenclature.new(@p, 'resultats_with_4.yml')}

    it 'identifie le numero de compte' do
      @cnf.valid?
      puts @cnf.errors.messages
      @cnf.errors.messages[:exploitation].should ==  ['La partie Exploitation comprend un compte étranger aux classes 6 et 7 : 410']
    end


  end






  it 'une nomenclature sait créer un sheet'





end