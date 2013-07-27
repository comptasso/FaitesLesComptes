# coding: utf-8

require 'spec_helper'

 
describe "check_deposits/new" do
  include JcCapybara

  let(:ba)  {mock_model(BankAccount, number: '124578AZ', name: 'IBAN', nickname:'Compte courant')}
  let(:o) {mock_model(Organism, bank_accounts:[ba])}
  let(:p) {mock_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)}
  let(:cks) {(1..3).collect {|i| mock_model(ComptaLine, label:"un chèque n° #{i}")} }
  
  let(:cd1) {mock_model(CheckDeposit, 
      bank_account_id: ba.id,
      deposit_date_picker: Date.today - 5,
      pointed?:false,
      check_ids:[1,2,3],
      checks:cks
    )}
   

  before(:each) do

    CheckDeposit.stub(:pending_checks).and_return([mock_model(ComptaLine, label:"un chèque non remis")])
    
    assign(:check_deposit, cd1)
    assign(:organism, o)
    assign(:period, p)
    assign(:bank_account, ba)
    assign(:nb_to_pick, 2)

  end

  
  describe "controle du corps" do

    before(:each) do
      render
    end

    it "affiche la légende du fieldset" do
      assert_select "h3", :text => "Nouvelle remise de chèque sur #{ba.nickname}"
    end
    
    it "affiche le formulaire de remise de chèques" do
      assert_select "form", count: 1
    end
    
    

  end
end
