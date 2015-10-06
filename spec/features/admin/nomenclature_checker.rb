# coding: utf-8

require 'spec_helper'


describe "Periods" do
  include OrganismFixtureBis

  before(:each) do
    use_test_user
    login_as(@cu, 'MonkeyMocha')
    use_test_organism
  end

  it 'l organisme a une nomenclature' do
    n = @p.organism.nomenclature
    n.should be_an_instance_of(Nomenclature)
  end

  it 'la nomenclature a ses folios' do
    n = @p.organism.nomenclature
    n.folios.each {|f| puts f.inspect  }
  end

  it 'la nomenclature est period_coherent' do
    n = @p.organism.nomenclature
    unc = Utilities::NomenclatureChecker.new(n)
    unc.should be_period_coherent(@p)
  end



end
