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
       @n.instructions.should be_an_instance_of(Hash)
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
     @n.should_not be_valid
   end

    it 'invalid sans passif' do
      @n.stub(:passif).and_return nil
      @n.should_not be_valid
    end

    it 'invalid sans resultat' do
      @n.stub(:resultat).and_return nil
      @n.should_not be_valid
    end

    it 'invalide sans organisme' do
      @n.organism_id = nil
      @n.should_not be_valid
    end

  end



  context 'with invalid nomenclature' do

    

    before(:each) do
      create_minimal_organism
      @o.periods.first.accounts.create!(:title=>'Compte non repris', number:'709')
#      @o.nomenclature.load_file(File.join(Rails.root, 'spec/fixtures/association/doublons.yml'))
#      @o.save!
    end

    it 'check_validity renvoie les erreurs trouvées par Compta::Nomenclature' do
      @nome = @o.nomenclature(true)
      @nome.send(:check_validity)
      @nome.errors[:resultat].should ==["Le compte de résultats ne reprend pas tous les comptes 6 et 7. Manque 709 pour Exercice #{Date.today.year}"]
 
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
      @n.should have(90).rubriks  
    end
    
    it 'la nomenclature a 4 folios' do
      @n.should have(4).folios  
    end
    
  end



end