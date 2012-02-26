# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckDeposit do
  let(:ba) {stub_model(BankAccount, number: '123456A')} # un compte bancaire
  let(:c1) {mock_model(Line, credit: 11, payment_mode: 'Chèque', check_deposit_id:nil)}
  let(:c2) {mock_model(Line, credit: 22, payment_mode: 'Chèque', check_deposit_id:nil)}
  let(:c3) {mock_model(Line, credit: 55, payment_mode: 'Chèque', check_deposit_id:nil)} # et trois chèques

  before(:each) do
    @check_deposit = CheckDeposit.new
    Line.stub_chain(:non_depose, :all).and_return([c1,c2,c3])
  end

  describe "vérif de la situation de départ" do
    it "3 chèques à déposer" do
      Line.non_depose.all.should have(3).elements
    end
  end


  describe "controle de la validité" do
    before(:each) do
      [c1,c2,c3].each {|c| c.stub(:update_attribute).and_return(true)}
      [c1,c2,c3].each {|c| c.stub(:save).and_return(true)}
    end

    it 'n est valide qu avec un compte bancaire' do
      @check_deposit.pick_all_checks
      @check_deposit.save.should == false
    end
    it 'n est valide qu avec au moins une ligne' do
      @check_deposit.bank_account = ba
      @check_deposit.save.should == false
    end
  
    it 'est valide avec un compte bancaire et au moins un chèque' do
      @check_deposit.bank_account=ba
      @check_deposit.pick_all_checks
      @check_deposit.valid?
      @check_deposit.save.should == true
    end

  end


  describe "controle des méthodes" do

    it 'pick_all_checks récupère tous les chèques' do
      @check_deposit.pick_all_checks
      @check_deposit.picked_checks.should == [c1,c2,c3]
    end



    context 'il y a des lignes de chèques' do


      before(:each) do
        @check_deposit.pick_all_checks
      end

      it 'add_check' do
        @check_deposit.remove_picked_check(c2)
        @check_deposit.remove_picked_check(c3)
        @check_deposit.total_picked_checks.should ==11
        @check_deposit.pick_check(c2)
        @check_deposit.total_picked_checks.should ==33

      end


      it 'remove a check for the non saved check_deposit' do
        @check_deposit.remove_picked_check(c2)
        @check_deposit.total_picked_checks.should ==66
      end

      it 'total renvoie le total des lignes associées' do
        @check_deposit.total_picked_checks.should == 88
      end

      it 'devrait y avoir deux totaux avant et après sauvegarde'
    end

  end

  describe "verification de la mise à jour des lignes" do

  before(:each) do
    @check_deposit.bank_account=ba
  end

  it 'sauve le check deposit met bien à jour toutes les lignes associées' do
   
    @check_deposit.pick_all_checks
    [c1,c2,c3].each {|c| c.should_receive(:update_attribute).with(:check_deposit_id, 1).and_return(true)}
    # j'ai mis 1 en val de check_deposit_id car le test donnait ça mais en fait cela pourrait peut être varier
    [c1,c2,c3].each {|c| c.should_receive(:save).and_return(true)}
    @check_deposit.should be_valid
    @check_deposit.save!
  end

    it 'sauve le check deposit met bien à jour les lignes associées et pas les autres' do
    @check_deposit.pick_all_checks
    @check_deposit.remove_picked_check(c2)
    [c1,c3].each {|c| c.should_receive(:update_attribute).with(:check_deposit_id, 1).and_return(true)}
    # j'ai mis 1 en val de check_deposit_id car le test donnait ça mais en fait cela pourrait peut être varier
    [c1,c3].each {|c| c.should_receive(:save).and_return(true)}
    c2.should_not_receive(:save)
    @check_deposit.should be_valid
    @check_deposit.save!
  end
    

  end

    describe "après sauvegarde" do


      before(:each) do
        @o=Organism.create!(title: 'test check_deposit')
        @p=@o.periods.create!(start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
        @ba=@o.bank_accounts.create!(number: '123456Z')
        @b=@o.income_books.create!(title: 'Recettes')
        @n=@p.natures.create!(name: 'ventes')
        @l1=@b.lines.create!(line_date: Date.today, credit: 44, payment_mode:'Chèque', nature: @n)
        @l2=@b.lines.create!(line_date: Date.today, credit: 101, payment_mode:'Chèque', nature: @n)
        @l3=@b.lines.create!(line_date: Date.today, credit: 300, payment_mode:'Chèque', nature: @n)
        @cd=@ba.check_deposits.new
       [@l1,@l2,@l3].each {|l|  @cd.pick_check(l)}
        @cd.should be_valid
        @cd.save!
     end
    it 'total retourne le total des chèques' do
      @cd.lines.count.should == 3
      @cd.total.should == 445
    end

    it 'sauver ne met pas à jour le champ bank_account_id' do # il est mis à jour lors du pointage du compte
      
      
      [@l1,@l2,@l3].each {|l|  l.bank_account_id.should == nil}
    end

    it 'on peut retirer un chèque' do
      @cd.remove_check(@l1)
      @cd.lines.count.should == 2
      @cd.total.should == 401
    end

    it 'lorsquon détruit la remise les lignes sont mises à jour' do
      CheckDeposit.count.should == 1
      @cd.destroy
      CheckDeposit.count.should == 0
      [@l1,@l2,@l3].each {|l|  l.check_deposit_id.should == nil}
     
    end


  end
end

