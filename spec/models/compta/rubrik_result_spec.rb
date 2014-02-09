# coding: utf-8

require 'spec_helper'

describe Compta::RubrikResult do

  before(:each) do
    @p = mock_model(Period, :resultat=>19)
    @p.stub_chain(:accounts, :find_by_number).and_return(mock_model(Account, :sold_at=>51.25))

  end

  it 'se crée avec un exercice' do
    Compta::RubrikResult.new(@p, :passif, '12').should be_an_instance_of(Compta::RubrikResult)
  end

  it 'initialise ses valeurs' do
    @rr = Compta::RubrikResult.new(@p, :passif, '12')
    @rr.brut.should == 70.25  # le solde 51.25 plus le résultat : 19)
    @rr.amortissement.should == 0
  end

  it 'ne crée pas d erreur si pas de compte' do
    @p.stub_chain(:accounts, :find_by_number).and_return(nil)
    @p.stub(:organism).and_return((mock_model(Organism, :title=>'Ma petite affaire')))
    @rr = Compta::RubrikResult.new(@p, :passif, '12')
    @rr.brut.should == 19
    @rr.amortissement.should == 0
  end

  describe 'previous_net' do

    before(:each) do
      @rr = Compta::RubrikResult.new(@p, :passif, '12')
    end

  it 'previous net renvoie 0 si pas de previous_period' do
    @p.stub('previous_period?').and_return false
     @rr.previous_net.should == 0
  end

    it 'demande le résultat si un period précédent' do
      @p.stub('previous_period?').and_return true
      @p.stub(:organism).and_return((mock_model(Organism, :title=>'Ma petite affaire')))
      @q = mock_model(Period)
      @q.stub(:organism) {mock_model(Organism, :title=>'Ma petite affaire')}
      @p.should_receive(:previous_period).and_return(@q)
      @q.stub_chain(:accounts, :find_by_number).and_return(double(Account, :sold_at=>5))
      @q.should_receive(:resultat).and_return 22
      @rr.previous_net.should == 27
    end

  end

end


