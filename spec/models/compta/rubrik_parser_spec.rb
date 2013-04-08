# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end


describe Compta::RubrikParser do
  include OrganismFixture

  let(:p) {mock_model(Period, 
      :two_period_account_numbers=>%w(20 201 206 207 208 2801))}

  # Dans le fichier asso.yml, les immos incorporelles ont
  # 4 comptes à 3 chiffres : 201, 206 et 208
  #
  def list_immo
    '20 201 206 207 208 -2801'
  end

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
