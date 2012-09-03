# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|
  config.filter =  {wip:true}
end


describe Account do 
  include OrganismFixture

   before(:each) do
      create_minimal_organism
   end

  it "un account non valide peut être instancié" do
    Account.new.should_not be_valid
  end

  def valid_attributes
    {number:'60',
     title:'Titre du compte',
     period_id:@p.id
    }
  end

  describe 'validations' do

    before(:each) do
      @account = Account.new(valid_attributes)
      puts @account.errors.messages unless @account.valid?
    end
  
    it "should be valid"  do
      @account.should be_valid
    end

    describe 'should not be valid lorsque' do

      it 'sans number' do
        @account.number = nil
        @account.should_not be_valid
      end

      it 'sans title' do
        @account.title =  nil
        @account.should_not be_valid
      end

      it 'sans exercice' do
        @account.period = nil
        @account.should_not be_valid
      end
    end
  end

  describe 'polymorphic', wip:true do
    it 'la création d\'une caisse entraîne celle d\'un compte' do
       @ba.should have(1).accounts
    end

    it 'la création d\'une caisse entraîne celle d\'un compte' do
      @c.accounts.length.should == 1
    end
  end



  describe 'all_lines_locked?' do

    it 'vrai si pas de lignes' do
      Account.new(valid_attributes).should be_all_lines_locked
    end

    context 'avec des lignes' do 
      
    
    before(:each) do
      @account = Account.create!(valid_attributes)
      @n.account_id = @account.id
      @n.save!
      @l1 = @account.lines.create(line_date:Date.today, nature_id:@n.id, debit:0, credit:1, narration:'ligne1', book_id:@ib.id, payment_mode:'Espèces', locked:false)
      @l2 = @account.lines.create!(line_date:Date.today, nature_id:@n.id, debit:0, credit:1, narration:'ligne2',book_id:@ib.id, payment_mode:'Espèces', locked:false)
    end

    it 'faux si des lignes dont au moins une n est pas locked' do
      @account.should_not be_all_lines_locked
    end
    
      it 'false si une ligne est unlocked' do
        @l1.update_attribute(:locked, true)
        
        @account.should_not be_all_lines_locked
      end

      it 'true si toutes les lignes sont locked' do
        @l1.update_attribute(:locked, true)
        @l2.update_attribute(:locked, true)
        @account.should be_all_lines_locked
      end
end

  end

  describe 'fonctionnalités natures' do
    before(:each) do
      @account = Account.create!(valid_attributes)
      @n.account_id = @account.id
      @n.save!
    end

    it 'un compte peut avoir des natures' do
      @account.should have(1).natures
    end
    
   
  end

  
end 

