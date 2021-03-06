# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/cashes/index' do
  include JcCapybara
  
  before(:each) do
    assign(:organism, stub_model(Organism))
    @cashes=[]
    @cashes << stub_model(Cash, name: 'Magasin', comment: 'la caisse du magasin') 
    @cashes << stub_model(Cash, name: 'Entrepot')
    @cashes.each do |b|
      b.stub(:created_at).and_return(Time.now)
      b.stub(:updated_at).and_return(Time.now)
      b.stub(:accounts).and_return [mock_model(Account, number:'5301')] 
    end
  end

  context 'mise en page générale' do
    before(:each) do
      render 
    end 

    it "should have title h3" do
      page.find('h3').should have_content 'Liste des caisses'
    end

    it "should have one table" do
      page.should have_css('table', :count=>1)
    end

    it 'avec deux ligness' do
      page.find('table tbody').should have_css('tr', :count=>2)
    end

    it "each row should show 2 icons (edit and delete)" do
      page.find('tbody tr:first').should have_css('img',:count=>1)
    end

    it "each row should show edit icon" do
      page.all('tbody tr img').first[:src].should match /\/assets\/icones\/modifier.png/
    end

  

    context 'title row' do
      it "shows Caisse" do
        page.find('thead th:first').text.should == 'Nom'
        page.find('thead th:nth-child(2)').text.should == 'Commentaire'
        page.find('thead th:nth-child(3)').text.should == 'Secteur'
        page.find('thead th:nth-child(4)').text.should == 'Compte de rattach.' 
        page.find('thead th:nth-child(5)').text.should == 'Actions'
      end
    end

    context 'check content of a row' do
      it "shows the relevant informations" do
        @ca=@cashes.first
        page.find('tbody tr:first td:nth-child(1)').text.should == @ca.name
        page.find('tbody tr:first td:nth-child(2)').text.should == @ca.comment
        page.find('tbody tr:first td:nth-child(3)').text.should == ''
        page.find('tbody tr:first td:nth-child(4)').text.should == '5301'
        
      end
    end

  end
  # on ne peut le traiter comme les autres car le render ne doit pas arriver
  # avant le stub_chain
  context 'test de l affichage de l icone destroy' do
    it "with a line, row should not propose supprimer" do
      @cashes.first.stub_chain(:cash_controls, :empty?).and_return(false)
      render
      page.should_not have_css('tbody tr:first img[src="/assets/icones/supprimer.png"]')
    end
  end 
       
end

