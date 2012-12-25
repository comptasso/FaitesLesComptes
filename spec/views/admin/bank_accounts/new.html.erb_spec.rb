# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/bank_accounts/new' do
  include JcCapybara
  before(:each) do
    assign(:organism, stub_model(Organism))
    @bank_account = stub_model(BankAccount).as_new_record
  end

  context 'mise en page générale' do
    before(:each) do
      render
    end

    it "should have title h3" do
      page.find('h3').text.should ==  "Nouveau compte bancaire"

    end

    it "should have one form" do
      page.all('form').should have(1).element
    end

    it "form should have field title" do
      page.should have_css('form input[name="bank_account[bank_name]"]')
    end

    it "form should have field numero de compte" do
      page.should have_css('form input[name="bank_account[number]"]') 
    end

     it "form should have field nickname" do
      page.should have_css('form input[name="bank_account[nickname]"]')
    end

    it 'avec comme label Surnom' do
      page.should have_content('Surnom')
    end

    it "form should have field comment" do
      page.should have_css('form textarea[name="bank_account[comment]"]')
    end

    it "form should have field title" do
      page.find('form input[type="submit"]').value.should == 'Créer le compte'
    end


  end


end
