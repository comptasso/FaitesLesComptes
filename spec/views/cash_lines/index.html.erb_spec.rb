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
   
   
  end

 
  describe "controle du corps" do

    before(:each) do 
      render 
    end

    it "affiche la légende du fieldset" do
      assert_select "h3", :text => "Caisse Magasin"
    end

    it "affiche la table desw remises de chèques" do
      assert_select "table tbody", count: 1
    end

    it "affiche les lignes (ici deux)" do
      assert_select "tbody tr", count: 2
    end

    it 'une cash line locked ne peut être éditée' do
      page.find("tbody tr:first td:nth-child(7)").all('img').last[:src].should == '/assets/icones/supprimer.png'

#      first_row=page.find('tbody tr:first')
#    first_row.all('img').should have(2).icons
#    first_row.all('img').first[:src].should == '/assets/icones/modifier.png'
#    first_row.all('img').last[:src].should == '/assets/icones/supprimer.png' 
    end

    it 'une cash_line locked ne peut être détruite'
    it 'une cash_line venant de transfer doit être éditée via transfer'


    #    context "chaque ligne affiche ..." do
    #
    #      it "le numéro de compte" do
    #        assert_select('tr:nth-child(2) td', :text=>cd2.bank_account.number)
    #      end
    #      it "la date" do
    #       assert_select('tr:nth-child(2) td:nth-child(2)', :text=>I18n::l(cd2.deposit_date))
    #      end
    #
    #      it "le montant (formatté avec une virgule et deux décimales)" do
    #        assert_select('tr:nth-child(2) td:nth-child(4)', :text=>'35,00')
    #      end
    #
    #      it "les liens pour l'affichage" do
    #        assert_select("tr:nth-child(2) td:nth-child(5) img[src='/assets/icones/afficher.png']")
    #        assert_select('tr:nth-child(2) td:nth-child(5) a[href=?]',organism_bank_account_check_deposit_path(o,ba, cd2))
    #      end
    #
    #
    #
    #      it "le lien pour la modification" do
    #        pending
    #        assert_select('tr:nth-child(2) td:nth-child(6) img[src=?]','/assets/icones/modifier.png')
    #        assert_select('tr:nth-child(2) td:nth-child(6) a[href=?]',edit_organism_bank_account_check_deposit_path(o,ba, cd2))
    #      end
    #
    #      it "le lien pour la suppression" do
    #        pending
    #        assert_select('tr:nth-child(2) > td:nth-child(7)  img[src=?]','/assets/icones/supprimer.png')
    #        assert_select('tr:nth-child(2) > td:nth-child(7) a[href=?]', organism_bank_account_check_deposit_path(o,ba, cd2))
    #      end
    #
    #
    #    end

    #    context "quand la remise de chèque est pointée, ie elle est reliée à une bank_extract_line" do
    #
    #      it "le lien affichage est toujours disponible" do
    #        assert_select('tr:nth-child(1) td:nth-child(5) img[src= ?]' , '/assets/icones/afficher.png')
    #        assert_select('tr:nth-child(1) td:nth-child(5) a[href=?]', organism_bank_account_check_deposit_path(o,ba, cd1))
    #      end
    #
    #      it "mais pas le lien modification" do
    #        assert_select('tr:nth-child(1) td:nth-child(6) a[href=?]',edit_organism_bank_account_check_deposit_path(o,ba, cd1), false)
    #      end
    #
    #      it 'ni le lien suppression' do
    #        assert_select('tr:nth-child(1) > td:nth-child(7) a[href=?]', organism_bank_account_check_deposit_path(o,ba, cd1), false)
    #      end
    #    end



  end
end
