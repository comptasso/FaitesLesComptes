# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Utilities::NotPointedLines do

  before(:each) do
    @ba = mock_model(BankAccount)
    @ba.stub(:np_check_deposits).and_return(
      [mock_model(CheckDeposit, id:1, total_checks:2, date:Date.today ),
        mock_model(CheckDeposit, id:2, total_checks:5, date: 1.day.ago)
      ])
    @ba.stub(:np_lines).and_return(
    [mock_model(Line, id:6, narration:'ligne 6', line_date:2.days.ago),
    mock_model(Line, id:7, narration:'ligne 7', line_date:3.days.ago)])
  end

  it 'npl should have 4 lines' do
    npl = Utilities::NotPointedLines.new(@ba)
    npl.list.should have(4).items
  end

  it 'list is ordered by date ASC' do
     npl = Utilities::NotPointedLines.new(@ba)
     npl.list.map {|l| l[:id] }.should == [7,6,2,1]
  end

  


end