#coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 #  c.filter = {wip:true}
end

describe "transfers/edit" do  
    include JcCapybara

  let(:acc1) {mock_model(Account, number:'5101', accountable:mock_model(BankAccount, nickname:'La Banque'))}
  let(:acc2) {mock_model(Account, number:'5301', accountable:mock_model(Cash, nickname:'La Caisse'))}

  before(:each) do
    @o = assign(:organism, stub_model(Organism)) 
    @bas= assign(:bank_accounts,
    [stub_model(BankAccount, name: 'DebiX', number: '1234Z'),
    stub_model(BankAccount, name: 'DebiX', number: '5678Z') ])
    @cas = assign(:cashes,
     [stub_model(Cash, name: 'Magasin'),
    stub_model(BankAccount, name: 'Entrepôt') ])
    @p= assign(:period, stub_model(Period, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year))


    @o.stub_chain(:bank_accounts, :all).and_return @bas
    @o.stub_chain(:cashes, :all).and_return @cas

    @transfer = assign(:transfer, stub_model(Transfer, :pick_date=>'12/04/2012', :amount=>50.23, narration: 'virement'))
#    @transfer.stub(:compta_lines).and_return([mock_model(ComptaLine, locked?:false, account:acc1),
#              mock_model(ComptaLine, locked?:false, account:acc2)] )

   
  end

  it "renders the edit transfer form" do
    render
    page.all('form').should have(1).element
    assert_select "form", :action => transfers_path, :method => "post"
  end

  describe 'a transfer partially locked has fields disabled' do

   
  it "debit is locked" do
    @transfer.should_receive(:partial_locked?).and_return(true, true, true) 
    render
    
    page.find('input#transfer_date_picker')[:disabled].should == 'disabled'
    page.find('input#transfer_narration')[:disabled].should == 'disabled'
    page.find('input#transfer_amount')[:disabled].should == 'disabled'
  end

    it "avec deux zones select"  do
      render
      page.all('select').should have(2).elements
      
    end


  it 'le select debit est disable if line_debit locked' do
     @transfer.stub(:compta_lines).and_return([mock_model(ComptaLine, 'locked?'=>false), mock_model(ComptaLine, 'locked?'=>true)])
     render
     page.find('select#transfer_compta_lines_attributes_1_account_id')[:disabled].should == 'disabled'
     page.find('select#transfer_compta_lines_attributes_0_account_id')[:disabled].should be_nil
  end

    it 'le select credit is disable if line_credit locked' do
    @transfer.stub(:compta_lines).and_return([mock_model(ComptaLine, 'locked?'=>true), mock_model(ComptaLine, 'locked?'=>false)])
     render
     page.find('select#transfer_compta_lines_attributes_0_account_id')[:disabled].should == 'disabled'
     page.find('select#transfer_compta_lines_attributes_1_account_id')[:disabled].should be_nil
  end

  end
  
end
