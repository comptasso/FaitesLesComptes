# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe Nomenclature do
  include OrganismFixtureBis 

  let(:o) {Organism.create!(title:'titre', :database_name=>'assotest1', status:'Association')}
  let(:p) {mock_model(Period, :organism_id=>o.id)}

  before(:each) do
    Apartment::Database.switch('assotest1')
    clean_assotest1
  end

  describe 'collect_error' do
    before(:each) do
      @n = o.nomenclature(true)
    end

    it 'renvoie chaine vide si valide' do
      @n.stub(:valid?).and_return true
      @n.collect_errors.should == ''
    end

    it 'renvoie une chaine formattée si invalide' do
      @n.stub(:valid?).and_return false
      @n.stub_chain(:errors, :full_messages).and_return(['une erreur', 'deux erreurs'])
      message =  %q{
La nomenclature utilisée comprend des incohérences avec le plan de comptes. Les documents produits risquent d'être faux.</br>
 Liste des erreurs relevées : <ul>
<li>une erreur</li>
<li>deux erreurs</li>
</ul>}.gsub("\n",'')
      @n.collect_errors.should == message
    end
  end



  describe 'with a valid nomenclature' do

    before(:each) do
      @n = o.nomenclature(true)
    end

    it 'peut restituer ses instructions' do
       
       @n.actif.should be_an_instance_of Folio 
       @n.passif.should be_an_instance_of Folio
       @n.resultat.should be_an_instance_of Folio
       @n.benevolat.should be_an_instance_of Folio
    end

    it 'actif a des rubriks' do
      @n.actif.should have(29).rubriks
    end

    it 'peut créer une Compta::Nomenclature' do
      @n.compta_nomenclature(p).should be_an_instance_of(Compta::Nomenclature)
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
      @n.stub(:resultat).and_return nil
      @n.should_not be_coherent
    end

    it 'invalide sans organisme' do
      @n.organism_id = nil
      @n.should_not be_valid
    end

  end



  describe 'bilan balanced?'  do

    before(:each) do
      @n = o.nomenclature
      @n.stub(:actif).and_return(double(Folio, :rough_numbers=>%w(102 506C 407 !805) ) )
      
    end

    it 'vrai si un compte C a une correspondance avec un compte D' do
      @n.stub(:passif).and_return(double(Folio, :rough_numbers=>%w(202 506D 407 !805)) )
      @n.should be_bilan_balanced
    end
    
    it 'faux dans le cas contraire' do
     @n.stub(:passif).and_return(double(Folio, :rough_numbers=>%w(202 506 407 !805)) )
      @n.should_not be_bilan_balanced
    end


  end
  
  # nouvelles spec pour faire évoluer nomenclature qui enregistre actuellement toutes 
  # les pages (actif, passif, resultat et bénévolat) dans une logique 
  # de rubrik ou  les rubrik sont persistants
  describe 'read and fill rubriks' , wip:true do
    
    before(:each) do
      @n = o.nomenclature  
    end
    
    it 'crée les 94 rubriks fournies par le fichier yml' do
      @n.should have(95).rubriks  
    end
    
    it 'la nomenclature a 4 folios' do
      @n.should have(4).folios  
    end
    
  end



end