# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

 
describe 'compta/listings/show' do 
  include JcCapybara

  let(:as) {double(Arel,
      order:(1.upto(10).collect {|i| mock_model(Account,
            number:"#{i}", title:"Compte test #{i}",
          long_name:"#{i} - Compte test #{i}")}) )}
  let(:a) {mock_model(Account, long_name:'605 compte de test')}
  let(:p) {mock_model(Period, start_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year)}
  let(:l) {Compta::Listing.new( account_id:a.id,
      from_date:Date.today.beginning_of_year, to_date:Date.today.end_of_year)}
  let(:line) {double(ComptaLine, w_piece_number:1, w_date:Date.today,
      b_abbreviation:'OD',
      w_ref:'',
      w_narration:'ligne test',
      debit:0, credit:5,
      nat_name:'Non affecté', dest_name:'dest test')}
  

  before(:each) do
    
    l.stub(:account).and_return a 
    l.stub(:lines).and_return( 50.times.collect {line})
    a.stub(:period).and_return p

    p.stub(:accounts).and_return as 
   
    assign(:cumulated_debit_before, 100)
    assign(:cumulated_credit_before,0)
    assign(:sold_before,100)
    assign(:total_debit, 105)
    assign(:total_credit, 0)
    assign(:cumulated_debit_at, 105)
    assign(:cumulated_credit_at, 0)
    assign(:sold_at, 105)
    assign(:listing, l)
    assign(:period, p)
    assign(:account, a)
  end
 
  it 'should render' do
    render 
  end

  context 'render' do
    before(:each) do
      render
    end

    it 'doit mettre en titre le numéro et le nom du compte' do
      page.find('.champ > h3').should have_content('Ecritures du compte')
      page.find('.champ > h3').should have_content('605 compte de test')
    end

    it 'avec les dates demandées' do
      page.find('.champ > h3').should have_content(
        "Du 1er janvier #{Date.today.year} au 31 décembre #{Date.today.year}")
    end
  end
end
