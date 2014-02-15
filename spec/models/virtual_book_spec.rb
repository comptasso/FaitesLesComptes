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

 
  it 'lines appelles compta_lines de la caisse ou de la banque' do
    @c.should_receive(:compta_lines).and_return 'bonjour'
    @vb.lines.should == 'bonjour'
  end

  it 'cumulated_at est la négation de la méthode de la caisse ou de la banque' do
    @c.should_receive(:cumulated_at).with(Date.today, :debit).and_return 10
    @vb.cumulated_at(Date.today, :debit).should == -10
  end


end
