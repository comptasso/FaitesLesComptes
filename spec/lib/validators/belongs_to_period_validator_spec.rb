# coding: utf-8

require 'spec_helper'

describe 'BelongsToPeriodValidator' do
  let(:o) {stub_model(Organism)}
  let(:p) {stub_model(Period, :organism_id=>o.id, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year)}
  let(:n) {stub_model(Nature, :period=>p)}
  let(:w) {stub_model(Writing,date:Date.today, :narration=>'essai')}

  before(:each) do
    w.stub_chain(:book, :type).and_return('IncomeBook')
    @cl = w.compta_lines.new(nature:n, nature_id:n.id)
    @cl.stub(:writing).and_return w
    @cl.stub_chain(:writing, :book, :organism).and_return o
  end

  it 'o recçoit la demande de trouver l exercice' do
    o.should_receive(:find_period).with(Date.today).exactly(2).times.and_return p
    @cl.nature_id.should == n.id
    @cl.writing.date.should == Date.today
    @cl.valid?
  end

  it 'checks if a date belongs_to a period' do
    o.stub(:find_period).and_return p
    @cl.valid?
    puts @cl.errors.messages
    @cl.should  have(0).errors_on(:nature)
  end

  it 'add error on date_picker when date outside period' do
    w.date = Date.today.years_ago(1)
    o.stub(:find_period).and_return nil
    @cl.valid?
    puts @cl.errors.messages
    @cl.should  have(1).errors_on(:nature)
  end


end