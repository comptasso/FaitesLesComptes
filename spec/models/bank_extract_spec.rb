# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|
   #  c.filter = {:wip=> true } 
end

describe BankExtract do 
  include OrganismFixture
  
  
  before(:each) do
    create_minimal_organism 
    @p2012 = @p
    # @be1 est entièrement en 2011
    @be1= @ba.bank_extracts.create!(bank_account_id: @ba.id, begin_date: Date.civil(2011,10,01), end_date: Date.civil(2011,10,31), begin_sold: 2011, total_credit: 11, total_debit: 10)
    # @be2 est entièrement en 2012
    @be2= @ba.bank_extracts.create!(bank_account_id: @ba.id, begin_date: Date.civil(2012,10,01), end_date: Date.civil(2012,10,31), begin_sold: 2012, total_credit: 11, total_debit: 10)


  end

  describe 'date_pickers' do
    it 'begin_date_picker' do
      @be1.begin_date_picker.should == I18n.l(@be1.begin_date)
    end

    it 'end_date_picker' do
      @be1.end_date_picker.should == I18n.l(@be1.end_date)
    end

    it 'begin_date=' do
      @be2.begin_date_picker = I18n.l Date.today
      @be2.begin_date.should == Date.today
    end

    it 'invalid model if date not acceptable' do
      @be2.begin_date_picker = 'bonjour'
      @be2.valid?
      @be2.should have(1).errors_on(:begin_date_picker)
      @be2.errors[:begin_date_picker].should ==  ['Date invalide']
    end
  end


  describe "vérification du scope period" do

    before(:each) do
    @p2011 = @o.periods.create!(start_date:Date.today.years_ago(1).beginning_of_year, close_date:Date.today.years_ago(1).end_of_year)
    end
    it "le spec de period renvoie @be1 pour 2011 et @be2 pour 2012" do
      @ba.bank_extracts.period(@p2011).should == [@be1]
      @ba.bank_extracts.period(@p2012).should == [@be2]
    end

    it "lorsqu'il y a un extrait à cheval, il est intégré dans les deux requêtes" do
      @be12= @ba.bank_extracts.create!(bank_account_id: @ba.id, begin_date: Date.civil(2011,12,15), end_date: Date.civil(2012,1,15), begin_sold: 2011, total_credit: 2012, total_debit: 10)
      @ba.bank_extracts.period(@p2011).should == [@be1, @be12]
      @ba.bank_extracts.period(@p2012).should == [@be12,@be2]
    end

    it 'les limites de dates sont avec des <= et non des <' do
      @be12= @ba.bank_extracts.create!(bank_account_id: @ba.id, begin_date: Date.civil(2011,12,15), end_date: Date.civil(2011,12,31), begin_sold: 2011, total_credit: 2012, total_debit: 10)
      @be21= @ba.bank_extracts.create!(bank_account_id: @ba.id, begin_date: Date.civil(2012,01,01), end_date: Date.civil(2012,1,31), begin_sold: 2011, total_credit: 2012, total_debit: 10)
      @ba.bank_extracts.period(@p2011).should == [@be1, @be12]
      @ba.bank_extracts.period(@p2012).should == [@be21,@be2]
    end

  end

  describe 'vérification des attributs' do

    def valid_attributes
      {:bank_account_id=>@ba.id, begin_sold:0, total_debit:1,
      total_credit:2, begin_date:Date.today, end_date:Date.today}
    end

    before(:each) do
      @be=BankExtract.new(valid_attributes) 
    end

    it 'valid begin sold' do
      @be.should be_valid
    end

    it 'end_sold doit être présent' do
      @be.begin_sold = nil
      @be.should_not be_valid
      # puts @be.errors.messages
      @be.should have(3).errors_on(:begin_sold) # numericality presence et format 
    end

    it 'pas valide sans begin_date' do 
      @be.begin_date = nil
      @be.should_not be_valid 
    end

    it 'pas valide sans end_date' do
      @be.end_date = nil
      @be.should_not be_valid
    end

    it 'pas valide sans total_debit' do
      @be.total_debit = nil
      @be.should_not be_valid
    end

    it 'pas valide sans total_credit' do
      @be.total_credit = nil
      @be.should_not be_valid
    end

    it 'begin_sold doît être un nombre' do
      @be.begin_sold = 'bonjour'
      @be.begin_sold.should  == 0
    end

    it 'les valeurs sont enregistrees avec 2 decimales' do
      @be.begin_sold = 1.124
      @be.save
      @be.begin_sold.should == 1.12
    end

     it 'les valeurs sont arrondies par valid' do
      @be.begin_sold = 1.124
      @be.valid?
      @be.begin_sold = 1.12
    end


    
  end

  describe 'when locked' do

    before(:each) do
      @be = @ba.bank_extracts.create!(:begin_date=>Date.today, end_date:Date.today, begin_sold:1,
        total_debit:1, total_credit:2)
      @be.locked = true
      @be.save!
    end

    it 'cant be edited' do
      @be.begin_sold = 0
      @be.should_not be_valid
      @be.errors.should have(1).error_on(:begin_sold)
    end
  end

  describe 'contrôle des bank_extract_lines' do

    before(:each) do
      @l1 = Line.new(narration:'bel', line_date:Date.today, debit:0, credit:97, payment_mode:'Chèque', book_id:@ib.id, nature_id:@n.id)
      @l1.valid?
      @l1.should be_valid
      @l1.save!
      

      @cd = CheckDeposit.create!(bank_account_id:@ba.id, deposit_date:(Date.today + 1.day)) 
      @cd.checks << @l1
      @cd.save!

      @l2 = Line.create!(narration:'bel', line_date:Date.today, debit:13, credit:0, payment_mode:'Virement', bank_account_id:@ba.id, book_id:@ib.id, nature_id:@n.id)

      @bel1 = CheckDepositBankExtractLine.new( bank_extract_id:@be2.id)
      @bel1.check_deposit = @cd
      @bel1.save!
      @bel2 = StandardBankExtractLine.create!(bank_extract_id:@be2.id, lines:[@l2])


    end

    it "should have two bank_extract_lines" do
      @be2.bank_extract_lines.count.should == 2
    end

    it 'each with the right class' do
      @be2.bank_extract_lines.last.should be_a BankExtractLine
      @be2.bank_extract_lines.first.should be_a CheckDepositBankExtractLine
    end

    it 'total lines debit' do
      @be2.total_lines_debit.should == 13
    end


     it 'total lines credit' do
      @be2.total_lines_credit.should == 97
    end

    it 'lines should be unique'

  
  end



end

