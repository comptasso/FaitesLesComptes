require 'spec_helper'

RSpec.configure do |c|
   c.filter = {:wip=>true}
end

describe Rubrik do
  include OrganismFixtureBis
  
  context 'avec un organisme dans la base de donnée' do
  
    before(:each) do
    
      create_organism
      @r = Rubrik.find_by_name('RESULTAT FINANCIER').children.first
    end
  
    it 'la rubrique existe' do
      @r.should be_an_instance_of(Rubrik)
    end
  
    it 'sa prefondeur est de deux' do
      @r.depth.should == 2
    end
  
    it 'title est synonime de name' do
      @r.title.should == @r.name
    end
  
    it 'sa position est respectée' do 
      @r.position.should == 23
      @r.folio.rubriks.find_by_position(24).name.should == 'Produits financiers'
      @r.folio.rubriks.find_by_position(22).name.should == 'RESULTAT FINANCIER'
    end
    
    describe 'fetch_lines'  do
       before(:each) do
         Rubrik.any_instance.stub(:lines).and_return ['une serie de lignes terminales']
       end
       
       it 'le tableau de lignes doit comporter 5 lignes' do
         @r.fetch_lines(@p).size.should == 5
         # la ligne de détail des produits financiers plus la rubrik Produits Financiers
         # idem pour reprise de provisions financières
         # et enfin le regroupement de Produits financiers
       end
    end
    
    describe 'lines', wip:true do
      
      it 'return children si la rubrik n est pas un leaf' do
        @rub = Rubrik.new
        @rub.stub(:children).and_return 'les enfants'
        @rub.stub('leaf?').and_return false
        @rub.lines(@p).should == 'les enfants'
      end
      
      it 'retourne un rubrik_result si c est un leaf et un resultat' do
        @r
        @r.stub('leaf?').and_return true
        @r.stub('resultat?').and_return true
        Compta::RubrikResult.should_receive(:new).with(@p, :passif, '12').and_return(@rr = double(Compta::RubrikResult))
        @r.lines(@p).should == [@rr]
      end
      
      it 'retourne all_lines si c est un leaf non résultat' do
        @rub = Rubrik.new
        @rub.stub('leaf?').and_return true
        @rub.stub('resultat?').and_return false
        @rub.should_receive(:all_lines).and_return 'mes lignes'
        @rub.lines(@p).should == 'mes lignes'
      end
      
    end
  
  
  end
  
  describe 'Resultats' do
    
    context 'une rubrique est une rubrique de resultat si' do
      
      before(:each) do
        @res = Rubrik.new(numeros:'125 12 13')
      end
      
      it 'si c est une feuille terminale et si la liste des numéros contient 12' do
        @res.stub('leaf?').and_return true
        @res.should be_resultat
      end
      
      it 'mais pas si 12 n est pas dans la liste' do
        @res.numeros = '125 13'
        @res.stub('leaf?').and_return true 
        @res.should_not be_resultat
      end
      
      it 'mais pas si ce n est pas une feuille terminale' do
        @res.stub('leaf?').and_return false
        @res.should_not be_resultat
      end
      
    end
    
  end
  
  describe 'all_instructions', wip:true do
    
    before(:each) do
        @res = Rubrik.new(numeros:nil)
        @res.stub(:children).and_return([Rubrik.new(numeros:'401 402'),
            Rubrik.new(numeros:'501 502'),
          ])
      end
    
    it 'une rubrik peut collecter ses instructions et celles de ses enfants en éliminant les numéros nil' do
      @res.all_instructions.should == ['401 402', '501 502']
    end
    
    
    
  end
  
  
  
end
