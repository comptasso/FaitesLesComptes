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
    

    it 'non valide si le compte de résultats ne prend pas tous les comptes' do
      @p.stub(:two_period_account_numbers).and_return(['709'])
      @cn.valid?
      @cn.errors.messages[:resultat].should == ['Le compte de résultats ne reprend pas tous les comptes 6 et 7. Manque 709']
    end


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

    it 'une nomenclature connait ses folios' do
      @cn.resultat.should be_an_instance_of(Folio) 
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

  




end