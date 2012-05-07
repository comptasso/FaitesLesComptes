# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BankExtract do
  before(:each) do
    @o=Organism.create!(title: 'My Little Firm')
    @p_2011=@o.periods.create!(start_date: Date.civil(2011,01,01), close_date:Date.civil(2011,12,31))
    @p_2012=@o.periods.create!(start_date: Date.civil(2012,01,01), close_date:Date.civil(2012,12,31))
    @ba=@o.bank_accounts.create!(name: 'La Banque', number: '123456Z', organism_id: @o.id)

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
  it "le scpê de period renvoie @be1 pour 2011 et @be2 pour 2012" do
    @ba.bank_extracts.period(@p_2011).should == [@be1]
    @ba.bank_extracts.period(@p_2012).should == [@be2] 
  end

    it "lorsqu'il y a un extrait à cheval, il est intégré dans les deux requêtes" do
       @be12= @ba.bank_extracts.create!(bank_account_id: @ba.id, begin_date: Date.civil(2011,12,15), end_date: Date.civil(2012,1,15), begin_sold: 2011, total_credit: 2012, total_debit: 10)
 @ba.bank_extracts.period(@p_2011).should == [@be1, @be12]
    @ba.bank_extracts.period(@p_2012).should == [@be12,@be2]
    end

    it 'les limites de dates sont avec des <= et non des <' do
       @be12= @ba.bank_extracts.create!(bank_account_id: @ba.id, begin_date: Date.civil(2011,12,15), end_date: Date.civil(2011,12,31), begin_sold: 2011, total_credit: 2012, total_debit: 10)
     @be21= @ba.bank_extracts.create!(bank_account_id: @ba.id, begin_date: Date.civil(2012,01,01), end_date: Date.civil(2012,1,31), begin_sold: 2011, total_credit: 2012, total_debit: 10)
@ba.bank_extracts.period(@p_2011).should == [@be1, @be12]
    @ba.bank_extracts.period(@p_2012).should == [@be21,@be2]
    end

  end
end

