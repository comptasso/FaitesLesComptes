# coding: utf-8

require 'spec_helper'

describe CheckDepositsController do

  before(:each) do
    @o=Organism.create!(title: 'test check_deposit')
    @p_2012=@o.periods.create!(start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year) # année 2012
    @p_2011=@o.periods.create!(start_date: (@p_2012.start_date - 365) , close_date: (@p_2012.start_date - 1)) # année 2011
    @ba=@o.bank_accounts.create!(name: 'AiD', number: '123456Z', organism_id: @o.id)
    @b=@o.income_books.create!(title: 'Recettes')
    @n=@p_2012.natures.create!(name: 'ventes')
    @n_2011=@p_2011.natures.create!(name: 'ventes')
    @l1=@b.lines.create!(line_date: Date.today,:narration=>'ligne de test', credit: 44, payment_mode:'Chèque', nature: @n)
    @l2=@b.lines.create!(line_date: Date.today,:narration=>'ligne de test', credit: 101, payment_mode:'Chèque', nature: @n)
    @l3=@b.lines.create!(line_date: Date.today,:narration=>'ligne de test', credit: 300, payment_mode:'Chèque', nature: @n)
    @l4=@b.lines.create!(line_date: Date.today - 365 ,:narration=>'ligne de test', credit: 150, payment_mode:'Chèque', nature: @n_2011) # une écriture de 2011
    @cd1= @ba.check_deposits.new(deposit_date: Date.today)
    @cd1.checks << @l1
    @cd1.save!
    @ba2=@o.bank_accounts.create!(name: 'BA2', number: 'un autre compte')
    @cd2=@ba2.check_deposits.new(deposit_date: Date.today)
    @cd2.checks << @l2
    @cd2.save!
  end

  describe "GET index" do

    context "no pending_checks" do

      before(:each) do
        CheckDeposit.stub!(:pending_checks).and_return nil
        CheckDeposit.stub!(:total_to_pick).and_return 0
        CheckDeposit.stub!(:nb_to_pick).and_return 0
      end

      it "verif du before filter" do
        get :index, :bank_account_id=>@ba.id, :organism_id=>@o.id
      end

      it "vérification de l'initialisation" do
        get :index, :bank_account_id=>@ba.id, :organism_id=>@o.id.to_s
        assigns[:period].should == @p_2012
        assigns[:organism].should == @o
        assigns[:bank_account].should == @ba
      end

      it "assigne la bank_account" do
        get :index, :bank_account_id=>@ba.id,  :organism_id=>@o.id.to_s
        assigns[:bank_account].should ==(@ba)
      end

      it "assigns all check_deposit as @check_deposits" do
        # création d' une autre remise de chèques
        @cd3= @ba.check_deposits.new(deposit_date: Date.today)
    @cd3.checks << @l3
    @cd3.save!
        get :index, :bank_account_id=>@ba.id.to_s,  :organism_id=>@o.id.to_s
        assigns(:check_deposits).should eq([@cd1, @cd3])
      end

       it "sans chèques en attente, ne génère pas de flash" do
        
        get :index, :bank_account_id=>@ba2.id, :organism_id=>@o.id.to_s
        flash[:notice].should == nil
      end

      context "avec deux banques" do

        it "avec deux banques sélectionne uniquement les remises correspondantes" do
        
          get :index, :bank_account_id=>@ba2.id,  :organism_id=>@o.id.to_s
          assigns(:check_deposits).should eq([@cd2])
          get :index, :bank_account_id=>@ba.id,  :organism_id=>@o.id.to_s
          assigns(:check_deposits).should eq([@cd1])
        end


      end

     
      it "ne prend que les remises de chèques qui sont dans l'exercice demandé" do
        @cd4=@ba.check_deposits.new(deposit_date: Date.today-365)
        @cd4.checks << @l4
        @cd4.save!
        session[:period]= @p_2011.id
        get :index, :bank_account_id=>@ba.id,  :organism_id=>@o.id.to_s
        assigns(:check_deposits).should == [@cd4]
      end

      it "rend le template index" do
        get :index, :bank_account_id=>@ba.id,  :organism_id=>@o.id.to_s
        response.should render_template("index")
      end
    end

    context "teste le remplissage du flash lorsqu'il y a des pending_checks" do
      before(:each) do
        CheckDeposit.stub!(:pending_checks).and_return [@l2, @l3]
        CheckDeposit.stub!(:total_to_pick).and_return 401
        CheckDeposit.stub!(:nb_to_pick).and_return 2

      end
      it "assigne le nombre de chèque à remettre à l'encaissement" do
        get :index, :bank_account_id=>@ba.id.to_s,  :organism_id=>@o.id.to_s
        assigns[:nb_to_pick].should == 2
      end

      it "construit le flash notice indiquant qu il reste des chèques à remettre à l'encaissement" do
        get :index, :bank_account_id=>@ba2.id, :organism_id=>@o.id.to_s
        flash[:notice].should == "Il y a 2 chèques à remettre à l'encaissement pour un montant de 401.00 €"
      end
    end

  end
end # fin de index

