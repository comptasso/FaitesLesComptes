# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end


describe Compta::RubrikLine do
  include OrganismFixture

  let(:pp) {mock_model(Period)}
  let(:p) {mock_model(Period, :close_date=>Date.today.end_of_year, 'previous_period?'=>true, previous_period:pp)}
  let(:acc) {mock_model(Account, :sold_at=>-120, number:'201', title:'Un compte')}
  let(:bcc) {mock_model(Account, :sold_at=>-14)}

  before(:each) do
    p.stub_chain(:accounts, :find_by_number).and_return acc
    pp.stub_chain(:accounts, :find_by_number).and_return bcc
  end

  it 'on peut instancier une rubrik_line' do
    @rl = Compta::RubrikLine.new(p, :actif, '201')
    @rl.should be_an_instance_of(Compta::RubrikLine)
  end

  it 'sans option mais à l actif' do
    @rl = Compta::RubrikLine.new(p, :actif, '201')
    @rl.brut.should == 120
    @rl.amortissement.should == 0
  end

  it 'sans option mais au passif' do
    @rl = Compta::RubrikLine.new(p, :passif, '100')
    @rl.brut.should == -120 # le solde n'est pas inversé
    @rl.amortissement.should == 0
  end

  it 'si le compte est un compte d amortissement' do
    @rl = Compta::RubrikLine.new(p, :actif, '2801', :col2)
    @rl.brut.should == 0
    @rl.amortissement.should == - 120 
  end
  
  describe 'correspondance entre passif - credit et actif - debit' do
    
    it 'sait calculer les brut qui vont à l actif et au passif' do
      acc.stub(:sold_at).and_return -120
      Compta::RubrikLine.new(p, :actif, '201', :debit).brut.should == 120
      Compta::RubrikLine.new(p, :actif, '201', :credit).brut.should == 0
    end
    
    it 'sait calculer les brut actif et passif' do
      acc.stub(:sold_at).and_return 99
      Compta::RubrikLine.new(p, :passif, '40', :debit).brut.should == 0
      Compta::RubrikLine.new(p, :passif, '40', :credit).brut.should == 99
    end
    
    
  end

  it 'to_a rencoie les 4 valeurs' do
    @rl = Compta::RubrikLine.new(p, :actif, '201')
    @rl.to_a.should == ['201 - Un compte', 120,0,120,14]
  end

  it 'une rubrique line a une profondeur de -1' do
    Compta::RubrikLine.new(p, :actif, '201').depth.should == -1
  end



  
 
 

end
