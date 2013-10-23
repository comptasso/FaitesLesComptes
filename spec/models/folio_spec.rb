require 'spec_helper'

describe Folio do
  
  def valid_folio
    f = Folio.new(title:'Bilan Actif', name:'actif', sens: :actif)
    f.nomenclature_id = 1
    f
  end
  
  describe 'validations' do
    
    before(:each) do
      @f = valid_folio
    end  
  
    it 'le folio est valide' do
      @f.should be_valid
    end
   
    it 'un folio appartient à une nomenclature' do
      @f.nomenclature_id = nil
      @f.should_not be_valid
    end
  
    it 'un folio est constitué de rubriques'
  
    describe 'attributs obligatoires' do
      it 'le titre' do
        @f.title = nil
        @f.should_not be_valid
        ', un name et un sens'
      end
    
      it 'le nom' do
        @f.name = nil
        @f.should_not be_valid
      end
      
      it 'le nom ne peut être que actif passif resultat et benevolat'
      
      it 'le sens' do
        @f.sens = nil
        @f.should_not be_valid
      end
  
    end
    
    it 'le sens peut être :passif' do
      @f.sens = :passif
      @f.should be_valid
    end
  
    it 'mais pas autre chose' do
      @f.sens = :autre
      @f.should_not be_valid
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
  
  describe 'coherent' do
    
    before(:each) do
      @f = valid_folio
    end  
    
    it 'renvoie faux si un doublon existe' do
      @f.stub(:rough_instructions).and_return(['101', '102', '201', '102'])
      @f.should_not be_coherent
    end
    it 'un folio resultat n utilise que des 6 et 7' do
      
    end
    it 'un folio benevolat n utilise que des rubriks commençant par 8'
    
  end
  
  context 'avec un exercice' do
    it 'all_numbers renvoie tous les numéros de comptes utilisés' 
    
    it 'all_numbers_with_option renvoie les numéros de comptes et les options utilisées'
  end
  
end
