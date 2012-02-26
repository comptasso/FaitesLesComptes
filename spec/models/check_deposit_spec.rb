# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckDeposit do

  before(:each) do

        @o=Organism.create!(title: 'test check_deposit')
        @p=@o.periods.create!(start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
        @ba=@o.bank_accounts.create!(number: '123456Z')
        @b=@o.income_books.create!(title: 'Recettes')
        @n=@p.natures.create!(name: 'ventes')
        @l1=@b.lines.create!(line_date: Date.today, credit: 44, payment_mode:'Chèque', nature: @n)
        @l2=@b.lines.create!(line_date: Date.today, credit: 101, payment_mode:'Chèque', nature: @n)
        @l3=@b.lines.create!(line_date: Date.today, credit: 300, payment_mode:'Chèque', nature: @n)
        

  end

  describe "vérif de la situation de départ" do
    it "3 chèques à déposer" do
      Line.non_depose.all.should have(3).elements
    end
  end


  describe "controle de la validité" do

    before(:each) do
      @check_deposit = CheckDeposit.new
    end
    
    it "n'est valide qu avec un compte bancaire" do
      @check_deposit.pick_all_checks
      @check_deposit.save.should == false
    end
    it "n'est valide qu avec au moins une ligne" do
      @check_deposit.bank_account = @ba
      @check_deposit.save.should == false
    end
  
    it 'est valide avec un compte bancaire et au moins un chèque' do
      @check_deposit.bank_account=@ba
      @check_deposit.pick_all_checks
      @check_deposit.save.should == true
    end

  end


  describe "controle des méthodes" do

    before(:each) do
      @check_deposit = CheckDeposit.new
    end

    it 'pick_all_checks récupère tous les chèques' do
      @check_deposit.pick_all_checks
      @check_deposit.lines.should == Line.all
    end


    context "lorsque la remise est un nouvel enregistrement, il faut que la fonction total fonctionne" do

      before(:each) do
        @check_deposit.pick_all_checks
      end

      it 'total renvoie le total des lignes associées' do
        @check_deposit.total.should == 445
      end

      it 'quand on retire un chèque, total est mis à jour' do
        @check_deposit.remove_check(@l2)
        @check_deposit.total.should == 344
      end

      it 'idem après ajout de chèque' do
        @check_deposit.total.should == 445
        @check_deposit.remove_check(@l1)
        @check_deposit.remove_check(@l3)
        @check_deposit.total.should == 101
        @check_deposit.pick_check(@l3)
        @check_deposit.total.should == 401
      end

    end

  end

   describe "après sauvegarde" do
 
   before(:each) do
      @check_deposit = @ba.check_deposits.new
      @check_deposit.pick_all_checks
      @check_deposit.save!
    end

    it 'sauver ne met pas à jour le champ bank_account_id' do # il est mis à jour lors du pointage du compte
       Line.all.each {|l|  l.bank_account_id.should == nil}
    end

     it 'remove a check' do
        @check_deposit.remove_check(@l2)
        @check_deposit.total.should == 344
      end

      it 'add_check' do
        @check_deposit.total.should == 445
        @check_deposit.remove_check(@l1)
        @check_deposit.remove_check(@l3)
        @check_deposit.total.should == 101
        @check_deposit.pick_check(@l3)
        @check_deposit.total.should == 401
      end

    it 'lorsquon détruit la remise les lignes sont mises à jour' do
      CheckDeposit.count.should == 1
      @check_deposit.destroy
      CheckDeposit.count.should == 0
      Line.all.each {|l|  l.check_deposit_id.should == nil}
    end


  end
end

