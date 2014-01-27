# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
 # c.filter = {:wip=>true} 
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

  
  it 'sait renvoyer ses divers Folio' do
    @cn.actif.should be_an_instance_of(Folio)
    @cn.passif.should be_an_instance_of(Folio)
    @cn.resultat.should be_an_instance_of(Folio) 
    @cn.benevolat.should be_an_instance_of(Folio) 
  end
  
  context 'avec les valeurs par défaut' do
    it 'est bilan complete' do
      @cn.should be_bilan_complete
    end
    
    it 'est resultat complete' do
      @cn.should be_resultat_complete
    end
    
    it 'est bilan_no_doublon' do
      @cn.should be_bilan_no_doublon
    end
    
    it 'est resultat no_doublon' do
      @cn.should be_resultat_no_doublon
    end
    
    it 'est benevolat no_doublon' do
      @cn.should be_benevolat_no_doublon
    end
    
    it 'est donc valide' do
      @cn.should be_valid
    end
    
    context 'pour une non association', wip:true do
      
      before(:each) do
        Organism.any_instance.stub(:status).and_return 'Entreprise'
      end
            
      it 'est valide malgré l absence de folio benevolat' do
        @cn.stub(:benevolat).and_return nil
        @cn.should be_valid
      end
      
    end
  end
    
  
  describe 'resultat complete' do

    it 'aouter un compte 7 non repris dans la nomenclature la rend invalide' do
      @p.stub(:two_period_account_numbers).and_return(['709'])
      @cn.valid?
      @cn.errors.messages[:resultat].should == ['Le compte de résultats ne reprend pas tous les comptes 6 et 7. Manque 709']
    end

  end

  

  describe 'bilan_complete' do
    
    context 'ajouter un compte de bilan non repris rend la nomenclature' do
      
      
      before(:each) do
        @p.accounts.create!(number:'103', title:'Fonds associatifs 103')
        @cn = Compta::Nomenclature.new(@p, @o.nomenclature)
      end
    
      it 'non bilan_complete'  do
        @cn.bilan_complete?.should be_false
      end
    
      it 'et invalide' do
        @cn.should_not be_valid
      end
    
    end
    
    context 'mais ajouter un compte de bilan repris' do
      before(:each) do
        @p.accounts.create!(number:'1021', title:'Sous compte du 102')
        @cn = Compta::Nomenclature.new(@p, @o.nomenclature)
      end
      
      it 'laisse la nomenclature bilan_complete' do
        @cn.should be_bilan_complete
        @cn.should be_valid
      end
      
    end
  end
  
  describe 'bilan_no_doublon'  do
    
    context 'avec un compte qui apparaît une fois à l actif et une au passif' do
      
      before(:each) do
        @p.stub(:two_period_account_numbers).and_return(['201'])
        @cn.stub(:actif).and_return(@actif = double(Folio, :all_numbers => "201" ))
        @actif.stub(:all_numbers_with_option).and_return [{:num=>"201", :option=>nil}]
        @cn.stub(:passif).and_return(@passif = double(Folio, :all_numbers => "201"))
        @passif.stub(:all_numbers_with_option).and_return [{:num=>"201", :option=>nil}]
      end
      
      it 'est bilan_doublon' do
        @cn.should_not be_bilan_no_doublon
      end
      
      it 'la nomenclature est invalide' do
        @cn.should_not be_valid
      end
      
      it 'a une erreur sur bilan' do
        @cn.should have(1).errors_on(:bilan)
      end
       
    end
    
    describe 'autres cas de doublons'  do
      
      before(:each) do
        @p.stub(:two_period_account_numbers).and_return(['102', '201'])
        @cn.stub(:actif).and_return(@actif = double(Folio, :all_numbers => "201" ))
        @cn.stub(:passif).and_return(@passif = double(Folio, :all_numbers => "102"))
        @passif.stub(:all_numbers_with_option).and_return [{:num=>"102", :option=>nil}]
        
      end
      
      it 'un compte en brut et le même en amortissement'  do
        @actif.stub(:all_numbers_with_option).and_return [{:num=>"201", :option=>nil}, {:num=>"201", :option=>:col2}]
        @cn.should_not be_bilan_no_doublon
      end
      
      it 'avec un compte qui apparaît une fois en brut et une fois en debit' do
        @actif.stub(:all_numbers_with_option).and_return [{:num=>"201", :option=>nil}, {:num=>"201", :option=>:debit}]
        @cn.should_not be_bilan_no_doublon
      end
      
      it 'avec un compte qui apparaît une fois en brut et une fois en credit' do
        @actif.stub(:all_numbers_with_option).and_return [{:num=>"201", :option=>nil}, {:num=>"201", :option=>:credit}]
        @cn.should_not be_bilan_no_doublon
      end
         
    end
    
  end
    
  describe 'resultat_no_doublon', wip:true do
      
    context 'avec un compte 6 qui apparaît deux fois' do   
        
      before(:each) do
        @p.stub(:two_period_account_numbers).and_return(['67', '70'])
        @cn.stub(:resultats).and_return(@results = [@result = double(Folio, :all_numbers => ['67', '70'] )])
        @results.stub(:all).and_return([@result])
        @result.stub(:all_numbers_with_option).and_return [{:num=>"67", :option=>nil}, {:num=>"67", :option=>nil}, {:num=>"70", :option=>nil}]
      end
      
      it 'est bilan_doublon' do
        @cn.should_not be_resultat_no_doublon
      end
      
      it 'la nomenclature est invalide' do
        @cn.should_not be_valid
      end
      
      it 'a une erreur sur bilan' do
        @cn.should have(1).errors_on(:resultat) 
      end
      
             
    end
      
    context 'avec plusieurs folios resultats' do
      
      before(:each) do
        @p.stub(:two_period_account_numbers).and_return(['67', '68', '70'])
        @cn.stub(:resultats).and_return(@results = [@resulta = double(Folio, :all_numbers => ['67', '68'] ), 
            @resultb = double(Folio, :all_numbers => ['67', '70'] )])
        @results.stub(:all).and_return([@resulta, @resultb])
        @resulta.stub(:all_numbers_with_option).and_return [{:num=>"67", :option=>nil}, {:num=>"68", :option=>nil}]
        @resultb.stub(:all_numbers_with_option).and_return [{:num=>"67", :option=>nil}, {:num=>"70", :option=>nil}]

      end
      
      it 'contrôle globalement resultat_complete' do
        @cn.should be_resultat_complete
      end
      
      it 'ainsi que resultat_no_doublon' do
        @cn.should_not be_resultat_no_doublon
      end
      
    end
      
  end
      
  describe 'benevolat_no_doublon'  do
      
    context 'avec un compte 8 qui apparaît deux fois' do   
        
      before(:each) do
        @p.stub(:two_period_account_numbers).and_return(['81', '82'])
        @cn.stub(:benevolat).and_return(@benevolat = double(Folio, :all_numbers => ['81', '82'] ))
        @benevolat.stub(:all_numbers_with_option).and_return [{:num=>"81", :option=>nil}, {:num=>"81", :option=>nil}, {:num=>"82", :option=>nil}]
       
      end
      
      it 'est bilan_doublon' do
        @cn.should_not be_benevolat_no_doublon
      end
      
      it 'la nomenclature est invalide' do
        @cn.should_not be_valid
      end
      
      it 'a une erreur sur bilan' do
        @cn.should have(1).errors_on(:benevolat)
      end
      
             
    end
  end
    
    
end

  




