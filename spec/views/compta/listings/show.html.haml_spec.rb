# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')


describe 'compta/listings/show' do
  include JcCapybara

  let(:ar) {double(Arel)}
  let(:a) {mock_model(Account, long_name:'605 compte de test', lines:ar)}
  let(:p) {mock_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)}
  let(:l) {Compta::Listing.new( account_id:a.id,
            from_date_picker:'01/01/2012',
             to_date_picker:'31/12/2012')}

  before(:each) do
    l.stub(:account).and_return a
    assign(:listing, l)
    assign(:period, p)
  end
 
  it 'should render' do
    render 
  end
end
