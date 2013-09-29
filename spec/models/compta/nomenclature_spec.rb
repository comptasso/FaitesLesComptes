# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
 #  c.filter = {:wip=>true}
end


describe Compta::Nomenclature do   
  include OrganismFixtureBis 


  
  before(:each) do
    create_organism
    @p = @o.periods.create!(start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
    @cn =  Compta::Nomenclature.new(@p, @o.nomenclature)
  end

  it 'se crée à partir de la nomenclature d un organisme' do
    @cn.should be_an_instance_of(Compta::Nomenclature) 
  end

  
  it 'sait renvoyer un Folio' do
    @cn.actif.should be_an_instance_of(Folio)
  end
  
  it 'sait si tous les comptes sont pris pour actif et passif', wip:true do
#    puts 'liste des comptes de l exercice'
#   puts  @p.two_period_account_numbers.join(', ')
#   
#    puts 'nombres actif'
#    puts @cn.send(:numbers_from_document, @cn.actif).join(', ')
#    puts 'nombres passif'
#    puts @cn.send(:numbers_from_document, @cn.passif).join(', ')
#    puts 'resultat de bilan complete'
#    puts @cn.bilan_complete.join(', ')
      @cn.should be_bilan_complete
    end


  context 'qui est  valide' do
    before(:each) do
      @cn.stub(:rough_accounts_list).and_return []
    end

   
    
#    it 'sait si tous les comptes C ont un compte D et vice vera' do
#      @cn.should_receive(:bilan_balanced).and_return true
#      @cn.valid?
#    end

    it 'non valide si le compte de résultats ne prend pas tous les comptes' do
      @cn.stub(:rough_accounts_reject).and_return(['709'])
      @cn.valid?
      @cn.errors.messages[:resultat].should == ['Le compte de résultats ne reprend pas tous les comptes 6 et 7. Manque 709']
    end
    
#    it 'le compte de resultats ne comprend que des comptes 6 et 7'  do 
#      @cn.send(:resultats_67).should be_true
#    end

    

#    it 'non valide si un résultat comprend un compte autre que 6 ou 7'do
#      @cn.stub(:rough_accounts_list).with(:resultat).and_return(['60', '70', '401'] )
#      @cn.should_not be_valid
#    end



#    it 'la partie benevolat ne comporte que des comptes 8' do
#      @cn.should_receive(:benevolat_8).and_return true
#      @cn.valid?
#    end



#    it 'un compte autre que 8 dans benevolat rend invalide' do
#      
#      @cn.stub(:rough_accounts_list).with(:benevolat).and_return(%w(80 !807 86 !860 45))
#      @cn.should_not be_valid
#    end

#    it 'visualisation des messages' do
#      @cn.valid?
#      puts @cn.errors.messages
#    end

    it 'une nomenclature sait créer un sheet' do
      @cn.sheet(@cn.resultat).should be_an_instance_of(Compta::Sheet) 
  end


  end

  

  context 'tous les comptes ne sont pas repris' do
    
    before(:each) do
      @p.accounts.create!(number:'103', title:'Fonds associatifs 3')
      @cn = Compta::Nomenclature.new(@p, @o.nomenclature)
    end
    
    it 'cn bilan_complete return false' , wip:true do
      @cn.bilan_complete?.should be_false
      @cn.should_not be_valid
    end
  end

#  context 'un compte de bilan C qui n a pas son D' do
#    before(:each) {@cn = Compta::Nomenclature.new(@p, instructions('one_C_missing.yml'))}
#    
#    it 'fait que la nomenclature n est pas valide' do
#      @cn.should_not be_valid
#    end
#
#    it 'avec une erreur sur le bilan' do
#      @cn.should have(1).errors_on(:bilan)
#    end
#
#    it 'qui identifie le numéro de compte' do
#      @cn.valid?
#      @cn.errors.messages[:bilan].should ==  [' : comptes D sans comptes C correspondant (43)']
#    end
#
#  end
#
#  context 'un compte de resultat avec un compte 4'  do
#    before(:each) {@cnf = Compta::Nomenclature.new(@p, instructions('resultats_with_4.yml'))}
#
#    it 'n est pas valide' do
#      @cnf.should_not be_valid
#    end
#
#    it 'identifie le numero de compte' do
#      @cnf.valid?
#      @cnf.errors.messages[:exploitation].should ==  ['comprend un compte étranger aux classes 6 et 7 (410)']
#    end
#  end
#
#  context 'vérification des doublons' , wip:true do 
#    before(:each) {@cnf = Compta::Nomenclature.new(@p, instructions('doublons.yml'))}
#
#    it 'n est pas valide' do
#      @cnf.should_not be_valid
#    end
#
#    it 'identifie le numéro en double' do 
#      @cnf.valid?
#      @cnf.errors.messages[:actif].should ==  ['comprend des doublons (27, 45, 455)']
#    end
#
#    it 'identifie les doublons au sein de l ensemble resultats' do 
#      @cnf.valid?
#      @cnf.errors.messages[:resultat].should ==  ['comprend des doublons (641, 645, 786)']
#    end
#
#    it 'et ceux du bilan' do
#      @cnf.valid?
#      @cnf.errors.messages[:bilan].should ==  ['comprend des doublons (27, 419, 45, 455)']
#    end
#
#
#  end

  




end