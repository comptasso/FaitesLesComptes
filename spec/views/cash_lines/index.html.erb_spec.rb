# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 # c.filter = {wip:true}
end

describe "cash_lines/index" do 
  include JcCapybara

  let(:o) {mock_model(Organism, title: 'spec cd')} 
  let(:t) {mock_model(Transfer, :creditable_type=>'BankAccount', :creditable_id=>1,
      :debitable_type=>'BankAccount', :debitable_id=>1,
      :amount=>250.12, :narration=> 'Retrait')}
  let(:p) {mock_model(Period, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year)}
  let(:c) {mock_model(Cash, name: 'Magasin')}
  let(:n) {mock_model(Nature, :name=>'achat de marchandises')} 
  let(:mce) { mock( Utilities::MonthlyCashExtract, :total_credit=>100, :total_debit=>51,
    :debit_before=>20, :credit_before=>10)}
  let(:cl1) { mock_model(Line, :line_date=>Date.today, :narration=>'test', :debit=>'45', :nature_id=>n.id)}
  let(:cl2) {mock_model(Line, :line_date=>Date.today, :narration=>'autre ligne', :debit=>'54', :nature_id=>n.id)}


  before(:each) do
    assign(:organism, o) 
    assign(:period, p)
    assign(:cash, c)
    assign(:monthly_extract, mce)
    p.stub(:list_months).and_return ListMonths.new(p.start_date, p.close_date)
    mce.stub(:lines).and_return([cl1,cl2])
    [cl1, cl2].each {|l| l.stub(:nature).and_return(n) }
    [cl1, cl2].each {|l| l.stub(:destination).and_return(nil) }
    [cl1, cl2].each {|l| l.stub(:editable?).and_return(true) }
    [cl1, cl2].each {|l| l.stub(:book_id).and_return(1) }
    [cl1, cl2].each {|l| l.stub(:book).and_return(mock_model(Book)) } 
    [cl1, cl2].each {|l| l.stub(:owner_type).and_return(nil) }
    view.stub('current_page?').and_return false
  end

 
  describe "controle du corps" do  

    before(:each) do 
      render
    end

    it "affiche la légende du fieldset" do
      assert_select 'h3', /Caisse Magasin.*/
    end

    it "affiche la table desw remises de chèques" do
      assert_select "table tbody", count: 1
    end

    it "affiche les lignes (ici deux)" do
      assert_select "tbody tr", count: 2
    end

    it 'une cash_line non verrouillée peut être éditée et supprimée' , wip:true do
      assert_select 'img', count:4 # deux par lignes
      assert_select("tbody tr:first-child") do
        assert_select 'a:first-child img[src=?]', '/assets/icones/modifier.png'
        assert_select 'a:last-child img[src=?]', '/assets/icones/supprimer.png'
     
      end
   
    end
  end

  context 'avec des lines non editable' do
    before(:each) do
       [cl1, cl2].each {|l| l.stub(:editable?).and_return(false) }
        render
    end

    it 'une cash line locked n a pas de line pour suppression ou effacement' do
      page.all("tbody a").should have(0).elements
    end
  end

  context 'avec des lignes locked?' do
    it 'ne doit pas avoir de lien edition ou suppression'
  end

  context 'avec une lignes venant de transfer' do
    before(:each) do
       [cl1, cl2].each {|l| l.stub(:owner_type).and_return("Transfer") }
        [cl1, cl2].each {|l| l.stub(:owner_id).and_return(10) }
        render
    end

   it 'ne doit y avoir qu un seul lien (modifier)' do
     page.find("tbody tr:first td:nth-child(8)").all('img').size.should == 1
   end

    it 'peut avoir un lien modifier pointant vers transfer' do
      page.find("tbody tr:first td:nth-child(8)").all('img').first[:src].should == '/assets/icones/modifier.png'
      page.find("tbody tr:first a")[:href].should == "/organisms/#{o.id}/transfers/10/edit"
    end 
  end
  
end
