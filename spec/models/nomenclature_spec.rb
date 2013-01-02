# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe Nomenclature do
  include OrganismFixture

  let(:o) {Organism.create!(title:'titre', :database_name=>'test', status:'Association')}
  let(:p) {mock_model(Period, :organism_id=>o.id)}

  it 'peut lire un fichier yml pour charger ses pages' do
    @n = o.nomenclature
    @n.load_file(File.join(Rails.root, 'spec/fixtures/association/good.yml')) 
    @n.should be_valid
  end

  describe 'with a valid nomenclature' do

    before(:each) do
      @n = o.nomenclature(true)
    end

    it 'peut restituer ses instructions' do
       @n.instructions.should be_an_instance_of(Hash)
       @n[:actif].should be_an_instance_of(Hash)
       @n[:passif].should be_an_instance_of(Hash)
       @n[:resultat].should be_an_instance_of(Hash)
       @n[:benevolat].should be_an_instance_of(Hash)
    end

    it 'la sérialization marche actif a des rubriks' do
      @n[:actif][:rubriks].should be_an_instance_of(Hash)
    end

    it 'peut créer une Compta::Nomenclature' do
      @n.compta_nomenclature(p).should be_an_instance_of(Compta::Nomenclature)
    end

   it 'n est pas valide sans un actif' do
     @n[:actif] = nil
     @n.should_not be_valid
   end

    it 'invalid sans passif' do
      @n[:passif] = nil
      @n.should_not be_valid
    end

    it 'invalid sans resultat' do
      @n[:resultat] = nil
      @n.should_not be_valid
    end

    it 'invalide sans organisme' do
      @n[:organism_id] = nil
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



end