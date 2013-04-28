# coding: utf-8

require 'spec_helper'
require 'month_year'

describe Extract::Monthly do

  let(:b) {mock_model(Book)}
  let(:my) {MonthYear.from_date(Date.today)}

  it 'se crée avec un book et un monthyear' do
    me = Extract::Monthly.new(b, my)
    me.should be_an_instance_of(Extract::Monthly)
  end

  it 'month renvoie le mois au format %B %Y' do
    me = Extract::Monthly.new(b, my)
    me.month.should == I18n.l(Date.today, :format=> '%B %Y')
  end

  it 'lines demande les lignes du livre pour le mois donné' do
    b.should_receive(:compta_lines).and_return(@ar = double(Arel))
    @ar.should_receive(:mois).with(Date.today.beginning_of_month).and_return 'bonjour'
    me = Extract::Monthly.new(b, my)
    me.lines.should == 'bonjour'
  end

  it 'debit_before se repose sur Book#cumulated_debit_before' do
    d = Date.today.beginning_of_month
    b.should_receive(:cumulated_debit_before).with(d).and_return 28
    me = Extract::Monthly.new(b, my)
    me.debit_before.should == 28
  end

  it 'credit_before se repose sur Book#cumulated_credit_before' do
    d = Date.today.beginning_of_month
    b.should_receive(:cumulated_credit_before).with(d).and_return 1928
    me = Extract::Monthly.new(b, my)
    me.credit_before.should == 1928
  end

  it 'sold fait le total credit plus le credit before et retire les débits' do
    me = Extract::Monthly.new(b, my)
    me.stub(:debit_before).and_return 7
    me.stub(:total_debit).and_return 11
    me.stub(:credit_before).and_return 13
    me.stub(:total_credit).and_return 17
    me.sold.should == 12
  end


end

