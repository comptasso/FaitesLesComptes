# coding: utf-8

RSpec.configure do |c|
  # c.filter = {wip:true} 
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

describe Nature do 
  include OrganismFixture

  let(:p) {stub_model(Period, :list_months=>ListMonths.new(Date.today.beginning_of_year, Date.today.end_of_year))}
  
  before(:each) do
    @nature = p.natures.new(name: 'Nature test', income_outcome: false)
  end

  it "should be valid" do
    @nature.should be_valid 
  end

  it 'should not be valid without period' do
    @nature.period_id = nil
    @nature.should_not be_valid
  end

  it 'should not be valid without name' do
    @nature.name = nil
    @nature.should_not be_valid
  end

  it 'should not be valid without income_outcome' do
    @nature.income_outcome = nil
    @nature.should_not be_valid
  end

  it 'une nature ne peut être rattachée qu a un compte de classe 6 ou 7' do
     Account.stub(:find_by_id).and_return(@acc = mock_model(Account, number:'120'))
  #   @nature.stub(:account_id).and_return(@acc.id)
     @nature.should_not be_valid
  end

  context 'une nature existe déja' do

    before(:each) do
      @nature = p.natures.create!(name: 'Nature test', income_outcome: false)
    end

    it 'on ne peut créer la même nature' do
      nat = p.natures.new(name: 'Nature test', income_outcome: false)
      nat.should_not be_valid
    end

    it 'sauf si elle est dans l autre sens' do
      nat = p.natures.new(name: 'Nature test', income_outcome: true)
      nat.should be_valid
    end

    it 'sauf si elle est d un autre exercice' do
      p2 = stub_model(Period)
      nat = p2.natures.new(name: 'Nature test', income_outcome: false)
      nat.should be_valid
    end

    it 'une nature empty peut être détruite' do
      expect {@nature.destroy}.to change {Nature.count}.by(-1)
    end

    it 'mais pas si elle n est pas empty' do
      @nature.stub(:compta_lines).and_return [1]
      expect {@nature.destroy}.not_to change {Nature.count}
    end

  describe 'les méthodes statistiques' do
    before(:each) do
      @nature.stub(:period).and_return p
      @nature.stub_chain(:compta_lines, :mois_with_writings, :sum, :to_f, :round).and_return 10
    end

     it 'stat renvoie un tableau de données' do
       @nature.stat_with_cumul.should == 12.times.map {|i| 10 } << 120
     end

      it 'stat peut être filtré avec un argument pour stat_with_cumul' do
        @nature.stub_chain(:compta_lines, :mois_with_writings, :where, :sum, :to_f, :round).and_return 2
        @nature.stat_with_cumul(1).should == 12.times.map {|i| 2 } << 24
      end
  end



  end


  
  
end

