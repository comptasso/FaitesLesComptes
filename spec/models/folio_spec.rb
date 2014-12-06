require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe Folio do
  
  def valid_folio
    f = Folio.new(title:'Bilan Actif', name: :actif, sens: :actif)
    f.nomenclature_id = 1
    f
  end
  
  describe 'validations' do
    
    before(:each) do
       
      @f = valid_folio
    end  
  
  
    describe 'attributs obligatoires' do
      
      before(:each) do
        @f.stub(:no_doublon?).and_return true  
      end
      
      it 'un folio appartient à une nomenclature' do
        @f.nomenclature_id = nil
        @f.should_not be_valid
      end
      
      it 'le titre' do
        @f.title = nil
        @f.should_not be_valid
        ', un name et un sens'
      end
    
      it 'le nom' do
        @f.name = nil
        @f.should_not be_valid
      end
      
      it 'le sens' do
        @f.sens = nil
        @f.should_not be_valid
      end
      
      describe 'le sens' do
      
        it 'peut être :passif ou :actif' do
          @f.sens = :passif
          @f.should be_valid
          @f.sens = :actif
          @f.should be_valid
        end
  
        it 'mais pas autre chose' do
          @f.sens = :autre
          @f.should_not be_valid
        end
      
      end
      
      describe 'le nom' do
        
        before(:each) do
          # car les tests sur le nom de resultat et benevolat déclanchent ces 
          # validations
          @f.stub(:only_67).and_return true
          @f.stub(:only_8).and_return true
        end
        
        it 'peut être actif passif resultat ou benevolat' do
          
          names = [:actif, :passif, :resultat, :benevolat]
          names.each do |name|
            @f.name = name
            @f.should be_valid
          end
        end
        it 'mais pas autre chose' do
          @f.name = :autre
          @f.should_not be_valid
        end
        
      end
      
    end
  end

  describe 'fill_rubriks_with_position', wip:true do
    
#     {:actif=>{:title=>"BILAN ACTIF", :sens=>:actif, :rubriks=>{:"TOTAL ACTIF"=>{:IMMOBILISATIONS=>{:"Immobilisations incorporelles"=>{:"Frais d'établissement"=>"201 -2801", :"Frais de recherche et développement"=>"203 -2803", :"Fonds commercial"=>"206 207 -2806 -2807", :Autres=>"208 -2808 -2809"},
    
    before(:each) do
     Rubrik.delete_all
     Folio.delete_all
     @fol = valid_folio
     @fol.save!
     @rubriks = {'Produits financier'=>{'interets'=>'65'}}
    end
    
    it 'peut créer des rubriques' do
      expect {@fol.fill_rubriks_with_position(@rubriks)}.to change {Rubrik.count}.by(2)
    end
    
    it 'la première n est pas une feuille' do
      @fol.fill_rubriks_with_position(@rubriks)
      Rubrik.first.should_not be_leaf
    end
    
    it 'mais le seconde l est' do
      @fol.fill_rubriks_with_position(@rubriks)
      Rubrik.last.should be_leaf
    end
    
    
  end

  
  describe 'méthodes d accès aux rubriques et instructions' do
    
    before(:each) do
      @f = valid_folio
    end  
  
    it 'root renvoie la rubrique racine' do
      @f.should_receive(:rubriks).and_return(@ar = double(Arel))
      @ar.should_receive(:root).and_return('la racine')
      @f.root.should == 'la racine'
    end
  
    describe 'all_instructions' do
      it 'si root est une feuille, renvoie les numéros de root' do
        @f.stub(:root).and_return(Rubrik.new(numeros:'101 102'))
        @f.all_instructions.should == ['101 102']
      end
      
      it 'all instructions renvoie l ensemble des instructions des rubriks' do
        @f.stub(:root).and_return(@rub = double(Rubrik))
        @rub.should_receive(:all_instructions).and_return(['101 102', '201'])
        @f.all_instructions.should == ['101 102', '201']
      end
  
    end
  
    it 'rough_instructions met en forme les instructions retournées par all_instructions' do
      @f.should_receive(:all_instructions).and_return ['101 102', '201']
      @f.rough_instructions.should == ['101', '102', '201']
    end
  
  end
  
  describe 'coherent'  do
    
    before(:each) do
      @f = valid_folio
    end 
    it ' si pas de doublon' do
      @f.stub(:rough_instructions).and_return(['101', '102', '201', '103'])
      @f.should be_coherent
    end
    
    it 'incoherente sinon' do
      @f.stub(:rough_instructions).and_return(['101', '102', '201', '102'])
      @f.should_not be_coherent
    end
    
    context 'un folio de type resultat' do
    
      before(:each) do
        @f.name = :resultat
      end
      
      it 'un folio resultat avec uniquement des comptes 6 et 7 est coherente' do
        
        @f.stub(:rough_instructions).and_return(['61', '62', '71', '72'])
        @f.should be_coherent
      end
      it 'un folio resultat avec un compte autre que 6 et 7 est incoherente' do
        
        @f.stub(:rough_instructions).and_return(['61', '62', '53', '71', '72'])
        @f.should_not be_coherent
      end
    
    end
    
    
    context 'un folio de type resultat' do
    
      before(:each) do
        @f.name = :benevolat
      end
      it 'un folio benevolat n utilise que des rubriks commençant par 8' do
        
        @f.stub(:rough_instructions).and_return(['81', '52', '84', '72'])
        @f.should_not be_coherent
      end
      
      it 'mais coherente dans le cas contraire' do
        @f.stub(:rough_instructions).and_return(['81', '82', '84', '8201'])
        @f.should be_coherent
      end
    end
    
  end
  
  context 'avec un exercice', wip:true do
    before(:each) do
      @f = valid_folio
      @per = double(Period)
      Compta::RubrikParser.any_instance.stub(:new).and_return(double(Compta::RubrikParser, :list=>['101', '102']))
    end
    
    
    
    it 'all_numbers_with_option renvoie les numéros de comptes et les options utilisées' do
      @f.should_receive(:all_instructions).and_return(['un', 'deux'])
      Compta::RubrikParser.should_receive(:new).with(@per, :actif, 'un', nil).
        and_return(double(Compta::RubrikParser, :list=>[{:num=>'251012', :option=>'col2'}]))
      Compta::RubrikParser.should_receive(:new).with(@per, :actif, 'deux', nil).
        and_return(double(Compta::RubrikParser, :list=>[{:num=>'101', :option=>nil}, {:num=>'102', :option=>nil}]))
      @f.all_numbers_with_option(@per).should == [{:num=>'251012', :option=>'col2'}, {:num=>'101', :option=>nil}, {:num=>'102', :option=>nil}]
    end
    
    it 'all_numbers renvoie tous les numéros de comptes utilisés' do
      # @f.stub(:all_instructions).and_return(['un', 'deux'])
      @f.should_receive(:all_numbers_with_option).with(@per).
        and_return([{num:'101', option:nil}, {num:'102', option:nil}])
      @f.all_numbers(@per).should == ['101', '102']
    end
  end
  
end
