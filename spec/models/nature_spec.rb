# coding: utf-8

RSpec.configure do |c|
  # c.filter = {wip:true} 
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

describe Nature do 
  include OrganismFixtureBis

  let(:p) {stub_model(Period, :list_months=>ListMonths.new(Date.today.beginning_of_year, Date.today.end_of_year))}
  let(:b) {stub_model(Book, title:'Le titre', type:'IncomeBook')}
  
  before(:each) do
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

  context 'une nature existe déja' do

    before(:each) do
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
  
  describe 'position d une nouvelle nature', wip:true  do
    
      
    
    before(:each) do
      Account.any_instance.stub(:sectorise_for_67).and_return true
      @accounts = create_accounts(%w(110 200 201)) 
      @accounts.each do |a|
        n = Nature.create!(book_id:1,
          account_id:a.id, name:"nature#{a.number}", period_id:1)          
        end
    end
      
    after(:each) do
      @accounts.each(&:destroy) 
      Nature.destroy_all 
    end
    
#    it 'liste les positions' do
#      @accounts.each {|a| puts a.inspect}
#      Nature.find_each {|n| puts n.inspect}
#    end   
    
    
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



  


  
  
end

