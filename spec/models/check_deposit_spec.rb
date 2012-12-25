# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


RSpec.configure do |c|
 #   c.filter = {:wip=> true }
end


describe CheckDeposit do   
  include OrganismFixture  
 
  before(:each) do 
    create_minimal_organism
    @w1 = create_in_out_writing(44, 'Chèque')
    @w2 = create_in_out_writing(101, 'Chèque')
    @w3 = create_in_out_writing(300, 'Chèque')
    @w4 = create_in_out_writing(50000, 'Virement')
    @ch= CheckDeposit.new
  end

 
  describe "methodes de classe sur les chèques à déposer"  do

    it "la classe check_deposit can give the total of non_deposited checks" do
      CheckDeposit.total_to_pick.should == 445
    end

    it 'vérif des contre lignes' do
      ComptaLine.pending_checks.count.should == 3
    end

    it "3 chèques à déposer" do
      CheckDeposit.pending_checks.should have(3).elements
      CheckDeposit.pending_checks.should == [@w1.children.last,@w2.children.last,@w3.children.last]
    end

    

    it "la classe donne le nombre total de chèques à encaisser pour l'organsime" do
      CheckDeposit.nb_to_pick.should == 3
    end

   
  end

  describe "création d'une remise de chèque"  do
    it "save the right date" do
      cd = @ba.check_deposits.new deposit_date_picker: '01/04/2012'
      cd.pick_all_checks
      cd.save!
      cd.deposit_date.should == Date.civil(2012,4,1)
    end

    describe 'creation d une écriture'  do

      before(:each) do
        @cd = @ba.check_deposits.new deposit_date:Date.today 
        @cd.pick_all_checks

      end

      it 'crée une writing' do
        expect {@cd.save}.to change {Writing.count}.by(1)
      end

      it 'créed un check_deposit' do
        expect {@cd.save}.to change {CheckDeposit.count}.by(1)
      end

      it 'une remise chèque appartient à writing' do
        @cd.save!
        CheckDeposit.last.writing.should == Writing.order(:id).last
      end

      it 'une remise chèque a des lignes qui sont lues par writing' do
        @cd.save!
        @cd.compta_lines.should == @cd.writing(true).compta_lines
      end


    end
  end 

  describe "controle de la validité : un check_deposit" do

    before(:each) do
      @check_deposit = CheckDeposit.new(deposit_date: (Date.today +1))
    end

    it "n'est valide qu'avec un bank_account" do
      @check_deposit.should have(1).errors_on(:bank_account_id)
    end
    
    
    it "n'est valide qu avec au moins une ligne" do
      @check_deposit.bank_account_id = @ba.id
      @check_deposit.checks.should be_empty
      @check_deposit.save.should == false
      @check_deposit.should have(1).errors_on(:base)
    end

    it "n'est pas valide sans date" do
      @check_deposit.bank_account_id = @ba.id
      @check_deposit.pick_all_checks
      @check_deposit.deposit_date = nil
      @check_deposit.should have(1).errors_on(:deposit_date)
      @check_deposit.save.should == false
    end
  
    it 'est valide avec un compte bancaire et au moins un chèque' do
      @check_deposit.bank_account=@ba
      @check_deposit.pick_all_checks
      @check_deposit.should be_valid
      @check_deposit.errors.messages.should == {}
      @check_deposit.save.should == true
    end

  end
 

  describe "Controle des méthodes"  do

    before(:each) do
      @check_deposit = @ba.check_deposits.new(deposit_date: Date.today)
    end

    it 'pick_all_checks récupère tous les chèques' do
      @check_deposit.pick_all_checks
      @check_deposit.checks.should == [@w1.children.last,@w2.children.last,@w3.children.last]
    end

    it "un nouvel enregistrement a son total à zero" do
      @check_deposit.total_checks.should == 0
    end

    context "lorsque la remise est un nouvel enregistrement, la fonction total fonctionne" do

      before(:each) do
        @check_deposit.pick_all_checks
      end

      it 'total renvoie le total des lignes associées' do
        @check_deposit.total_checks.should == 445
      end

      it 'quand on retire un chèque, total est mis à jour' do
        @check_deposit.checks.delete(@w2.children.last)
        @check_deposit.total_checks.should == 344
      end

      it 'idem après ajout de chèque' do
        @check_deposit.total_checks.should == 445
        @check_deposit.checks.delete(@w1.children.last)
        @check_deposit.checks.delete(@w3.children.last)
        @check_deposit.total_checks.should == 101
        @check_deposit.checks << @w3.children.last
        @check_deposit.total_checks.should == 401
      end

    end

    

  end

  describe "après sauvegarde"  do
 
    before(:each) do
      date = Date.today + 2
      @check_deposit = @ba.check_deposits.new(deposit_date: date)
      @check_deposit.pick_all_checks
      @check_deposit.save!
    end

    
    describe 'sauver doit avoir créé une écriture'  do

      it 'ligne au credit du 511'  do
        cl = @check_deposit.credit_line
        cl.date.should == @check_deposit.deposit_date
        cl.account.number.should == REM_CHECK_ACCOUNT[:number]
        cl.credit.should == @check_deposit.total_checks

      end

      it 'ligne au débit du 511' do
        dl = @check_deposit.debit_line
        dl.date.should == @check_deposit.deposit_date
        dl.account.should == @check_deposit.bank_account.current_account(@p)
        dl.debit.should == @check_deposit.total_checks
      end

    end

    it 'sauver devrait avoir mis à jour le champ check_deposit_id des lignes ayant 511 comme compte'  do
      @check_deposit.total_checks.should == 445
      ls = ComptaLine.where('account_id = ?', @p.rem_check_account.id)
      ls.size.should == 4 # les 3 chèques plus la contrepartie
      ls.each {|l|  l.check_deposit_id.should == @check_deposit.id }

    end

    it 'le compte est soldé puisqu on a pris tous les chèques' do
      @p.rem_check_account.sold_at(@p.close_date).should == 0
    end



    describe 'edition' do

      it 'remove a check'  do
        l2 = @w2.children.last
        @check_deposit.checks.delete(l2)
        @check_deposit.total_checks.should == 344
        @check_deposit.save!
        # doit modifier la ligne total de la remise
        
      end

      it 'add_check'  do
        @check_deposit.total_checks.should == 445
        @check_deposit.checks.delete(@w1.support_line)
        @check_deposit.checks.delete(@w3.support_line)
        @check_deposit.total_checks.should == 101
        @check_deposit.checks << @w3.support_line
        @check_deposit.total_checks.should == 401
        @check_deposit.save!
        @check_deposit.credit_line.credit.should == 401
        @check_deposit.debit_line.debit.should == 401
      end

      it 'change date' do
        @check_deposit.writing.date.should == (Date.today + 2)
        @check_deposit.deposit_date  =  Date.today
        @check_deposit.save
        @check_deposit.writing.date.should == Date.today

      end

    end

    it 'on peut détruire la remise'  do
      expect {@check_deposit.destroy}.to change{CheckDeposit.count}.by(-1)
    end

    it 'lorsqu on détruit la remise les lignes sont mises à jour'do
      CheckDeposit.pending_checks.each {|c| puts c.inspect}
      CheckDeposit.nb_to_pick.should == 0
      @check_deposit.destroy
      CheckDeposit.nb_to_pick.should == 3
    end

    it 'l ecriture est détruite'   do
      expect {@check_deposit.destroy}.to change {ComptaLine.count}.by(-2)
    end

    it "on peut changer la date" do
      @check_deposit.deposit_date += 2
      @check_deposit.should be_valid
    end

    it "on peut changer le compte bancaire" do  
      @check_deposit.bank_account_id = 9999 
      @check_deposit.should be_valid 
    end

    

    describe "le rattachement à un extrait de compte" do
      before(:each) do
        @check_deposit.should have(3).checks
        @be = @ba.bank_extracts.create!(end_date: (Date.today +15), begin_date: (Date.today -15))
        @bel = @be.bank_extract_lines.new
        @bel.compta_lines << @check_deposit.debit_line
        @bel.save!
      end

      it 'doit être pointé' do
        @check_deposit.should be_pointed
      end

     
      it "la date ne peut plus être modifiée" do
        @check_deposit.deposit_date = Date.today+6
        @check_deposit.should_not be_valid
      end

      it "la banque ne peut plus être modifiée" do
        @ba2=@o.bank_accounts.create!(bank_name: "L'autre Banque", number: 'Un autre compte', nickname:'Cpte Epargne')
        @check_deposit.bank_account = @ba2
        @check_deposit.should_not be_valid
      end

      it "ne peut plus être détruit" do
        expect {@check_deposit.destroy}.to raise_error
      end

      it "ne peut plus retirer de chèque" do
        expect {@check_deposit.checks.delete(@w2.supportline)}.to raise_error
      end

      it "ne peut plus ajouter de chèque" do
        @w5 = create_in_out_writing(44, 'Chèque')
        expect {@check_deposit.checks << @w5.supportline}.to raise_error
        
      end
   
    end # fin du rattachement à un extrait de compte
  end 

 

  

end

