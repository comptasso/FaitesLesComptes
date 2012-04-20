# coding: utf-8

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

    it 'debitable and creditable should be different' do
      @transfer.debitable = @transfer.creditable
      @transfer.should_not be_valid
    end

  end


  describe 'errors' do

    before(:each) do
      @transfer=Transfer.new(valid_attributes)
    end

    it 'champ obligatoire when a required field is missing' do
      @transfer.amount = nil
      @transfer.valid?
      @transfer.errors[:amount].should == ['champ obligatoire', 'nombre']
    end

    it 'montant ne peut être nul' do
      @transfer.amount = 0
      @transfer.valid?
      @transfer.errors[:amount].should == ['nul !']
    end

    it 'champ obligatoire pour debitable' do
      @transfer.debitable=nil
      @transfer.valid?
      @transfer.errors[:fill_debitable].should == ['champ obligatoire']
    end

    it 'champ obligatoire pour creditable' do
      @transfer.creditable=nil
      @transfer.valid?
      @transfer.errors[:fill_creditable].should == ['champ obligatoire']
    end


  end

  describe 'class method lines' do
    before(:each) do
      @t= Transfer.new(:date=>Date.today, :narration=>'test',
        :organism_id=> @o.id, :amount=>123.50, :creditable_id=>1, :creditable_type=>'Cash' )
    end

    it 'has a method for returning od_id' do
      @t.send(:od_id).should == @o.od_books.first.id
    end

    it 'transfer create a credit line' do
      l = @t.send(:build_credit_line)
      l.should be_an_instance_of Line
      l[:line_date].should == Date.today
      l[:narration].should == 'test'
      l[:credit].should == 123.50
      l[:debit].should == 0.0
      l[:cash_id].should == 1
      l[:bank_account_id].should == nil
      
    end

    it 'can build a debit line for a bank_account' do
      @t= Transfer.new(:date=>Date.today, :narration=>'test', :amount=>123.50,
        :creditable_id=>@ba.id, :creditable_type=>'BankAccount',
        :debitable_id=>@bb.id, :debitable_type =>'BankAccount',
        :organism_id=>@o.id)
      l = @t.send(:build_debit_line)
      l[:cash_id].should == nil
      l[:bank_account_id].should == @bb.id
    end

    it 'create debit line as well' do
      @t= Transfer.new(:date=>Date.today, :narration=>'test', :amount=>123.50,
        :creditable_id=>@ba.id, :creditable_type=>'BankAccount',
        :debitable_id=>@bb.id, :debitable_type =>'BankAccount',
        :organism_id=>@o.id)
      l = @t.send(:build_debit_line)
      l[:credit].should == 0
      l[:debit].should == @t.amount  
      l[:cash_id].should == nil
      l[:bank_account_id].should == @bb.id
      
    end


    context 'check save and after_create' do

      before(:each) do
        @t= Transfer.new(:date=>Date.today, :narration=>'test', :amount=>123.50,
          :creditable_id=>@ba.id, :creditable_type=>'BankAccount',
          :debitable_id=>@bb.id, :debitable_type =>'BankAccount',
          :organism_id=>@o.id)
      end


      it 'save transfer create the two lines' do
        @t.should be_valid
        expect {@t.save}.to change {Line.count}.by(2)
      end

      it 'save transfer create the two lines' do
        @t.save!
        @t.should have(2).lines
      end

      context do

        before(:each) do
          @t.save!
        end
        it 'destroy the transfer should delete the two lines' do
          expect {@t.destroy}.to change {Line.count}.by(-2)
        end
        it 'destroy the transfer is impossible if any line locked' do
          @t.lines.first.update_attribute(:locked, true)
          expect {@t.destroy}.not_to change {Line.count}
        end

        it 'destroy the transfer is impossible if any line locked' do
          @t.lines.last.update_attribute(:locked, true)
          @t.should_not be_destroyable
          expect {@t.destroy}.not_to change {Transfer.count}
        end

        it 'can return the debited line or the credited line' do
          @t.line_debit.should == @t.lines.select { |l| l.debit != 0 }.first
          @t.line_credit.should == @t.lines.select { |l| l.credit != 0 }.first
        end

        it 'can say what it can edit' do
          @t.line_debit.update_attribute(:locked, true)
          @t.debit_editable?.should be_false
          @t.credit_editable?.should be_true
        end


        it 'modify transfer change lines adequatly'
        it 'modify transfer debit or credit is not possibile if locked'
      end
    end
  end

end
