# coding: utf-8

require 'spec_helper'
require 'lines_helper'

describe "check_deposits/index.html.erb" do
  let(:o) {mock_model(Organism, title: 'spec cd')}
  let(:ba)  {mock_model(BankAccount, number: '124578AZ')}
  let(:cd1) {mock_model(CheckDeposit, bank_account_id: ba.id, deposit_date: Date.today - 5)}
  let(:cd2) {mock_model(CheckDeposit, bank_account_id: ba.id, deposit_date: Date.today - 20)}

  10.times do |t|
    s=('l'+t.to_s).to_sym
    let(s) {mock_model(Line, :amount=>(t+1))}
  end

 

  before(:each) do
    [cd1, cd2].each do |cd|
      cd.stub(:bank_account).and_return(ba)
      
    end

    cd1.stub(:bank_extract_line).and_return(1) # la remise de chèque n° 1 est pointée
    cd2.stub(:bank_extract_line).and_return(nil)

    cd1.stub_chain(:checks, :total).and_return(10)
    cd2.stub_chain(:checks, :total).and_return(35)


    assign(:check_deposits, [cd1,cd2])
    assign(:organism, o)
    assign(:bank_account, ba)


  end

  describe "controle du menu" do
      it 'le menu doit apparaître'
  end

  describe "controle du corps" do

    before(:each) do
        render
      end

    it "affiche la légende du fieldset" do
      
      assert_select "legend", :text => "Liste des remises de chèques"
    end
    
    it "affiche la table desw remises de chèques" do
   
      assert_select "table tbody", count: 1
    end
    
    it "affiche les lignes (ici deux)" do
    
      assert_select "tbody tr", count: 2
    end

    
    context "chaque ligne affiche ..." do

      it "le numéro de compte" do
        assert_select('tr:nth-child(2) td', :text=>cd2.bank_account.number)
      end
      it "la date" do

        assert_select('tr:nth-child(2) td:nth-child(2)', :text=>I18n::l(cd2.deposit_date))
      end
      
      it "le montant (formatté avec une virgule et deux décimales)" do
        assert_select('tr:nth-child(2) td:nth-child(3)', :text=>'35,00')
      end

      it "les liens pour l'affichage" do
        assert_select("tr:nth-child(2) td:nth-child(4) img[src='/assets/icones/afficher.png']")
        assert_select('tr:nth-child(2) td:nth-child(4) a[href=?]',bank_account_check_deposit_path(ba, cd2))
      end

      

      it "le lien pour la modification" do
        assert_select('tr:nth-child(2) td:nth-child(5) img[src=?]','/assets/icones/modifier.png')
        assert_select('tr:nth-child(2) td:nth-child(5) a[href=?]',edit_bank_account_check_deposit_path(ba, cd2))
      end

      it "le lien pour la suppression" do
        assert_select('tr:nth-child(2) > td:nth-child(6)  img[src=?]','/assets/icones/supprimer.png')
        assert_select('tr:nth-child(2) > td:nth-child(6) a[href=?]', bank_account_check_deposit_path(ba, cd2))
      end

    
    end

    context "quand la remise de chèque est pointée, ie elle est reliée à une bank_extract_line" do

      it "le lien affichage est toujours disponible" do
       assert_select('tr:nth-child(1) td:nth-child(4) img[src= ?]' , '/assets/icones/afficher.png')
       assert_select('tr:nth-child(1) td:nth-child(4) a[href=?]', bank_account_check_deposit_path(ba, cd1))
      end

      it "mais pas le lien modification" do
        assert_select('tr:nth-child(1) td:nth-child(5) a[href=?]',edit_bank_account_check_deposit_path(ba, cd1), false)
      end

      it 'ni le lien suppression' do
        assert_select('tr:nth-child(1) > td:nth-child(6) a[href=?]', bank_account_check_deposit_path(ba, cd1), false)
      end
    end



  end
end
