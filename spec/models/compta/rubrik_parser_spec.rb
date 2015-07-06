# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end


describe Compta::RubrikParser do
  include OrganismFixtureBis

  let(:p) {mock_model(Period, 
      :two_period_account_numbers=>%w(12 20 201 206 207 208 2801))}

  describe 'méthode de tri des numéros' do

    before(:each) do
      @rp = Compta::RubrikParser.new(p, :actif, '20 !201')
      Compta::RubrikLine.stub(:new).and_return 'une rubrique line'
    end

    it 'renvoie les numéros retenus' do
      @rp.list_numbers.should == %w(20 206 207 208)
    end

    it 'rubrik_lines' do
      @rp.rubrik_lines.should have(4).rubrik_lines
    end

    it 'raise error si argument mal formé' do
      expect {Compta::RubrikParser.new(p, :actif, '20, 201')}.to raise_error(/argument mal formé/)
    end
  
  end
  
  describe 'traitement du compte RESULT_ACCOUNT' do

    subject {Compta::RubrikParser.new(p, :passif, RESULT_ACCOUNT)}
    
    before(:each) do
      p.stub(:accounts).and_return(@ar = double(Arel))
      p.stub(:resultat).and_return 1234.56
      Compta::RubrikResult.any_instance.stub(:resultat_non_sectorise).and_return 1
   end
    
    it 'renvoie un RubrikResult si le compte est RESULT_ACCOUNT' do
      @ar.stub(:find_by_number).and_return(mock_model(Account, number:'12', sold_at:120.54))
      subject.rubrik_lines.first.should be_an_instance_of(Compta::RubrikResult) 
    end
    
    it 'de même pour un compte commençant par 12' do
      @ar.stub(:find_by_number).and_return(mock_model(Account, number:'1201', sold_at:120.54))
      subject.rubrik_lines.first.should be_an_instance_of(Compta::RubrikResult)
    end
  
  end
  
  describe 'filtre les comptes sur la base du secteur' do
    
#    let(:p) {mock_model(Period, 
#      :two_period_account_numbers=>[@acc1, @acc2])}
    
    before(:each) do
      @sec1 = mock_model(Sector)
      @acc1 = mock_model(Account, sector_id:@sec1.id, number:'6001')
    end
    
    it 'le folio de secteur 1 a un compte' do
      p.should_receive(:two_period_account_numbers).with(@sec1).and_return(['6001'])
      @rp = Compta::RubrikParser.new(p, :actif, '60', @sec1)
#      puts @rp.instance_variable_get('@numeros')
#      puts @rp.instance_variable_get('@numbers')
      @rp.list_numbers.should == ['6001']
    end
    
    
    
  end

  
end
