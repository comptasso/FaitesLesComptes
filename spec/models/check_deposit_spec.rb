# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


RSpec.configure do |c|
#    c.filter = {:wip=> true }
end


describe CheckDeposit do
  include OrganismFixture  

  before(:each) do
    create_minimal_organism
    @p.accounts.create!(number:'520', title:'Remise chèque')
    @l1=@ib.lines.create!(line_date: Date.today, counter_account:@baca, :narration=>'ligne de test', credit: 44, payment_mode:'Chèque', nature: @n)
    @l2=@ib.lines.create!(line_date: Date.today, counter_account:@baca,:narration=>'ligne de test',credit: 101, payment_mode:'Chèque', nature: @n)
    @l3=@ib.lines.create!(line_date: Date.today,counter_account:@baca,:narration=>'ligne de test', credit: 300, payment_mode:'Chèque', nature: @n)
    @l5=@ib.lines.create!(line_date: Date.today,counter_account:@baca, :narration=>'ligne de test',credit: 50000, payment_mode:'Virement', nature: @n)
  end

 
  describe "vérif de la situation de départ" do
    it "3 chèques à déposer" do
      @o.pending_checks.should have(3).elements
    end

    it "ne doit pas prétendre fonctionner sans un rattachement à un compte bancaire" do
      @ch= CheckDeposit.new
      expect { @ch.pick_all_checks}.to raise_error
    end
  end

  describe "methodes de classe sur les chèques à déposer" do
    it "la classe check_deposit can give the total of non_deposited checks" do
      CheckDeposit.total_to_pick(@o).should == 445
    end

    it "la classe donne le nombre total de chèques à encaisser pour l'organsime" do
      CheckDeposit.nb_to_pick(@o).should == 3
    end

    it "la classe donne le tableau des chèques à encaisser" do
      CheckDeposit.pending_checks(@o).should == [@l1,@l2,@l3]
    end
  end

  describe "création d'un chèque" do
    it "save the right date" do
    cd = @ba.check_deposits.new pick_date: '01/04/2012'
    cd.pick_all_checks
    cd.save!
    cd.deposit_date.should == Date.civil(2012,4,1)
  end
  end 

  describe "controle de la validité : un check_deposit" do

    before(:each) do
      @check_deposit = @ba.check_deposits.new(deposit_date: (Date.today +1))
    end

    it "n'est valide qu'avec un bank_account" do
      @check_deposit.bank_account.should == @ba 
    end
    
    
    it "n'est valide qu avec au moins une ligne" do
      pending 'suppression de cette validation pour arriver à faire la restauration'
      @check_deposit.checks.should be_empty
      @check_deposit.save.should == false
    end

    it "n'est pas valide sans date" do
      @check_deposit.pick_all_checks
      @check_deposit.deposit_date = nil
      @check_deposit.save.should == false
    end
  
    it 'est valide avec un compte bancaire et au moins un chèque' do
      @check_deposit.bank_account=@ba
      @check_deposit.pick_all_checks
      @check_deposit.valid?
      @check_deposit.errors.messages.should == {}
      @check_deposit.save.should == true
    end

  end
 

  describe "Controle des méthodes" do

    before(:each) do
      @check_deposit = @ba.check_deposits.new(deposit_date: Date.today)
    end

    it 'pick_all_checks récupère tous les chèques' do
      @check_deposit.pick_all_checks
      @check_deposit.checks.should == [@l1,@l2,@l3]
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
        @check_deposit.checks.delete(@l2)
        @check_deposit.total_checks.should == 344
      end

      it 'idem après ajout de chèque' do
        @check_deposit.total_checks.should == 445
        @check_deposit.checks.delete(@l1)
        @check_deposit.checks.delete(@l3)
        @check_deposit.total_checks.should == 101
        @check_deposit.checks << @l3
        @check_deposit.total_checks.should == 401
      end

    end

    context "vérification du callback remove" do

      it "toutes les lignes ont un bank_account_id à nil" do
        [@l1,@l2,@l3].each {|l| l.bank_account_id.should == nil}
      end

      it "retirer un chèque de la remise enlève son bank_account_id" do
        @check_deposit.checks << @l2
        @check_deposit.save!
        Line.find_by_credit(101).bank_account_id.should == @check_deposit.bank_account_id
        @check_deposit.checks.delete(@l2)
        @l2.bank_account_id.should == nil
      end

    end

  end

  describe "après sauvegarde" do
 
    before(:each) do
      date = Date.today + 2
      @check_deposit = @ba.check_deposits.new(deposit_date: date)
      @check_deposit.deposit_date.should == (Date.today + 2)
      @check_deposit.pick_all_checks
      @check_deposit.save!
    end

    it "a sauvé la bonne date" do
      @check_deposit.deposit_date.should == (Date.today + 2)
    end

    it 'sauver devrait avoir mis à jour les champs bank_account_id' do
      @check_deposit.bank_account_id.should == @ba.id
      @check_deposit.total_checks.should == 445
      ls = Line.find_all_by_payment_mode('Chèque')
      ls.size.should == 6 # les 3 chèques mais chacun correspond à deux lignes
      ls.each {|l|  l.bank_account_id.should == @check_deposit.bank_account_id }
    end

    it 'remove a check' do
      @check_deposit.save!
      l2=@check_deposit.checks.where('credit = 101').first
      @check_deposit.checks.delete(l2)
      @check_deposit.total_checks.should == 344
      @check_deposit.save!
      Line.find_by_credit(101).bank_account_id.should == nil
      Line.find_by_credit(44).bank_account_id.should == @check_deposit.bank_account_id
      Line.find_by_credit(300).bank_account_id.should == @check_deposit.bank_account_id
    end

    it 'add_check' do
      @check_deposit.total_checks.should == 445
      @check_deposit.checks.delete(@l1)
      @check_deposit.checks.delete(@l3)
      @check_deposit.total_checks.should == 101
      @check_deposit.checks << @l3
      @check_deposit.total_checks.should == 401
    end

    it 'on peut détruire la remise' do
      expect {@check_deposit.destroy}.to change{CheckDeposit.count}.by(-1)
    end

    it 'lorsquon détruit la remise les lignes sont mises à jour' do
      @check_deposit.destroy
      Line.all.each {|l|  l.check_deposit_id.should == nil}
    end

    it "on peut changer la date" do
      @check_deposit.deposit_date += 2
      @check_deposit.should be_valid
    end

    it "on peut changer le compte bancaire" do  
      @check_deposit.bank_account_id = 9999 
      @check_deposit.should be_valid
    end

    it 'la remise est identifiée par le scope not_pointed'  do
      CheckDeposit.not_pointed.should have(1).item
    end

    describe "le rattachement à un extrait de compte"  do
      before(:each) do
        @ba.np_check_deposits.should == [@check_deposit]
        @be = @ba.bank_extracts.create!(end_date: (Date.today +15), begin_date: (Date.today -15))
        @bel = @be.bank_extract_lines.create!
        @check_deposit.bank_extract_line = @bel
      end

      it "entraine la mise à jour des lignes de chèques" do
        @check_deposit.save!
        Line.where('check_deposit_id=?', @check_deposit_id).all.each {|l|  l.bank_account_id.should == @ba.id}
         
      end
   
      context "après rattachement à un extrait de compte" do

        before(:each) do
          @check_deposit.update_attribute(:bank_extract_line, @bel)
        end

        it 'la remise n est plus selectionnée par le scope not_pointed'  do
          CheckDeposit.not_pointed.should have(0).item
        end

        it "la date ne peut plus être modifiée" do
          @check_deposit.deposit_date= Date.today+6
          @check_deposit.should_not be_valid
        end

        it "la banque ne peut plus être modifiée" do
          @ba2=@o.bank_accounts.create!(name: "L'autre Banque", number: 'Un autre compte')
          @check_deposit.bank_account = @ba2
          @check_deposit.should_not be_valid
        end

        it "ne peut plus être détruit" do
          expect {@check_deposit.destroy}.to raise_error
        end

        it "ne peut plus retirer de chèque" do
        
          expect {@check_deposit.checks.delete(@l2)}.to raise_error
       
        end

        it "ne peut plus ajouter de chèque" do
          @l4=@ib.lines.create!(line_date: Date.today,counter_account:@baca, :narration=>'ligne de test', credit: 300, payment_mode:'Chèque', nature: @n)
       
          expect {@check_deposit.checks << @l4}.to raise_error
        
        end

      

      end

    end # fin du rattachement à un extrait de compte
  end 

  context "avec deux organismes"  do
    before(:each) do
      @o2=Organism.create!(title: 'autre société', database_name:'assotest2')
      @p2=@o2.periods.create!(start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
      @p2.accounts.create!(number:'520', title:'Remise chèque')
      @ba2=@o2.bank_accounts.create!(name: 'BBIC', number: '987654321Z')
      @b2=@o2.income_books.create!(title: 'Recettes')
      @n2=@p2.natures.create!(name: 'ventes')
      
      @l21=@b2.lines.create!(line_date: Date.today,counter_account:@baca,  :narration=>'ligne de test',credit: 244, payment_mode:'Chèque', nature: @rec)
      @l22=@b2.lines.create!(line_date: Date.today, counter_account:@baca, :narration=>'ligne de test',credit: 2101, payment_mode:'Chèque', nature: @rec)
      @l23=@b2.lines.create!(line_date: Date.today, counter_account:@baca, :narration=>'ligne de test',credit: 2300, payment_mode:'Chèque', nature: @rec)
      @cd2=@ba2.check_deposits.new
    end

    it "should not mix the checks of the two organisms" do
      @cd2.pick_all_checks
      @cd2.total_checks.should == 2300+2101+244
    end
  end

  describe "Ne pas mélanger les chèques de deux organismes" do
    before(:each) do
      @o2=Organism.create!(title: 'Autre société', database_name:'assotest2')
      @p2=@o2.periods.create!(start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
      @p2.accounts.create!(number:'520', title:'Remise chèque')
      @ba2=@o2.bank_accounts.create!(name: 'IBAN', number: '123456Z')
      @b2=@o2.income_books.create!(title: 'Recettes')
      @n2=@p2.natures.create!(name: 'ventes')
      @ligne1=@b2.lines.create!(line_date: Date.today, counter_account:@baca, :narration=>'ligne de test',credit: 44, payment_mode:'Chèque', nature: @n)
    end

    it "Line non depose a maintenant 4 éléments appartenant à 2 organismes" do
      Line.non_depose.count.should == 4
      @o.pending_checks.count.should == 3
      @o2.pending_checks.count.should == 1
    end

  end

end

