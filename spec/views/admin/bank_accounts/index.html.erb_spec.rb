# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/bank_accounts/index' do 
  include JcCapybara
  
  before(:each) do
    assign(:organism, stub_model(Organism))
    @bank_accounts=[]
    @bank_accounts << stub_model(BankAccount, bank_name: 'JC Bank', number: 'BA1', nickname:'Compte courant', comment: 'un commentaire')
    @bank_accounts << stub_model(BankAccount, number: 'BA2')
    @bank_accounts.each do |b|
      b.stub(:created_at).and_return(Time.now)
      b.stub(:updated_at).and_return(Time.now)
      b.stub(:accounts).and_return [mock_model(Account, number:'5101')] 
      b.stub(:sector).and_return(mock_model(Sector, name:'Général'))
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
      page.find('tbody tr:first').should have_css('img',:count=>1)
    end

    it "each row should show delete icon" do
      page.all('tbody tr:first img').first[:src].should match /\/assets\/icones\/modifier.png/
    end

    

    context 'title row' do
      it "shows Banque" do
        page.find('thead th:first').text.should == 'Banque'
        page.find(:css,'thead th:nth-child(2)').text.should == 'Numéro'
        page.find(:css,'thead th:nth-child(3)').text.should == 'Surnom'
        page.find(:css,'thead th:nth-child(4)').text.should == 'Secteur'
        page.find(:css,'thead th:nth-child(5)').text.should == 'Commentaire'
        page.find(:css,'thead th:nth-child(6)').text.should == 'Compte de rattach.'
        page.find(:css,'thead th:nth-child(7)').text.should == 'Actions'

      end
    end

    context 'check content of a row' do
      it "shows the relevant informations" do
        @ba=@bank_accounts.first
        page.find('tbody tr:first td:nth-child(1)').text.should == @ba.bank_name
        page.find('tbody tr:first td:nth-child(2)').text.should == @ba.number
        page.find('tbody tr:first td:nth-child(3)').text.should == @ba.nickname
        page.find('tbody tr:first td:nth-child(4)').text.should == 'Général'
        page.find('tbody tr:first td:nth-child(5)').text.should == 'un commentaire'
        page.find('tbody tr:first td:nth-child(6)').text.should == '5101'
        
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

