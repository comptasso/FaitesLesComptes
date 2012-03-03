# coding: utf-8

require 'spec_helper'

describe CheckDepositsController do

  before(:each) do
    @o=Organism.create!(title: 'test check_deposit')
    @p_2012=@o.periods.create!(start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
    @p_2011=@o.periods.create!(start_date: (@p_2012.start_date - 365) , close_date: (@p_2012.start_date - 1))
    @ba=@o.bank_accounts.create!(name: 'AiD', number: '123456Z')
    @b=@o.income_books.create!(title: 'Recettes')
    @n=@p_2012.natures.create!(name: 'ventes')
    @n_2011=@p_2011.natures.create!(name: 'ventes')
    @l1=@b.lines.create!(line_date: Date.today, credit: 44, payment_mode:'Chèque', nature: @n)
    @l2=@b.lines.create!(line_date: Date.today, credit: 101, payment_mode:'Chèque', nature: @n)
    @l3=@b.lines.create!(line_date: Date.today, credit: 300, payment_mode:'Chèque', nature: @n)
    @l4=@b.lines.create!(line_date: Date.today - 365 , credit: 150, payment_mode:'Chèque', nature: @n_2011)
    @cd1= @ba.check_deposits.new(deposit_date: Date.today)
    @cd1.checks << @l1
    @cd1.save!
    @ba2=@o.bank_accounts.create!(name: 'BA2', number: 'un autre compte')
    @cd2=@ba2.check_deposits.new(deposit_date: Date.today)
    @cd2.checks << @l2
    @cd2.save!
  end

   describe "GET index" do

    it "controle du controller" do
      get :index, :bank_account_id=>@ba.id
      assigns[:organism].should == @o
    end

    it "assigne la bank_account" do
      get :index, :bank_account_id=>@ba.id
      assigns[:bank_account].should ==(@ba)
    end

    it "assigne le nombre de chèque à remettre à l'encaissement" do
      get :index, :bank_account_id=>@ba.id.to_s
      assigns[:nb_to_pick].should == 2
    end

    it "assigns all check_deposit as @check_deposits" do
     pending 'FIXME'
      get :index, :bank_account_id=>@ba.id.to_s
      assigns(:check_deposits).should eq([@cd1])
    end

    it "avec deux banques sélectionne uniquement les remises correspondantes" do
      pending 'FIXME'
      get :index, :bank_account_id=>@ba2.id
      assigns(:check_deposits).should eq([@cd2])
      get :index, :bank_account_id=>@ba.id
      assigns(:check_deposits).should eq([@cd1])
    end


    it "construit le flash notice indiquant qu il reste des chèques à remettre à l'encaissement" do
      get :index, :bank_account_id=>@ba2.id
      flash[:notice].should == "Il y a 2 chèques à remettre à l'encaissement pour un montant de 450.00 €"
    end


    it "ne prend que les remises de chèques qui sont dans l'exercice demandé" do
      @cd4=@ba.check_deposits.new(deposit_date: Date.today-365)
      @cd4.checks << @l4
      @cd4.save
      pending 'PB avec les sessions de period'
      session[:period]= @p_2011.id
      get :index, :bank_account_id=>@ba2.id
      assigns(:check_deposits).should == @cd4
    end

    it "rend le template index" do
      get :index, :bank_account_id=>@ba.id
      response.should render_template("index")
    end
  end
end

