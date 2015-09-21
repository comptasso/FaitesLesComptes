# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'support/spec_controller_helper'

RSpec.configure do |c|
  # c.filter = {:wip => true }
  #  c.exclusion_filter = {:js=> true }
end




describe VirtualBookLinesController do
  include SpecControllerHelper

  let(:ba) {mock_model(BankAccount, :organism=>@o)}


  def create_virtual_book
    vb = VirtualBook.new
    vb.organism_id = @o.id
    vb.virtual = ba
    vb
  end

  def month_year_values(date)
    @m = '%02d' % date.month.to_s
    @y = '%04d' % date.year.to_s
    @p.stub(:guess_month).and_return(MonthYear.from_date(date))
    {mois:@m, an:@y}
  end

  before(:each) do
    minimal_instances
    @o.stub(:find_period).and_return @p
    month_year_values(Date.today)
    @vb = create_virtual_book
    @vb.stub(:organism).and_return @o
    ba.stub(:virtual_book).and_return @vb
    BankAccount.stub(:find).with(ba.to_param).and_return ba
  end

  describe "GET 'index'" do
    it "returns http success" do

      get :index, {:bank_account_id=>ba.to_param, :mois=>@m, :an=>@y}, valid_session
      response.should be_success
    end

    it 'doit chercher le bank_account' do
      BankAccount.should_receive(:find).with(ba.to_param).and_return ba
      get :index, {:bank_account_id=>ba.to_param, :mois=>@m, :an=>@y}, valid_session
    end

    it 'et l assigner' do
      get :index, {:bank_account_id=>ba.to_param, :mois=>@m, :an=>@y}, valid_session
      assigns(:bank_account).should == ba
    end

    it 'crée un virtual book' do
      ba.should_receive(:virtual_book).and_return @vb
      get :index, {:bank_account_id=>ba.to_param, :mois=>@m, :an=>@y}, valid_session
      assigns(:virtual_book).should == @vb
    end

    it 'crée un MonthlyExtract' do
      Extract::MonthlyBankAccount.should_receive(:new).with(@vb, :month=>@m, :year=>@y).and_return(@ex = double(Extract::MonthlyInOut))
      get :index, {:bank_account_id=>ba.to_param, :mois=>@m, :an=>@y}, valid_session
      assigns(:monthly_extract).should == @ex
    end

    context 'si params est tous' do

      it 'renvoie un ExtractInOut' do
      Extract::BankAccount.should_receive(:new).with(@vb, @p).and_return(@ex = double(Extract::InOut))
      get :index, {:bank_account_id=>ba.to_param, :mois=>'tous'}, valid_session
      assigns(:monthly_extract).should == @ex
      end


    end





  end



end
