# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end


describe Compta::RubrikLine do
  include OrganismFixtureBis

  let(:pp) {mock_model(Period)}
  let(:p) {mock_model(Period, :close_date=>Date.today.end_of_year, 'previous_period?'=>true, previous_period:pp, :previous_account=>bcc)}
  let(:acc) {mock_model(Account, :sold_at=>-120, number:'201', title:'Un compte')}
  # TODO il faudrait utiliser ici aussi sold_at plutôt que final_sold pour gagner en rapidité.
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

  it 'to_a rencoie les 5 valeurs', wip:true do
    @rl = Compta::RubrikLine.new(p, :actif, '201')
    @rl.to_a.should == ['201 - Un compte', 120,0,120,14]
  end

  it 'to_passif renvoie un array avec le titre, le net et le previous_net' do
    @rl = Compta::RubrikLine.new(p, :actif, '201')
    @rl.to_passif.should == ['201 - Un compte', 120,14]
  end

  it 'to actif est un alial de to_a' do
    @rl = Compta::RubrikLine.new(p, :actif, '201')
    @rl.to_actif.should == @rl.to_a
  end

  it 'une rubrique line a une profondeur de -1' do
    Compta::RubrikLine.new(p, :actif, '201').depth.should == -1
  end

  it 'sait rendre un csv' do
    pending 'en attente de vérification que cette méthode (to_csv) soit bien utilisée'
    @rl = Compta::RubrikLine.new(p, :actif, '201')
    @rl.to_csv.should == "201\t201 - Un compte\t120\t0\t120\t14\n" 
  end
  
  describe 'previous_net' do
    context 'lorsque le compte n existe pas dans l exercice' do
      
      it 'recherche le compte dans l exercice précédent' do
        p.stub_chain(:accounts, :find_by_number).and_return nil
        pp.should_receive(:accounts).and_return( @ar=double(Arel))
        @ar.should_receive(:find_by_number).with('385').and_return mock_model(Account, :sold_at=>-150)
        rl = Compta::RubrikLine.new(p, :actif, '385')
        rl.previous_net.should == 150.00
      end
      
    end

  end

  
 
 

end
