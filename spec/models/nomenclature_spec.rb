# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe Nomenclature do
  include OrganismFixtureBis 

  let(:o) {Organism.create!(title:'titre', :database_name=>SCHEMA_TEST, status:'Association')}
  let(:p) {mock_model(Period, :organism_id=>o.id)} 

  before(:each) do
    Apartment::Database.switch(SCHEMA_TEST)
    clean_organism
  end
  
  it 'invalide sans organisme' do
      @n = o.nomenclature(true)
      @n.organism_id = nil
      @n.should_not be_valid
    end

  describe 'with a valid nomenclature' do

    before(:each) do
      @n = o.nomenclature(true)
    end
    
    it 'peut restituer ses instructions'  do       
      @n.actif.should be_an_instance_of Folio 
      @n.passif.should be_an_instance_of Folio
      @n.resultat.should be_an_instance_of Folio
      @n.benevolat.should be_an_instance_of Folio
    end

    it 'actif a des rubriks' do
      @n.actif.should have(31).rubriks
    end

    it 'peut créer une Compta::Nomenclature' do
      @n.compta_nomenclature(p).should be_an_instance_of(Compta::Nomenclature)
    end

    describe 'check_coherent'  do
  
      context 'tous les folios sont coherents' do
        before(:each) do
          Folio.any_instance.stub(:coherent?).and_return true
        end
     
        it 'n est pas valide sans un actif' do
          @n.stub(:actif).and_return nil
          @n.should_not be_coherent
        end

        it 'invalid sans passif' do
          @n.stub(:passif).and_return nil
          @n.should_not be_coherent
        end

        it 'invalid sans resultat' do
          @n.stub(:actif).and_return false # pour ne pas déclancher le test bilan_balanced
          @n.stub(:resultat).and_return nil
          @n.should_not be_coherent
        end
        
        describe 'appelle bilan_balanced?' do
        
          it 'si actif et passif' do
            @n.should_receive('bilan_balanced?')
            @n.coherent?
          end
        
          it 'mais pas si actif manque' do
            @n.stub(:actif).and_return nil
            @n.should_not_receive('bilan_balanced?')
            @n.coherent?
          end
          
          it 'ou si passif manque' do
            @n.stub(:passif).and_return nil
            @n.should_not_receive('bilan_balanced?')
            @n.coherent?
          end
        end
        
        describe 'appelle bilan_no_doublon?' do
          it 'si actif et passif' do
            @n.should_receive('bilan_no_doublon?')
            @n.coherent?
          end
        
          it 'mais pas si actif manque' do
            @n.stub(:actif).and_return nil
            @n.should_not_receive('bilan_no_doublon?')
            @n.coherent?
          end
          
          it 'ou si passif manque' do
            @n.stub(:passif).and_return nil
            @n.should_not_receive('bilan_no_doublon?')
            @n.coherent?
          end
        end
        
        describe 'coherent?' do
          before(:each) do
            @n.stub_chain(:organism, :periods, :opened).and_return([@p1 = double(Period), @p2 = double(Period)])
          end
          
          it 'doit créer deux compta nomenclature' do
            @n.should_receive(:compta_nomenclature).with(@p1).and_return(double(Compta::Nomenclature, valid?:true))
            @n.should_receive(:compta_nomenclature).with(@p2).and_return(double(Compta::Nomenclature, valid?:true))
            @n.coherent? 
          end
          
          it 'faux si une compta_nomenclature est invalide' do
            @n.stub(:compta_nomenclature).with(@p1).and_return(double(Compta::Nomenclature, valid?:true))
            @n.stub(:compta_nomenclature).with(@p2).
              and_return(@cn2 = Compta::Nomenclature.new(p, @n))
            @cn2.stub('valid?').and_return false
            @cn2.errors.add(:bilan, 'manque une valeur')
            @n.should_not be_coherent
            
          end
          
          it 'recopie l erreur dans la nomenclature'  do
            @n.stub(:compta_nomenclature).with(@p1).and_return(double(Compta::Nomenclature, valid?:true))
            @n.stub(:compta_nomenclature).with(@p2).
              and_return(@cn2 = Compta::Nomenclature.new(p, @n))
            @cn2.stub('valid?').and_return false
            @cn2.errors.add(:bilan, 'manque une valeur')
            @n.coherent?
            @n.errors.messages.should == {:bilan=>['manque une valeur']}
          end
          
        end 
    
      end
      
      context 'un folio incohérent'  do
        
        before(:each) do 
          @n.stub('bilan_balanced?').and_return true
          @n.stub('bilan_no_doublon?').and_return true
          @n.stub(:folios).and_return([double(Folio, name:'test',
                errors:double(Object, full_messages:'une erreur'), coherent?:false)])
        end
         
        it 'rend la nomenclature incohérente' do
          @n.should_not be_coherent
        end
        
        
        
      end
      
      
    
    end

    

  end



  describe 'bilan balanced?'  do

    before(:each) do
      @n = o.nomenclature
      @n.stub(:actif).and_return(double(Folio, :rough_instructions=>%w(102 506C 407 !805) ) )
      
    end

    it 'vrai si un compte C a une correspondance avec un compte D' do
      @n.stub(:passif).and_return(double(Folio, :rough_instructions=>%w(202 506D 407 !805)) )
      @n.should be_bilan_balanced
    end
    
    it 'faux dans le cas contraire' do
      @n.stub(:passif).and_return(double(Folio, :rough_instructions=>%w(202 506 407 !805)) )
      @n.should_not be_bilan_balanced
    end


  end
  
  # nouvelles spec pour faire évoluer nomenclature qui enregistre actuellement toutes 
  # les pages (actif, passif, resultat et bénévolat) dans une logique 
  # de rubrik ou  les rubrik sont persistants
  describe 'read and fill rubriks'  do
    
    before(:each) do
      @n = o.nomenclature  
    end
    
    # TODO gérer la problématique du test sur un nombre qui évolue lorsqu'on modifie
    # le fichier nomenclature. Il faudrait mieux qu'il compte le nombre de rubriques par lui
    # même
    it 'crée les 94 rubriks fournies par le fichier yml' do
      @n.should have(98).rubriks  
    end
    
    it 'la nomenclature a 4 folios' do
      @n.should have(4).folios  
    end
    
  end



end