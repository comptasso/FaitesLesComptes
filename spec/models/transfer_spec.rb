# coding: utf-8

require 'spec_helper'

describe Transfer , :wip=>true do
  include OrganismFixture

  
 
  before(:each) do
    create_minimal_organism 
    @bb=@o.bank_accounts.create!(name: 'DebiX', number: '123Y')
    @aa = @ba.accounts.first
    @ba = @bb.accounts.first
  end 

  def valid_attributes
    {date: Date.today, debitable: @aa, creditable: @ba, amount: 1.5, organism_id: @o.id}
  end

  describe 'virtual attribute pick date' do
  
    before(:each) do
      @transfer=Transfer.new(valid_attributes)
    end
    
    it "should store date for a valid pick_date" do
      @transfer.date_picker = '06/06/1955'
      @transfer.date.should == Date.civil(1955,6,6)
    end 

    it 'should return formatted date' do
      @transfer.date =  Date.civil(1955,6,6)
      @transfer.date_picker.should == '06/06/1955'
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
      @tr = Transfer.new(valid_attributes)
    end

    it 'champ obligatoire when a required field is missing' do
      @tr.amount = nil
      @tr.valid?
      @tr.errors[:amount].should == ['obligatoire', 'doit être un nombre']
    end

    it 'montant ne peut être nul' do
      @tr.amount = 0
      @tr.valid?
      @tr.errors[:amount].should == ['nul !']
    end

    it 'champ obligatoire pour debitable' do
      @tr.debitable=nil
      @tr.valid?
      @tr.errors[:debitable_id].should == ['obligatoire']
    end

    it 'champ obligatoire pour creditable' do
      @tr.creditable=nil
      @tr.valid?
      @tr.errors[:creditable_id].should == ['obligatoire']
    end


  end

  describe 'instance method credit and debit lines' do
    before(:each) do
      @t= Transfer.new(:date=>Date.today, :narration=>'test',
        :organism_id=> @o.id, :amount=>123.50, :creditable_id=>1, :creditable_type=>'Cash' )
    end

    it 'a new record answers false to partial, debit and credit_locked?' do
      @t.should_not be_partial_locked
      @t.should_not be_debit_locked
      @t.should_not be_credit_locked
    end

    it 'has a method for returning od_id' do
      @t.send(:od_id).should == @o.od_books.first.id
    end

    


    context 'check save and after_create' do

      before(:each) do
        @t= Transfer.new(:date=>Date.today, :narration=>'test', :amount=>123.50,
          :creditable_id=>@aa.id, :creditable_type=>'BankAccount',
          :debitable_id=>@ba.id, :debitable_type =>'BankAccount',
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



      context 'with a saved tranfer' do

        before(:each) do
           @t.save!
        end

        it 'can return the debited line or the credited line' do
          @t.line_debit.should == @t.lines.select { |l| l.debit != 0 }.first
          @t.line_credit.should == @t.lines.select { |l| l.credit != 0 }.first
        end

        it 'destroy the transfer should delete the two lines' do
          expect {@t.destroy}.to change {Line.count}.by(-2)
        end
        it 'destroy the transfer is impossible if debit_line locked' do
          @t.line_debit.update_attribute(:locked, true)
          @t.should_not be_destroyable
          expect {@t.destroy}.not_to change {Line.count}
        end

        it 'destroy the transfer is impossible if any line locked' do
          
          l = @t.line_credit
          l.locked.should be_false 
          l.locked = true
          l.save!
          
          @t.line_credit.locked.should be_true
          @t.should_not be_destroyable
          expect {@t.destroy}.not_to change {Transfer.count}
        end

        it 'can say what it can edit' do
          @t.line_debit.update_attribute(:locked, true)
          @t.debit_editable?.should be_false
          @t.credit_editable?.should be_true
        end

        describe 'update' do

          before(:each) do
            @t.line_debit.counter_account_id.should == @ba.id
            @bc=@o.bank_accounts.create!(name: 'DebiX', number: '456X')
            @ac = @bc.accounts.first
          end

          it 'modify transfer change lines adequatly' do
            @t.debitable = @ac
            @t.save!
            @t.line_debit.counter_account_id.should == @ac.id
          end

          it 'modify transfer change lines adequatly' do
            @t.creditable = @ac
            @t.save!
            @t.line_credit.counter_account_id.should == @ac.id
          end

          context 'line_debit locked' do

            before(:each) do
              l= @t.line_debit
              l.locked = true
              l.save!(:validate=>false)
            end
          
            it 'modify transfer debit is not possibile if locked' do
              @t.creditable = @ac
              @t.save!
              @t.line_debit.counter_account_id.should == @ba.id
            end

            it 'says debit_locked' do
              @t.should be_debit_locked
              @t.should be_partial_locked
              @t.should_not be_credit_locked
            end


          end

          context 'line_credit locked' do

            before(:each) do
              l= @t.line_credit
              l.locked = true
              l.save!(:validate=>false)
            end

            it 'modify transfer debit or credit is not possibile if locked' do

              @t.creditable = @ac
              @t.save!
              @t.line_credit.counter_account_id.should == @aa.id
            end

            it 'transfer is credit_locked' do 
              @t.should be_credit_locked
              @t.should be_partial_locked
              @t.should_not be_debit_locked
            end

          end

        end
      end
    end
  end

end
