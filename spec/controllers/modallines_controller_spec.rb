require 'spec_helper'

RSpec.configure do |c|
 # c.filter = {wip:true}
end
 
describe ModallinesController do 
  include SpecControllerHelper 

 
  def valid_arguments
    {:book_id=>1, date:Date.today, :narration=>'ligne de test',
      compta_lines_attributes:{'0' =>{account_id:1, nature_id:2, debit:50},
        '1'=>{account_id:2, payment_mode:'Virement'}}}
  end



  def invalid_arguments
    {:book_id=>1, :narration=>'ligne de test',
      compta_lines_attributes:{'0' =>{account_id:1, nature_id:2, debit:50},
        '1'=>{account_id:2, payment_mode:'Virement'}}}
  end
  
  before(:each) do 
    minimal_instances
    InOutWriting.any_instance.stub_chain(:book, :type).and_return('IncomeBook')
    InOutWriting.any_instance.stub_chain(:book, :organism).and_return(@o)
    InOutWriting.any_instance.stub(:counter_line).and_return(mock_model(ComptaLine, payment_mode:'Virement'))
    @o.stub(:find_period).and_return @p
    @o.stub(:next_piece_number).and_return 1975
    @p.stub(:guess_month).and_return(Date.today.month - 1) 
  end

  describe "POST 'create" do
    it 'should ask for bank_extract, bank_account and current_account' do
      Utilities::NotPointedLines.stub(:new).and_return []
      BankExtract.should_receive(:find).with("1").and_return(@be = mock_model(BankExtract))
      @be.should_receive(:bank_account).and_return(@ba = mock_model(BankAccount))
      @ba.should_receive(:current_account).with(@p).and_return(mock_model(Account))
      post 'create', { :format=>:js, :bank_extract_id=>1, :in_out_writing=>valid_arguments}, valid_session
    end
  end

  describe "POST 'create' return success" do

    before(:each) do
      @ba = mock_model(BankAccount)
      @be = mock_model(BankExtract, :bank_account=>@ba)
      @acc2 = mock_model(Account)
      @ib = mock_model(IncomeBook, :organism=>@o)
      BankExtract.stub(:find).with(@be.to_param).and_return @be
      @ba.stub(:current_account).with(@p).and_return(@acc2)
      InOutWriting.any_instance.stub(:book).and_return(@ib)
      Utilities::NotPointedLines.stub(:new).and_return []
    end

    
    it "returns http success with valid arguments" , wip:true do
      
      post 'create', {:format=>:js, :bank_extract_id=>@be.id, :in_out_writing=>valid_arguments}, valid_session
      response.should be_success
    end

    it 'should render template create' do
     
      InOutWriting.any_instance.stub(:save).and_return true
      post 'create',{ :format=>:js, :bank_extract_id=>@be.id, :in_out_writing=>valid_arguments}, valid_session
      response.should render_template 'modallines/create' 
    end

    describe 'invalid arguments' do

    before(:each) do
      InOutWriting.any_instance.stub(:save).and_return false
    end

    it "return also http success with invalid arguments" do
      post 'create', {:format=>:js, :bank_extract_id=>@be.id, :in_out_writing=>invalid_arguments}, valid_session
      response.should be_success
    end

    it 'should render template new when invalid arguments' do
      post 'create',{ :format=>:js, :bank_extract_id=>@be.id, :in_out_writing=>invalid_arguments}, valid_session
      response.should render_template 'modallines/new'
    end

    end

  end

end
