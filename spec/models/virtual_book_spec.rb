# coding: utf-8

require 'spec_helper'

describe VirtualBook do

  before(:each) do
    @c = mock_model(Cash)
    @vb = VirtualBook.new
    @vb.virtual = @c

  end

  it 'connait virtual' do
    @vb.virtual.should == @c
  end

  it 'fournit les informations pour les données du pavé graphique' do
    @vb.pave_char.should ==  ['cash_pave', 'cash_book']
  end

  it 'lines appelles compta_lines de la caisse ou de la banque' do
    @c.should_receive(:compta_lines).and_return 'bonjour'
    @vb.lines.should == 'bonjour'
  end

  it 'cumulated_at est la négation de la méthode de la caisse ou de la banque' do
    @c.should_receive(:cumulated_at).with(Date.today, :debit).and_return 10
    @vb.cumulated_at(Date.today, :debit).should == -10
  end

  it 'monthly_values fait appel à sold_at en se placçant à la fin du mois' do
    @vb.should_receive(:sold_at).with(Date.today.end_of_month).and_return(56.25)
    @vb.monthly_value(Date.today).should == 56.25
  end

  it 'on peut appeler monthly_value avec un string comme \'04-2013\' ' do
    @vb.should_receive(:sold_at).with(Date.civil(2013,01,01).end_of_month).and_return(-56.25)
    @vb.monthly_value('01-2013').should == -56.25
  end


end
