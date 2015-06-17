# coding: utf-8

require 'spec_helper'

describe Extract::BankAccount do 

  before(:each) do
    @extract = Extract::BankAccount.new(@b = mock_model(Book), @p = mock_model(Period, :start_date=>Date.today.beginning_of_month, :close_date=>Date.today.end_of_month))
  end

  it 'est une instance' do
    @extract.should be_an_instance_of(Extract::BankAccount)
    @extract.from_date.should == Date.today.beginning_of_month 
  end

  it 'to_pdf appelle Editions::Cash' do
    Editions::BankAccount.should_receive(:new).with(@p, @extract) 
    @extract.to_pdf
  end

  it 'lines appelles les compta_lines avec les arguments de dates' do
    @b.should_receive(:extract_lines).with(Date.today.beginning_of_month, Date.today.end_of_month)
    @extract.lines
  end

  it 'to_csv prépare les lignes' do
    @extract.stub(:lines).and_return([double(ComptaLine, date:Date.today,
        ref:'001',
        narration:'un libellé', :credit=>0,
        :debit=>'125.56')])

    @extract.to_csv.should == "Date\tRéf\tLibellé\tDépenses\tRecettes\n#{I18n.l(Date.today, :format=>'%d/%m/%Y')}\t001\tun libellé\t0,00\t125.56\n"
  end



end

