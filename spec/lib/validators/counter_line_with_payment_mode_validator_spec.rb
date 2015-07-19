# coding: utf-8

require 'spec_helper'

describe 'CounterLineWithPaymentModeValidator' do 
  let(:b) {stub_model(IncomeBook)}
  let(:cl) {stub_model(ComptaLine)}

  def valid_attributes
    {"date_picker"=>"01/03/2013", "piece_number"=>"1974", "ref"=>"",
            "narration"=>"essa",
            "compta_lines_attributes"=>{'0'=>{"nature_id"=>"",
                "destination_id"=>"", "credit"=>"0", "debit"=>"0",
                "payment_mode"=>"Virement" },
              '1'=>{"account_id"=>"144", "check_number"=>"",
                "credit"=>"0", "debit"=>"0", "payment_mode"=>"" }}}
  end
  

  before(:each) do

    @w = b.in_out_writings.build(valid_attributes)

    @w.stub(:book).and_return b
    @w.stub(:counter_line).and_return(cl)
  end

  it 'le validator interroge le champ payment mode de la counter line' do
    cl.should_receive(:payment_mode).at_least(1).times.and_return('Espèces')
    @w.valid?
  end

  it 'non valide si pas de champ payment_mode' do 
    cl.stub(:payment_mode).and_return(nil)
    @w.should_not be_valid
    @w.errors.messages[:counter_line].should == ['erreur sur la counter_line']
    cl.errors.messages[:payment_mode].should == ['obligatoire']
  end

  it 'non valide si pas dans la liste des constantes autorisées' do
    cl.stub(:payment_mode).and_return('bizarre')
    @w.should_not be_valid
    @w.errors.messages[:counter_line].should == ['erreur sur la counter_line']
    cl.errors.messages[:payment_mode].should == ['valeur non acceptée']
  end



  


end