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
    {date: Date.today, to_account: @aa, from_account: @ba, amount: 1.5, organism_id: @o.id}
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

    it 'nor without to_account' do

      @transfer.to_account = nil
      @transfer.should_not be_valid

    end

    it 'nor without from_account' do
      @transfer.to_account = nil
      @transfer.should_not be_valid
    end

    it 'amount should be a number' do
      @transfer.amount = 'bonjour'
      @transfer.should_not be_valid
    end

    it 'to_account and from_account should be different' do
      @transfer.to_account = @transfer.from_account
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

    it 'champ obligatoire pour to_account' do
      @tr.to_account=nil
      @tr.valid?
      @tr.errors[:to_account_id].should == ['obligatoire']
    end

    it 'champ obligatoire pour from_account' do
      @tr.from_account=nil
      @tr.valid?
      @tr.errors[:from_account_id].should == ['obligatoire']
    end


  end

  describe 'instance method credit and debit lines' do
    before(:each) do
      @t= Transfer.new(:date=>Date.today, :narration=>'test',
        :organism_id=> @o.id, :amount=>123.50, :from_account_id=>@aa.id, :to_account_id=>@ba.id )
    end

    it 'a new record answers false to partial, debit and credit_locked?' do
      @t.should_not be_partial_locked
      @t.should_not be_to_locked
      @t.should_not be_from_locked
    end

    context 'check save and after_create' do

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
          @t.line_to.should == @t.lines.select { |l| l.debit != 0 }.first
          @t.line_from.should == @t.lines.select { |l| l.credit != 0 }.first
        end

        it 'destroy the transfer should delete the two lines' do
          expect {@t.destroy}.to change {Line.count}.by(-2)
        end
        it 'destroy the transfer is impossible if debit_line locked' do
          @t.line_to.update_attribute(:locked, true)
          @t.should_not be_destroyable
          expect {@t.destroy}.not_to change {Line.count}
        end

        it 'destroy the transfer is impossible if any line locked' do 
          
          l = @t.line_from
          l.locked.should be_false 
          l.locked = true
          l.save!
          
          @t.line_from.locked.should be_true 
          @t.should_not be_destroyable
          expect {@t.destroy}.not_to change {Transfer.count}
        end

        it 'can say what it can edit' do
          @t.line_to.update_attribute(:locked, true)
          @t.to_editable?.should be_false
          @t.from_editable?.should be_true
        end

        describe 'update' do

          before(:each) do
            @t.line_to.account_id.should == @ba.id
            @bc=@o.bank_accounts.create!(name: 'DebiX', number: '456X')
            @ac = @bc.accounts.first
          end

          it 'modify transfer change lines adequatly' do
            @t.to_account = @ac
            @t.save!
            @t.line_to.account_id.should == @ac.id
            @t.line_to.book_id.should == @t.line_to.account.accountable.book.id
          end

          it 'modify transfer change lines adequatly' do
            @t.from_account = @ac
            @t.save!
            @t.line_from.account_id.should == @ac.id
            @t.line_from.book_id.should == @t.line_from.account.accountable.book.id
          end

          context 'line_to locked' do

            before(:each) do
              l= @t.line_to
              l.locked = true
              l.save!(:validate=>false)
            end
          
            it 'modify transfer debit is not possibile if locked' do
              @t.from_account = @ac
              @t.save!
              @t.line_to.account_id.should == @ba.id
            end

            it 'says debit_locked' do
              @t.should be_to_locked
              @t.should be_partial_locked
              @t.should_not be_from_locked
            end


          end

          context 'line_from locked' do

            before(:each) do
              l= @t.line_from
              l.locked = true
              l.save!(:validate=>false)
            end

            it 'modify transfer debit or credit is not possibile if locked' do

              @t.from_account = @ac
              @t.save!
              @t.line_from.account_id.should == @aa.id
            end

            it 'transfer is credit_locked' do 
              @t.should be_from_locked
              @t.should be_partial_locked
              @t.should_not be_to_locked
            end

          end

        end
      end
    end
  end

end
