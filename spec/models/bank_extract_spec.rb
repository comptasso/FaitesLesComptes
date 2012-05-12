# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
    c.filter = {:wip=> true }
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
      @be2.begin_date_picker=I18n.l Date.today
      @be2.begin_date.should == Date.today
    end

    it 'raise error when date is malformatted' do
      expect { @be2.begin_date_picker = '31/06/2012' }.to raise_error(ArgumentError, 'string cant be transformed to a date')
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

    it 'end_sold doit être présent' do
      be = @ba.bank_extracts.new(begin_sold:nil)
      be.should have(2).errors_on(:begin_sold) # numericality and presence
    end

    it 'begin_sold doît être un nombre' do
      be = @ba.bank_extracts.new(begin_sold:'bonjour')
      be.should have(1).errors_on(:begin_sold) # numericality
    end
  end

  describe 'contrôle des bank_extract_lines', :wip=>true do

    before(:each) do
      @l1 = Line.new(narration:'bel', line_date:Date.today, debit:0, credit:97, payment_mode:'Chèque', book_id:@ib.id, nature_id:@n.id)
      @l1.valid?
      @l1.should be_valid
      @l1.save!
      

      @cd = CheckDeposit.create!(bank_account_id:@ba.id, deposit_date:(Date.today + 1.day))
      @cd.checks << @l1
      @cd.save!

      @l2 = Line.create!(narration:'bel', line_date:Date.today, debit:13, credit:0, payment_mode:'Virement', bank_account_id:@ba.id, book_id:@ib.id, nature_id:@n.id)

      @bel1 = CheckDepositBankExtractLine.create!( bank_extract_id:@be2.id, check_deposit_id:@cd.id )
      @bel2 = BankExtractLine.create!(bank_extract_id:@be2.id, lines:[@l2])


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

  end



end

