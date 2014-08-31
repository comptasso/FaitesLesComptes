# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe Nomenclature do
  include OrganismFixtureBis 


  before(:each) do
    use_test_organism
  end
  
  it 'invalide sans organisme' do
    @nomen = @o.nomenclature(true)
    @nomen.organism_id = nil
    @nomen.should_not be_valid
  end

  describe 'with a valid nomenclature' do

    before(:each) do
      @nomen = @o.nomenclature(true)
    end
    
    it 'peut restituer ses instructions'  do       
      @nomen.actif.should be_an_instance_of Folio 
      @nomen.passif.should be_an_instance_of Folio
      @nomen.resultat.should be_an_instance_of Folio
      @nomen.benevolat.should be_an_instance_of Folio
    end

    it 'actif a des rubriks' do
      @nomen.actif.should have(31).rubriks
    end

    it 'peut créer une Compta::Nomenclature' do
      @nomen.compta_nomenclature(@p).should be_an_instance_of(Compta::Nomenclature)
    end

    describe 'check_coherent'  do
  
      context 'tous les folios sont coherents' do
        before(:each) do
          Folio.any_instance.stub(:coherent?).and_return true
          
        end
        
        context 'on stub period_coherent?' do
          
          
          before(:each) {@nomen.stub(:period_coherent?).and_return true}
     
          it 'n est pas valide sans un actif' do
            @nomen.stub(:actif).and_return nil
            @nomen.should_not be_coherent
          end

          it 'invalid sans passif' do
            @nomen.stub(:passif).and_return nil
            @nomen.should_not be_coherent
          end

          it 'invalid sans resultat' do
            @nomen.stub(:actif).and_return false # pour ne pas déclancher le test bilan_balanced
            @nomen.stub(:resultat).and_return nil
            @nomen.should_not be_coherent
          end
        
          describe 'appelle bilan_balanced?' do
        
            it 'si actif et passif' do
              @nomen.should_receive('bilan_balanced?')
              @nomen.coherent?
            end
        
            it 'mais pas si actif manque' do
              @nomen.stub(:actif).and_return nil
              @nomen.should_not_receive('bilan_balanced?')
              @nomen.coherent?
            end
          
            it 'ou si passif manque' do
              @nomen.stub(:passif).and_return nil
              @nomen.should_not_receive('bilan_balanced?')
              @nomen.coherent?
            end
          end
        
          describe 'appelle bilan_no_doublon?' do
            it 'si actif et passif' do
              @nomen.should_receive('bilan_no_doublon?')
              @nomen.coherent?
            end
        
            it 'mais pas si actif manque' do
              @nomen.stub(:actif).and_return nil
              @nomen.should_not_receive('bilan_no_doublon?')
              @nomen.coherent?
            end
          
            it 'ou si passif manque' do
              @nomen.stub(:passif).and_return nil
              @nomen.should_not_receive('bilan_no_doublon?')
              @nomen.coherent?
            end
          end
        end
        
        # TODO retravailler ce sujet qui oscille entre Period et Nomenclature
        # il faut se décider sur quel modèle a la main.
        
        describe 'appel de la cohérence des exercices?' do
          before(:each) do
            @nomen.stub_chain(:organism, :periods, :opened).and_return([@p1 = double(Period), @p2 = double(Period)])
            @p1.stub(:update_attribute)
            @p2.stub(:update_attribute)
          end
          
          it 'doit créer deux compta nomenclature' do
            @nomen.should_receive(:compta_nomenclature).with(@p1).and_return(double(Compta::Nomenclature, valid?:true))
            @nomen.should_receive(:compta_nomenclature).with(@p2).and_return(double(Compta::Nomenclature, valid?:true))
            @nomen.coherent? 
          end
          
          it 'faux si une compta_nomenclature est invalide' do
            @nomen.stub(:compta_nomenclature).with(@p1).and_return(double(Compta::Nomenclature, valid?:true))
            @nomen.stub(:compta_nomenclature).with(@p2).
              and_return(@cn2 = Compta::Nomenclature.new(@p, @nomen))
            @cn2.stub('valid?').and_return false
            @cn2.errors.add(:bilan, 'manque une valeur')
            @nomen.should_not be_coherent
            
          end
          
          it 'recopie l erreur dans la nomenclature'  do
            @nomen.stub(:compta_nomenclature).with(@p1).and_return(double(Compta::Nomenclature, valid?:true))
            @nomen.stub(:compta_nomenclature).with(@p2).
              and_return(@cn2 = Compta::Nomenclature.new(@p, @nomen))
            @cn2.stub('valid?').and_return false
            @cn2.errors.add(:bilan, 'manque une valeur')
            @nomen.coherent?
            @nomen.errors.messages.should == {:bilan=>['manque une valeur']}
          end
          
        end 
        
        
    
      end
      
      describe 'period_coherent?' do
          
        it 'met à jour le champ nomenclature_ok de period avec le resultat de valid?' do
          @nomen.stub(:compta_nomenclature).with(@p).
            and_return(@cn2 = Compta::Nomenclature.new(@p, @nomen))
          @cn2.stub('valid?').and_return 'bizarre'
          @p.should_receive(:update_attribute).with(:nomenclature_ok, 'bizarre')
          @nomen.period_coherent?(@p)
        end
      end
      
      context 'un folio incohérent'  do
        
        before(:each) do 
          @nomen.stub('bilan_balanced?').and_return true
          @nomen.stub('bilan_no_doublon?').and_return true
          @nomen.stub(:period_coherent?).and_return true
          @nomen.stub(:folios).and_return([double(Folio, name:'test',
                errors:double(Object, full_messages:'une erreur'), coherent?:false)])
        end
         
        it 'rend la nomenclature incohérente' do
          @nomen.should_not be_coherent
        end
        
        
        
      end
      
      
    
    end

    

  end



  describe 'bilan balanced?'  do

    before(:each) do
      @nomen = @o.nomenclature
      @nomen.stub(:actif).and_return(double(Folio, :rough_instructions=>%w(102 506C 407 !805) ) )
      
    end

    it 'vrai si un compte C a une correspondance avec un compte D' do
      @nomen.stub(:passif).and_return(double(Folio, :rough_instructions=>%w(202 506D 407 !805)) )
      @nomen.should be_bilan_balanced
    end
    
    it 'faux dans le cas contraire' do
      @nomen.stub(:passif).and_return(double(Folio, :rough_instructions=>%w(202 506 407 !805)) )
      @nomen.should_not be_bilan_balanced
    end


  end
  
  # nouvelles spec pour faire évoluer nomenclature qui enregistre actuellement toutes 
  # les pages (actif, passif, resultat et bénévolat) dans une logique 
  # de rubrik ou  les rubrik sont persistants
  describe 'read and fill rubriks'  do
    
    before(:each) do
      @nomen = @o.nomenclature  
    end
    
    # TODO gérer la problématique du test sur un nombre qui évolue lorsqu'on modifie
    # le fichier nomenclature. Il faudrait mieux qu'il compte le nombre de rubriques par lui
    # même
    it 'crée les 94 rubriks fournies par le fichier yml' do
      @nomen.should have(98).rubriks  
    end
    
    it 'la nomenclature a 4 folios' do
      @nomen.should have(4).folios  
    end
    
  end
  
  describe 'fill_rubrik_with_values' do
    
    subject {@o.nomenclature}
    
    it 'appelle le Job' do
      Delayed::Job.should_receive(:enqueue).with(
        Jobs::NomenclatureFillRubriks.new(@o.database_name,
          @p.id)
      )
      subject.fill_rubrik_with_values(@p)
    end
    
  end



end