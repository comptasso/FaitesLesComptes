# coding: utf-8



require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'
require File.expand_path(File.dirname(__FILE__) + '/../../support/similar_model.rb')




describe Restore::RecordsRestorer do

  before(:each) do
    @compta = double(Restore::ComptaRestorer)

  end

  it 'create a habtml' do
    Restore::HabtmRestorer.new(@compta, :bank_extract_line, :line)
  end

  it 'check validate false' do
    @bel = StandardBankExtractLine.new(bank_extract_id:1)
    expect {@bel.save!(validate:false)}.to change {BankExtractLine.count}
  end
  
  describe 'restore_records'



  
  before(:each) do
     @hr = Restore::HabtmRestorer.new(@compta, :bank_extract_line, :line)
     @ds = [ {:bank_extract_line => 1, :line => 1 }]
     @bel = StandardBankExtractLine.new(bank_extract_id:1)
     @bel.save!(validate:false)
     @l = mock_model(Line, bank_extract_lines:[])
     BankExtractLine.stub(:find).and_return @bel
     
     Line.stub(:find).and_return @l
  end
  
  it 'can rebuild datas' do
    @compta.should_receive(:ask_id_for).with('bank_extract_line',1).and_return 9
    @compta.should_receive(:ask_id_for).with('line',1).and_return 20
    @bel.should_receive(:save!).and_return(true)
    @hr.restore_records(@ds)
  end

  it 'rebuild datas' do
    @compta.should_receive(:ask_id_for).with('bank_extract_line',1).and_return 9
    @compta.should_receive(:ask_id_for).with('line',1).and_return 20
    @hr.restore_records(@ds)
    @bel.lines.should have(1).lines
  end

  


end
