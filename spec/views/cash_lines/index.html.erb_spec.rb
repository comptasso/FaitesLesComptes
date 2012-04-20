# coding: utf-8

require 'spec_helper'

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
    p.stub(:list_months).and_return %w(jan fév mar avr mai jui jui aou sept oct nov déc)
    mce.stub(:lines).and_return([cl1,cl2])
    [cl1, cl2].each {|l| l.stub(:nature).and_return(n) }
    [cl1, cl2].each {|l| l.stub(:destination).and_return(nil) }
    [cl1, cl2].each {|l| l.stub(:locked?).and_return(false) }
    [cl1, cl2].each {|l| l.stub(:book_id).and_return(1) }
    [cl1, cl2].each {|l| l.stub(:book).and_return(mock_model(Book)) }
    [cl1, cl2].each {|l| l.stub(:owner_type).and_return(nil) } 
  end

 
  describe "controle du corps" do  

    before(:each) do 
      render 
    end

    it "affiche la légende du fieldset" do
      page.find('h3').should have_content "Caisse Magasin"
    end

    it "affiche la table desw remises de chèques" do
      assert_select "table tbody", count: 1
    end

    it "affiche les lignes (ici deux)" do
      assert_select "tbody tr", count: 2
    end

    it 'une cash_line non verrouillée peut être éditée et supprimée' do
      page.find("tbody tr:first td:nth-child(7)").all('img').first[:src].should == '/assets/icones/modifier.png'
      page.find("tbody tr:first td:nth-child(7)").all('img').last[:src].should == '/assets/icones/supprimer.png'
    end
  end

  context 'avec des lines locked' do
    before(:each) do
       [cl1, cl2].each {|l| l.stub(:locked?).and_return(true) }
        render
    end

    it 'une cash line locked n a pas de line pour suppression ou effacement' do
      page.should_not have_selector("tbody tr:first td:nth-child(7) a")
    end
  end

  context 'avec une lignes venant de transfer' do
    before(:each) do
       [cl1, cl2].each {|l| l.stub(:owner_type).and_return("Transfer") }
        [cl1, cl2].each {|l| l.stub(:owner_id).and_return(10) }
        render
    end

   it 'ne doit y avoir qu un seul lien (modifier)' do
     page.find("tbody tr:first td:nth-child(7)").all('img').size.should == 1
   end

    it 'peut avoir un lien modifier pointant vers transfer' do
      page.find("tbody tr:first td:nth-child(7)").all('img').first[:src].should == '/assets/icones/modifier.png'
      page.find("tbody tr:first a")[:href].should == '/transfers/10/edit' 
    end 
  end
  
end
