# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end


describe Compta::Nomenclature do   
  include OrganismFixture


  def instructions(file)
    path = File.join Rails.root, 'spec', 'fixtures', 'association', file
    YAML::load_file(path)
  end

  before(:each) do
    create_organism
    @p = Period.create!(organism_id:@o.id, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
  end

  it 'se crée à partir d un hash d instructions' do
    cn =  Compta::Nomenclature.new(@p, instructions('good.yml'))
    cn.should be_an_instance_of(Compta::Nomenclature) 
  end

  
  it 'sait renvoyer une page' do
    cn =  Compta::Nomenclature.new(@p, instructions('good.yml'))
    cn.actif.should be_an_instance_of(Hash)
  end

  context 'qui est  valide' do
    before(:each) do
      @cn =  Compta::Nomenclature.new(@p, instructions('good.yml'))
    end

   
    it 'sait si tous les comptes sont pris pour actif et passif' do
      @cn.should be_bilan_complete
    end

    it 'sait si tous les comptes C ont un compte D et vice vera' do
      @cn.should_receive(:bilan_balanced).and_return true
      @cn.valid?
    end

    it 'non valide si le compte de résultats ne prend pas tous les comptes', wip:true do
      @cn.stub(:rough_accounts_reject).and_return(['709'])
      @cn.valid?
      @cn.errors.messages[:resultat].should == ['Le compte de résultats ne reprend pas tous les comptes 6 et 7. Manque 709']
    end
    
    it 'le compte de resultats ne comprend que des comptes 6 et 7'  do 
      @cn.send(:resultats_67).should be_true
    end

    it 'la validation de resultats appelle 3 rubriques' do
      @cn.stub(:rough_accounts_list, :actif).and_return(['20', '30'] )
      @cn.stub(:rough_accounts_list, :passif).and_return(['10', '16'] )
      @cn.should_receive(:rough_accounts_list).with(:exploitation).and_return(['60', '70'] )
      @cn.should_receive(:rough_accounts_list).with(:financier).and_return(['66', '76'] )
      @cn.should_receive(:rough_accounts_list).with(:exceptionnel).and_return(['68', '78'] )
      @cn.valid?
    end

    it 'non valide si un résultat comprend un compte autre que 6 ou 7' do
      @cn.stub(:rough_accounts_list, :exploitation).and_return(['60', '70', '401'] )
      @cn.should_not be_valid
    end



    it 'la partie benevolat ne comporte que des comptes 8' do
      @cn.should_receive(:benevolat_8).and_return true
      @cn.valid?
    end



    it 'un compte autre que 8 dans benevolat rend invalide' do
      @cn.stub(:rough_accounts_list, :benevolat).and_return(%w(80 !807 86 !860 45))
      @cn.should_not be_valid
    end

#    it 'visualisation des messages' do
#      @cn.valid?
#      puts @cn.errors.messages
#    end

    it 'une nomenclature sait créer un sheet' do
      @cn.sheet(:resultat).should be_an_instance_of(Compta::Sheet) 
  end


  end

  context 'qui est non valide' do

    before(:each) do
      @cn =  Compta::Nomenclature.new(@p, instructions('bad.yml'))
    end

    it 'indique ses erreurs par des messages' do 
      @cn.valid?
      @cn.errors.messages[:resultat].first.should == 'Pas de document Résultat'
    end

    it 'doit avoir un actif, un passif' do
      @cn.stub(:actif).and_return nil
      @cn.stub(:passif).and_return nil
      @cn.valid?
      @cn.errors.messages[:actif].should == ['Pas de document Actif']
      @cn.errors.messages[:passif].should == ['Pas de document Passif']
    end

  end

  context 'tous les comptes ne sont pas repris' do
    
    it 'cn bilan_complete return false' do
      @cn = Compta::Nomenclature.new(@p, instructions('one_account_missing.yml'))
      @cn.bilan_complete?.should be_false
      @cn.should_not be_valid
    end
  end

  context 'un compte de bilan C qui n a pas son D' do
    before(:each) {@cn = Compta::Nomenclature.new(@p, instructions('one_C_missing.yml'))}
    
    it 'fait que la nomenclature n est pas valide' do
      @cn.should_not be_valid
    end

    it 'avec une erreur sur le bilan' do
      @cn.should have(1).errors_on(:bilan)
    end

    it 'qui identifie le numéro de compte' do
      @cn.valid?
      @cn.errors.messages[:bilan].should ==  [' : comptes D sans comptes C correspondant (43)']
    end

  end

  context 'un compte de resultat avec un compte 4'  do
    before(:each) {@cnf = Compta::Nomenclature.new(@p, instructions('resultats_with_4.yml'))}

    it 'n est pas valide' do
      @cnf.should_not be_valid
    end

    it 'identifie le numero de compte' do
      @cnf.valid?
      @cnf.errors.messages[:exploitation].should ==  ['comprend un compte étranger aux classes 6 et 7 (410)']
    end
  end

  context 'vérification des doublons' , wip:true do 
    before(:each) {@cnf = Compta::Nomenclature.new(@p, instructions('doublons.yml'))}

    it 'n est pas valide' do
      @cnf.should_not be_valid
    end

    it 'identifie le numéro en double' do 
      @cnf.valid?
      @cnf.errors.messages[:actif].should ==  ['comprend des doublons (27, 45, 455)']
    end

    it 'identifie les doublons au sein de l ensemble resultats' do 
      @cnf.valid?
      @cnf.errors.messages[:resultat].should ==  ['comprend des doublons (641, 645, 786)']
    end

    it 'et ceux du bilan' do
      @cnf.valid?
      @cnf.errors.messages[:bilan].should ==  ['comprend des doublons (27, 419, 45, 455)']
    end


  end

  




end