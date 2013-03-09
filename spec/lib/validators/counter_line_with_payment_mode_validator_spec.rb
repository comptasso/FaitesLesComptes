# coding: utf-8

require 'spec_helper'

describe 'CounterLineWithPaymentModeValidator' do
  let(:b) {stub_model(IncomeBook)}

  def valid_attributes
    {"date_picker"=>"01/03/2013", "ref"=>"",
            "narration"=>"essa",
            "compta_lines_attributes"=>{'0'=>{"nature_id"=>"", "destination_id"=>"", "credit"=>"0", "debit"=>"0", "payment_mode"=>"Virement" },
              '1'=>{"account_id"=>"144", "check_number"=>"", "credit"=>"0", "debit"=>"0", "payment_mode"=>"" }}}
  end
  

  before(:each) do

    
    @w = b.in_out_writings.build(valid_attributes)

    @w.stub(:book).and_return b
  end

  it 'o recçoit la demande de trouver l exercice' do
    @w.should be_valid
    
  end

  


end