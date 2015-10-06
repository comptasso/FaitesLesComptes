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

  subject {@o.nomenclature}

  it 'invalide sans organisme' do
    subject.organism_id = nil
    subject.should_not be_valid
  end

  describe 'with a valid nomenclature' do



    it 'peut restituer ses instructions'  do
      subject.actif.should be_an_instance_of Folio
      subject.passif.should be_an_instance_of Folio
      subject.resultat.should be_an_instance_of Folio
      subject.benevolat.should be_an_instance_of Folio
    end

    it 'actif a des rubriks' do
      subject.actif.should have(31).rubriks
    end

    it 'peut créer une Compta::Nomenclature' do
      subject.compta_nomenclature(@p).should be_an_instance_of(Compta::Nomenclature)
    end

  end




    describe 'fresh_values?' do

      it 'retourne faux si job_finished_at est vide' do
        subject.stub(:job_finished_at).and_return nil
        subject.fresh_values?.should be_false
      end

      context 'mais quand job_finished_at est rempli' do
        it 'retourne vrai si aucune écriture' do
          subject.stub(:job_finished_at).and_return Time.current
          ComptaLine.stub(:maximum).and_return nil
          subject.fresh_values?.should be_true
        end

        it 'vrai si le champ est postérieur à la dernière modification de ComptaLine' do
          ComptaLine.stub(:maximum).and_return(Time.current - 1.day)
          subject.stub(:job_finished_at).and_return Time.current
          subject.fresh_values?.should be_true
        end

        it 'faux si la dernière modification de ComptaLine est plus récente' do
          ComptaLine.stub(:maximum).and_return(Time.current)
          subject.stub(:job_finished_at).and_return(Time.current - 1.day)
          subject.fresh_values?.should be_false
        end
      end

    end







  describe 'check_coherent'  do

      it 'crée Utilities::NomenclatureChecker' do
        Utilities::NomenclatureChecker.should_receive(:new).with(subject).
          and_return(@unc = double(Utilities::NomenclatureChecker, valid?:true))
        subject.coherent?
      end

      it 'et appelle valid? de cet objet' do
        Utilities::NomenclatureChecker.should_receive(:new).with(subject).
          and_return(@unc = double(Utilities::NomenclatureChecker, valid?:'resultat'))
        subject.coherent?.should == @unc.valid?
      end

    end







  # nouvelles spec pour faire évoluer nomenclature qui enregistre actuellement toutes
  # les pages (actif, passif, resultat et bénévolat) dans une logique
  # de rubrik ou  les rubrik sont persistants
  describe 'read and fill rubriks'  do

    # TODO gérer la problématique du test sur un nombre qui évolue lorsqu'on modifie
    # le fichier nomenclature. Il faudrait mieux qu'il compte le nombre de rubriques par lui
    # même
    it 'crée les 94 rubriks fournies par le fichier yml' do
      subject.should have(98).rubriks
    end

    it 'la nomenclature a 4 folios' do
      subject.should have(4).folios
    end

  end

  describe 'fill_rubrik_with_values' do

    it 'appelle le Job' do
      Delayed::Job.should_receive(:enqueue).with(
        Jobs::NomenclatureFillRubriks.new(@t.id, @p.id))
      subject.fill_rubrik_with_values(@p)
    end

  end



end
