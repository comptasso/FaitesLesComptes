# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Utilities::NotPointedLines do

  before(:each) do
    @ba = mock_model(BankAccount)
    @ba.stub(:np_check_deposits).and_return(
      [mock_model(CheckDeposit, id:1, total_checks:2, date:Date.today ),
        mock_model(CheckDeposit, id:2, total_checks:5, date: 1.day.ago)
      ])
    @ba.stub_chain(:compta_lines, :not_pointed).and_return(
    [mock_model(ComptaLine, id:6, narration:'ligne 6', line_date:2.days.ago),
    mock_model(ComptaLine, id:7, narration:'ligne 7', line_date:3.days.ago)])

    
  end

  it 'demande à bank_account de remplir les lignes à pointer' do
    @ba.should_receive(:compta_lines).and_return(@ar = double(Arel))
    @ar.should_receive(:not_pointed)
    Utilities::NotPointedLines.new(@ba)
  end

  it 'doit connaître sa taille' do
    npls = Utilities::NotPointedLines.new(@ba)
    npls.size.should == 2
  end

  it 'total_credit renvoie le total de ses lignes ' do
    @ar = double(Arel)
    @npls = Utilities::NotPointedLines.new(@ba)
    @npls.stub(:lines).and_return([mock_model(ComptaLine, :credit=>5), mock_model(ComptaLine, :credit=>8)])
    @npls.total_credit.should == 13
  end

  it 'total_debit renvoie le total de ses lignes ' do
    @ar = double(Arel)
    @npls = Utilities::NotPointedLines.new(@ba)
    @npls.stub(:lines).and_return([mock_model(ComptaLine, :debit=>3), mock_model(ComptaLine, :debit=>3)])
    @npls.total_debit.should == 6
  end

  it 'et peut aussi calculer le solde' do
    @npls = Utilities::NotPointedLines.new(@ba)
    @npls.stub(:total_credit).and_return 12
    @npls.stub(:total_debit).and_return 5
    @npls.sold.should == 7
  end

 

  


end