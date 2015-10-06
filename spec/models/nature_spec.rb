# coding: utf-8

RSpec.configure do |c|
  # c.filter = {wip:true}
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Nature do
  include OrganismFixtureBis

  let(:p) {stub_model(Period,
      :list_months=>ListMonths.new(Date.today.beginning_of_year, Date.today.end_of_year))}
  let(:b) {stub_model(Book, title:'Le titre', type:'IncomeBook')}

  before(:each) do
    Tenant.set_current_tenant(1)
    @nature = Nature.new(name: 'Nature test', book_id:1, period_id:1)
    @nature.stub(:book).and_return(b)
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

  it 'should not be valid without book_id' do
    @nature.book_id = nil
    @nature.should_not be_valid
  end

  it 'une nature ne peut être rattachée qu a un compte de classe 6 ou 7' do
    # @nature.stub_chain(:book, :type).and_return('IncomeBook')
    Account.stub(:find_by_id).and_return(@acc = mock_model(Account, number:'120'))
    @nature.should_not be_valid
  end

  context 'avec une nature' do

    before(:each) do
      Nature.any_instance.stub(:period).and_return p
      p.stub(:organism).and_return(@ar = double(Arel))
      @ar.stub(:masks).and_return @ar
      @ar.stub(:filtered_by_name).and_return []
      @nature = p.natures.new(name: 'Nature test')
      @nature.book_id = 1
      @nature.save!
    end

    after(:each) do
      Nature.delete_all
    end

    it 'on ne peut créer la même nature' do
      nat = p.natures.new(name: 'Nature test')
      nat.book_id = 1
      nat.should_not be_valid
    end

    it 'sauf si elle dépend d un autre livre' do
      nat = p.natures.new(name: 'Nature test'); nat.book_id = 2
      nat.should be_valid
    end

    it 'sauf si elle est d un autre exercice' do
      p2 = stub_model(Period)
      nat = p2.natures.new(name: 'Nature test'); nat.book_id = 1
      nat.should be_valid
    end

    it 'une nature empty peut être détruite' do
      expect {@nature.destroy}.to change {Nature.count}.by(-1)
    end

    it 'mais pas si elle n est pas empty' do
      @nature.stub(:compta_lines).and_return [1]
      expect {@nature.destroy}.not_to change {Nature.count}
    end



  end

  describe 'position d une nouvelle nature' do

    before(:each) do
      Account.any_instance.stub(:sectorise_for_67).and_return true
      @accounts = create_accounts(%w(110 200 201))
      Nature.any_instance.stub(:period).and_return p
      p.stub(:organism).and_return(@ar = double(Arel))
      @ar.stub(:masks).and_return @ar
      @ar.stub(:filtered_by_name).and_return []
      @accounts.each do |a|
        n = Nature.create!(book_id:1,
          account_id:a.id, name:"nature#{a.number}", period_id:1)
      end
    end

    after(:each) do
      @accounts.each(&:destroy)
      Nature.destroy_all
    end

    it 'une nouvelle nature se met à la position dans l ordre des comptes' do
      acc = @accounts.second
      n = Nature.create(book_id:1, account_id:acc.id, name:'nouveau', period_id:1)
      n.reload
      n.position.should == 2
    end

    it 'elle peut être en premier' do
      begin
        acc = create_accounts(['100']).first
        n = Nature.create!(book_id:1, account_id:acc.id, name:'nouveau', period_id:1)
        n.position.should == 1
      ensure
        acc.destroy
      end
    end

    it 'ou en dernier' do
      begin
        acc = create_accounts(['300']).first
        n = Nature.create!(book_id:1, account_id:acc.id, name:'nouveau', period_id:1)
        n.position.should == 4
      ensure
        acc.destroy
      end
    end

  end

  describe 'les statistiques' do
    before(:each) {use_test_organism}

    it 'renvoie une table de lignes' do
      expect(Nature.statistics(@p)).to be_instance_of(Array)
    end

    it 'avec autant de lignes que de natures' do
      expect(Nature.statistics(@p).size).to eq(@p.natures.count)
    end

    it 'chaque ligne comprend le nom de la nature suivi de 13 valeurs (des 0 ici)' do
      expect(Nature.statistics(@p).first).to eq(
        ['Vente produits finis'] + 13.times.collect {0}      )
    end

    context 'avec une écritures', wip:true do

      before(:each) do
        @w = create_outcome_writing # montant 99, nature @n, pas de destination
      end

      after(:each) do
        erase_writings
      end

      context 'avec une destination' do

        before(:each) do
          @dest1 = @o.destinations.first
          @w.in_out_line.destination_id = @dest1.id
          @w.save!
          @m = @w.date.month
        end

        it 'la ligne de la nature @n contient le montant de 99 pour le mois en cours' do
          ligne = Nature.statistics(@p).select {|r| r[0] == @n.name}.first
          expect(ligne).to eq([@n.name] + (@m-1).times.collect {0} + [-99.0] + (12-@m).times.collect {0} + [-99.0])
        end

        it 'de même si filtre sur la destinations' do
          ligne = Nature.statistics(@p, [@dest1.id]).select {|r| r[0] == @n.name}.first
          expect(ligne).to eq([@n.name] + (@m-1).times.collect {0} + [-99.0] + (12-@m).times.collect {0} + [-99.0])
        end

        it 'mais pas sur une autre destination' do
          n = @dest1.id + 1
          ligne = Nature.statistics(@p, [n]).select {|r| r[0] == @n.name}.first
          expect(ligne).to eq([@n.name] + (13).times.collect {0})
        end

      end

      # TODO Pour être vraiment certain de la qualité de la requête, il
      # faudrait créer une base test, non modifiée, avec suffisemment d'écritures
      # sur deux ou trois exercices. Ce qui permettrait aussi de tester toutes
      # les éditions.

    end

  end








end

