# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 #  c.filter = {wip:true}
end

describe Utilities::NomenclatureChecker do

  include OrganismFixtureBis


  before(:each) do
    use_test_organism
    @nomen  = @o.nomenclature
  end

  subject {Utilities::NomenclatureChecker.new(@nomen)}

  describe 'la nomenclature de test' do
    it 'est valide' do
      subject.should be_valid
      subject.should be_complete
    end
  end

  describe 'Contrôle sur les comptes de résultat' do

    before(:each) do
      @acc_result = @p.accounts.create!(number:'1220',
        title:'Résultat du secteur')
    end

    after(:each) do
      @acc_result.destroy
    end

    it 'non valable avec un compte de résultat non sectorisé' do
      subject.should_not be_valid
    end

    it 'valable si le compte est sectorisé' do
      @acc_result.update_attribute(:sector_id, 2)
      subject.should be_valid
    end


  end

  describe 'Présence des folios : ' do

    before(:each) do
       # inutile de refaire à chaque fois toutes les étapes du contrôle
      # subject.stub(:check_folios_present)
      subject.stub(:folios_coherent?)
      subject.stub(:bilan_balanced?)
      subject.stub(:bilan_no_doublon?)
      subject.stub(:periods_coherent?)
      subject.stub(:sectors_result_compliant?)
    end

    it 'toute nomenclature doit avoir un folio actif' do
      @nomen.stub(:actif).and_return nil
      subject.should_not be_valid
      subject.should_not be_complete
    end

    it 'une nomenclature doit avoir un folio passif' do
      @nomen.stub(:passif).and_return nil
      subject.should_not be_valid
      subject.should_not be_complete
    end
    it 'une nomenclature doit avoir un folio compte de résultats' do
      @nomen.stub(:resultat).and_return nil
      subject.should_not be_valid
      subject.should_not be_complete
    end

    context 'une association ' do

      it 'doit aussi avoir un folio bénévolat' do
        @nomen.stub(:benevolat).and_return nil
        subject.should_not be_valid
        subject.should_not be_complete
      end

      it 'mais pas les autres statuts' do
        @nomen.stub(:benevolat).and_return nil
        @nomen.stub_chain(:organism, :status).and_return('abc')
        subject.should be_valid
        subject.should be_complete
      end

    end

  end

  describe 'bilan balanced et no_doublon' do


    before(:each) do
      @nomen.stub(:actif).and_return(double(Folio, :rough_instructions=>%w(102 506C 407 !805) ) )
       # inutile de refaire à chaque fois toutes les étapes du contrôle
      subject.stub(:check_folios_present)
      subject.stub(:folios_coherent?)
     # subject.stub(:bilan_balanced?)
     # subject.stub(:bilan_no_doublon?)
      subject.stub(:periods_coherent?)
    end

    it 'vrai si un compte C a une correspondance avec un compte D' do
      @nomen.stub(:passif).and_return(double(Folio, :rough_instructions=>%w(202 506D 507 !905)) )
      subject.should be_valid
    end

    it 'faux dans le cas contraire' do
      @nomen.stub(:passif).and_return(double(Folio, :rough_instructions=>%w(202 506 507 !905)) )
      subject.should_not be_valid
    end

    it 'pas de doublons si aucun compte n est répété' do
      @nomen.stub(:passif).and_return(double(Folio, :rough_instructions=>%w(202 506D 507)) )
      subject.should be_valid
    end

    it 'et des doublons dans le cas contraire' do
      @nomen.stub(:passif).and_return(double(Folio, :rough_instructions=>%w(202 506D 407)) )
      subject.should_not be_valid
      @nomen.errors.messages[:bilan].should == ["Une instruction apparait deux fois dans la construction du bilan"]

    end


  end

  describe 'controle des cohérences propres aux folios' do
    before(:each) do

       # inutile de refaire à chaque fois toutes les étapes du contrôle
      subject.stub(:check_folios_present)
      # subject.stub(:folios_coherent?)
      subject.stub(:bilan_balanced?)
      subject.stub(:bilan_no_doublon?)
      subject.stub(:periods_coherent?)

      @f1 = mock_model(Folio, coherent?:true)
      @f2 = mock_model(Folio, coherent?:true)
      @f1.stub_chain(:errors, :full_messages).and_return('je signale une erreur')

    end

    it 'valid? appelle pour chaque folio la cohérence' do
      @nomen.should_receive(:folios).at_least(1).times.and_return([@f1, @f2])
      @f1.should_receive(:coherent?)
      @f2.should_receive(:coherent?)
      subject.valid?
    end

    it 'invalide si un folio n est pas coherent' do
      @nomen.stub(:folios).and_return([@f1, @f2])
      @f1.stub(:coherent?).and_return false
      @f1.stub(:name).and_return 'folio 1'
      subject.should_not be_valid
      @nomen.errors.messages[:folio].should == ["Le folio folio 1 indique une incohérence : je signale une erreur"]
    end
  end

  describe 'contrôle de la cohérence des exercices' do

    before(:each) do
      # inutile de refaire à chaque fois toutes les étapes du contrôle
      subject.stub(:check_folios_present)
      subject.stub(:folios_coherent?)
      subject.stub(:bilan_balanced?)
      subject.stub(:bilan_no_doublon?)
      subject.stub(:sectors_result_compliant?)
    end

    it 'valid vérifie que chaque exercice est cohérent' do
      @o.periods.each do |per|
        subject.should_receive(:period_coherent?).with(per).and_return true
      end
      subject.valid?
    end

    it 'pour chacun des exercices' do
      @nomen.stub_chain(:organism, :periods).and_return([1,2,3])
      subject.should_receive(:period_coherent?).with(1).and_return true
      subject.should_receive(:period_coherent?).with(2).and_return true
      subject.should_receive(:period_coherent?).with(3).and_return true
      subject.valid?
    end

    it 'recopie les erreurs éventuelles' do
      Compta::Nomenclature.any_instance.stub(:valid?).and_return false
      Compta::Nomenclature.any_instance.stub(:errors).and_return('bilan'=>'Manque compte 9999')
      subject.valid?
      @nomen.errors.messages[:bilan].should include("Manque compte 9999")
    end

    it 'met à jour le champ nomenclature_ok de period' do
      Compta::Nomenclature.any_instance.stub(:valid?).and_return true
      @p.update_attribute(:nomenclature_ok, false)
      subject.should be_valid
      @p.reload
      @p.should be_nomenclature_ok
    end

    it 'nomenclatureçk passe à false si une erreur' do
      Compta::Nomenclature.any_instance.stub(:valid?).and_return false
      @p.update_attribute(:nomenclature_ok, false)
      subject.valid?
      @p.reload
      @p.should_not be_nomenclature_ok
    end

  end

end
