require 'spec_helper'

describe Transfer do
  include OrganismFixture

  before(:each) do
    create_minimal_organism
    @bb=@o.bank_accounts.create!(name: 'DebiX', number: '123Y')
  end

  def valid_attributes
    {date: Date.today, debitable: @ba, creditable: @bb, amount: 1.5, organism_id: @o.id}
  end

  context 'virtual attribute pick date' do
  
    before(:each) do
      @transfer=Transfer.new(valid_attributes)
    end
    
    it "should store date for a valid pick_date" do
      @transfer.pick_date = '06/06/1955'
      @transfer.date.should == Date.civil(1955,6,6)
   end

    it 'should return formatted date' do
      @transfer.date =  Date.civil(1955,6,6)
      @transfer.pick_date.should == '06/06/1955'
    end
 
  end

  describe 'virtual attribute fill_debitable' do

     before(:each) do
      @transfer=Transfer.new(:debitable_type=>'Model', :debitable_id=>'9')
    end
    

    it 'fill_debitable = ' do
      @transfer.fill_debitable=('Model_6')
      @transfer.debitable_id.should == 6
      @transfer.debitable_type.should == 'Model'
    end

    it 'debitable concat type and id' do
      @transfer.fill_debitable.should == 'Model_9'
    end

  end

  describe 'virtual attribute creditable' do

     before(:each) do
      @transfer=Transfer.new(:creditable_type=>'Model', :creditable_id=>'9')
    end


    it 'fill_creditable = ' do
      @transfer.fill_creditable= 'Model_6'
      @transfer.creditable_id.should == 6
      @transfer.creditable_type.should == 'Model'
    end

    it 'fill_creditable concat type and id' do
      @transfer.fill_creditable.should == 'Model_9'
    end

  end

  describe 'validations' do

    before(:each) do
      @transfer=Transfer.new(valid_attributes)
    end

    it 'should be valid with valid attributes' do
      @transfer.should be_valid
    end

    it 'but not without a date' do
      @transfer.date = nil
      @transfer.should_not be_valid
    end

    it 'nor without amount' do
      @transfer.amount = nil
      @transfer.should_not be_valid
    end

    it 'nor without debitable' do

      @transfer.debitable = nil
      @transfer.should_not be_valid

    end

    it 'nor without creditable' do
      @transfer.debitable = nil
      @transfer.should_not be_valid
    end

    it 'amount should be a number' do
      @transfer.amount = 'bonjour'
      @transfer.should_not be_valid
    end
  end


end
