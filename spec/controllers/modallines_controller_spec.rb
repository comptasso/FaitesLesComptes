require 'spec_helper'

describe ModallinesController do
  include SpecControllerHelper
  
  before(:each) do
    minimal_instances
    @p.stub(:guess_month).and_return(Date.today.month - 1)
  end

  describe "POST 'create" do
    it 'should ask for bank_extract, bank_account and organism' do
      BankExtract.should_receive(:find).with("1").and_return(@be = mock_model(BankExtract))
      @be.should_receive(:bank_account).and_return(@ba = mock_model(BankAccount))
      @ba.should_receive(:organism).and_return(mock_model(Organism))
      post 'create', {:bank_extract_id=>1, :line=>{}}, valid_session
    end
  end

  describe "POST 'create' return success" do

    def valid_arguments
    {:book_id=>1, :credit=>200 ,:narration=>'ligne de test',
        :line_date=>Date.civil(2012,01,02), :nature_id=>2, :payment_mode=> 'Virement'}
    end

    before(:each) do
      @ba = mock_model(BankAccount)
      @be = mock_model(BankExtract)
      
      BankExtract.stub(:find).with(@be.id.to_s).and_return @be
      @be.stub(:bank_account).and_return @ba
      @ba.stub(:organism).and_return @o
      Line.any_instance.stub(:book).and_return(@ib = mock_model(IncomeBook))
      @ib.stub(:organism).and_return(@o)
      @o.stub(:find_period).and_return(mock_model(Period))

    end

    it 'test line save' do
      l = Line.new(valid_arguments)
      l.bank_account_id = @ba.id
      l.should be_valid
      expect {l.save}.to change {Line.count}
    end

    it "returns http success with valid arguments" do
      Utilities::NotPointedLines.stub(:new).and_return []
      post 'create', {:format=>:js, :bank_extract_id=>@be.id, :line=>valid_arguments}, valid_session
      response.should be_success
    end

    it 'should render template create' do
      Utilities::NotPointedLines.stub(:new).and_return []
      post 'create',{ :format=>:js, :bank_extract_id=>@be.id, :line=>valid_arguments}, valid_session
      response.should render_template 'modallines/create'
    end
    
    it "return also http success with invalid arguments", :js=>true do
      Utilities::NotPointedLines.stub(:new).and_return []
      post 'create', {:format=>:js, :bank_extract_id=>@be.id, :line=>{}}, valid_session
      response.should be_success
    end

    it 'should render template new when invalid arguments' do
      Utilities::NotPointedLines.stub(:new).and_return []
      post 'create',{ :format=>:js, :bank_extract_id=>@be.id, :line=>{}}, valid_session
      response.should render_template 'modallines/new'
    end



  end

end
