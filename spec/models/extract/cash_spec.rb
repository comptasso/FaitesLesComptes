# coding: utf-8

require 'spec_helper'

describe Extract::Cash do

  before(:each) do
    @ec = Extract::Cash.new(@b = mock_model(Book), @p = mock_model(Period, :start_date=>Date.today.beginning_of_month, :close_date=>Date.today.end_of_month))
  end

  it 'est une instance' do
    @ec.should be_an_instance_of(Extract::Cash)
    @ec.begin_date.should == Date.today.beginning_of_month
  end

  it 'to_pdf appelle Editions::Cash' do
    Editions::Cash.should_receive(:new).with(@p, @ec)
    @ec.to_pdf
  end

  it 'lines appelles les compta_lines avec les arguments de dates' do
    @b.should_receive(:compta_lines).and_return(@ar = double(Arel))
    @ar.should_receive(:extract).with(Date.today.beginning_of_month, Date.today.end_of_month)
    @ec.lines
  end

  it 'to_csv prépare les lignes' do
    @ec.stub(:lines).and_return([double(ComptaLine, line_date:Date.today,
        narration:'un libellé', ref:'001', :credit=>0,
        destination:stub(:name=>'la destinée'),
        nature:stub(:name=>'ecolo'),
        :debit=>'125.56')])

    @ec.to_csv.should == "Date\tRéf\tLibellé\tDestination\tNature\tSorties\tEntrées\n#{I18n.l(Date.today, :format=>'%d/%m/%Y')}\t001\tun libellé\tla destinée\tecolo\t0,00\t125.56\n"
  end



end
