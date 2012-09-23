# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/bank_accounts/index' do
  include JcCapybara
  
  before(:each) do
    assign(:organism, stub_model(Organism))
    @bank_accounts=[]
    @bank_accounts << stub_model(BankAccount, name: 'JC Bank', number: 'BA1', comment: 'un commentaire', address: '22, rue de Lille')
    @bank_accounts << stub_model(BankAccount, number: 'BA2')
    @bank_accounts.each do |b|
      b.stub(:created_at).and_return(Time.now)
      b.stub(:updated_at).and_return(Time.now)
      b.stub(:accounts).and_return [mock_model(Account, number:'5101')]
    end
  end

  context 'mise en page générale' do
    before(:each) do
      render 
    end 

    it "should have title h3" do
      page.find('h3').should have_content 'Liste des comptes bancaires'
    end

    it "should have one table" do
      page.should have_css('table', :count=>1)
    end

    it 'mise au point de la chaine de test' do
      page.find('table tbody').should have_css('tr', :count=>2)
    end

    it "each row should show 1 icon (edit)" do
      page.find('tbody tr').should have_css('img',:count=>1)
    end

    it "each row should show delete icon" do
      page.all('tbody tr img').first[:src].should match /\/assets\/icones\/modifier.png/
    end

    

    context 'title row' do
      it "shows Banque" do
        page.find('thead th:first').text.should == 'Banque'
        page.find(:css,'thead th:nth-child(2)').text.should == 'Numéro'
        page.find(:css,'thead th:nth-child(3)').text.should == 'Commentaire'
        page.find(:css,'thead th:nth-child(4)').text.should == 'Adresse'
        page.find(:css,'thead th:nth-child(5)').text.should == 'Compte de rattach.'
        page.find(:css,'thead th:nth-child(6)').text.should == 'Créé le'
        page.find(:css,'thead th:nth-child(7)').text.should == 'Modifié le'
        page.find(:css,'thead th:nth-child(8)').text.should == 'Actions'

      end
    end

    context 'check content of a row' do
      it "shows the relevant informations" do
        @ba=@bank_accounts.first
        page.find('tbody tr td:nth-child(1)').text.should == @ba.name
        page.find('tbody tr td:nth-child(2)').text.should == @ba.number
        page.find('tbody tr td:nth-child(3)').text.should == @ba.comment
        page.find('tbody tr td:nth-child(4)').text.should == @ba.address
        page.find('tbody tr td:nth-child(5)').text.should == '5101'
        page.find('tbody tr td:nth-child(6)').text.should == l(@ba.created_at)
        page.find('tbody tr td:nth-child(7)').text.should == l(@ba.updated_at)
      end
    end

  end
  # on ne peut le traiter comme les autres car le render ne doit pas arriver
  # avant le stub_chain
  context 'test de l affichage de l icone destroy' do
    it "with a line, row should not propose supprimer" do
      @bank_accounts.first.stub_chain(:bank_extracts, :empty?).and_return(false)
      render
      page.should_not have_css('tbody tr:first img[src="/assets/icones/supprimer.png"]')
    end
  end 
      
end

