# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


RSpec.configure do |c|
  # c.filter = {:wip=> true }
end
# TODO on pourrait accélérer ces tests en testant pending_checks
# dans ComptaLine et après ensuite en utilisant des stubs
# A refactoriser car il y a des doublons dans les tests (création écriture notamment)

describe CheckDeposit do
  include OrganismFixtureBis

  before(:each) do
    use_test_organism
    @w1 = create_in_out_writing(44, 'Chèque')
    @w2 = create_in_out_writing(101, 'Chèque')
    @w3 = create_in_out_writing(300, 'Chèque')
    @w4 = create_in_out_writing(50000, 'Virement')
    @ch= CheckDeposit.new
  end

  after(:each) { erase_writings }

  describe "methodes de classe sur les chèques à déposer" do

    it 'total_to pick donne le total' do
      CheckDeposit.total_to_pick.should == 445
    end

    it 'pending_checks donne les 3 chèques qui sont à déposer' do
      CheckDeposit.pending_checks.should have(3).elements
      CheckDeposit.pending_checks.should == [@w1.children.last,@w2.children.last,@w3.children.last]
    end

    it 'nb_to_pick renvoie le nombre de chèques à encaisser' do
      CheckDeposit.nb_to_pick.should == 3
    end

    context 'quand on précise un secteur', wip:true  do

      before(:each) {@sect2 = mock_model(Sector, name:'ASC')}
      # after(:each) {@ba.update_attribute(sector_id:@sid) unless @ba.sector_id == @sid}

      it 'pending_checks ne renvoie pas de chèques si le secteur demandé est différent' do
        @sect2 = mock_model(Sector)
        expect(CheckDeposit.nb_to_pick(@sector)).to eq(3)
        expect(CheckDeposit.nb_to_pick(@sect2)).to eq(0)
      end

      it 'si le secteur est commun, alors on prend tous les chèques' do
        @sect2 = mock_model(Sector, name:'Commun')
        expect(CheckDeposit.nb_to_pick(@sect2)).to eq(3)
      end
    end
  end

  describe "création d'une remise de chèque" do
    it "save the right date", wip:true  do
      d = @p.start_date.months_since(4)
      cd = @ba.check_deposits.new deposit_date_picker:I18n::l(d, :format=>:date_picker)
      cd.pick_all_checks(@sector)
      puts cd.errors.messages unless cd.valid?
      cd.save!
      cd.deposit_date.should == d
    end

    describe 'creation d une écriture'  do

      before(:each) do
        @cd = @ba.check_deposits.new deposit_date:Date.today
        @cd.pick_all_checks(@sector)

      end

      it 'crée une writing' do
        expect {@cd.save}.to change {Writing.count}.by(1)
      end

      it 'créed un check_deposit' do
        expect {@cd.save}.to change {CheckDeposit.count}.by(1)
      end

      it 'une remise chèque appartient à writing' do
        @cd.save!
        CheckDeposit.last.check_deposit_writing.should == Writing.order(:id).last
      end

      it 'une remise chèque a des lignes qui sont lues par writing' do
        @cd.save!
        @cd.compta_lines.should == @cd.check_deposit_writing(true).compta_lines
      end


    end
  end

  describe "controle de la validité : un check_deposit" do

    before(:each) do
      @check_deposit = CheckDeposit.new(:deposit_date=>(Date.today + 1))
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
      @check_deposit.pick_all_checks(@sector)
      @check_deposit.deposit_date = nil
      @check_deposit.should have(1).errors_on(:deposit_date)
      @check_deposit.save.should == false
    end

    it 'est valide avec un compte bancaire et au moins un chèque' do
      @check_deposit.bank_account=@ba
      @check_deposit.pick_all_checks(@sector)
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
      @check_deposit.pick_all_checks(@sector)
      @check_deposit.checks.should == [@w1.children.last,@w2.children.last,@w3.children.last]
    end

    it "un nouvel enregistrement a son total à zero" do
      @check_deposit.total_checks.should == 0
    end

    context "lorsque la remise est un nouvel enregistrement, la fonction total fonctionne" do

      before(:each) do
        @check_deposit.pick_all_checks(@sector)
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

  describe "l'action de sauver"  do

    before(:each) do
      # attention pose un problème si
      date = @p.start_date + 2
      @check_deposit = @ba.check_deposits.new(deposit_date: date)
      @check_deposit.user_ip = '127.0.0.1'
      @check_deposit.written_by = 3
      @check_deposit.pick_all_checks(@sector)
      @check_deposit.save!
    end


    describe 'crée une écriture'  do

      it 'a une écriture' do
        @check_deposit.check_deposit_writing.should be_an_instance_of(CheckDepositWriting)
      end

      it 'dont les champs written_by et uesr_ip sont remplis' do
        cdw = @check_deposit.check_deposit_writing
        cdw.written_by.should == @check_deposit.written_by
        cdw.user_ip.should == @check_deposit.user_ip
      end

      it 'avec une ligne au credit du 511'  do
        cl = @check_deposit.credit_line
        cl.date.should == @check_deposit.deposit_date
        cl.account.number.should == REM_CHECK_ACCOUNT[:number]
        cl.credit.should == @check_deposit.total_checks

      end

      it 'et une ligne au débit de la banque' do
        dl = @check_deposit.debit_line
        dl.date.should == @check_deposit.deposit_date
        dl.account.should == @check_deposit.bank_account.current_account(@p)
        dl.debit.should == @check_deposit.total_checks
      end



    end

    it 'met à jour le champ check_deposit_id des lignes relevant du compte 511'  do
      @check_deposit.total_checks.should == 445
      ls = ComptaLine.where('account_id = ?', @p.rem_check_account.id)
      ls.size.should == 4 # les 3 chèques plus la contrepartie
      ls.each {|l|  l.check_deposit_id.should == @check_deposit.id }

    end

    it 'du coup, le compte de remise de chèque est soldé puisqu on a pris tous les chèques' do
      @p.rem_check_account.sold_at(@p.close_date).should == 0
    end



    describe 'edition' do

      it 'enlever un chèque modifie le montant total de la remise'  do
        l2 = @w2.children.last
        @check_deposit.checks.delete(l2)
        @check_deposit.total_checks.should == 344
        @check_deposit.save!
        # TODO vérifier la modif sur les lignes débit crédit

      end

      it 'after_update met à jour le montant des compta_lines'  do
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


      it 'after_update met à jour la date de la writing' do
        @check_deposit.check_deposit_writing.date.should == (@p.start_date + 2)
        @check_deposit.deposit_date  =  Date.today
        @check_deposit.should be_valid
        @check_deposit.save
        @check_deposit.check_deposit_writing.date.should == Date.today
      end

      describe 'avec deux banques', wip:true do

        before(:each) do
          # crée une deuxième banque
           @ba2 = @o.bank_accounts.new(bank_name:'CMNE', number:'8887',
             nickname:'Livret', sector_id:1)
           puts @ba2.errors.messages if @ba2.errors.any?
           @ba2.save!
        end

        after(:each) do
          # détruit cette deuxième banque
          @ba2.destroy
        end

        it 'after_update met à jour la banque de la compta_line débitée', wip:true do
          @check_deposit.bank_account_id = @ba2.id
          @check_deposit.save!
          @check_deposit.debit_line.account_id.should == @ba2.current_account(@p).id
        end

      end

      it "on peut changer le compte bancaire" do
        @check_deposit.bank_account_id = 9999
        @check_deposit.should be_valid
      end

    end

    describe 'destruction' do


      it 'on peut détruire la remise'  do
        expect {@check_deposit.destroy}.to change{CheckDeposit.count}.by(-1)
      end

      it 'lorsqu on détruit la remise les lignes sont mises à jour'do
        # CheckDeposit.pending_checks.each {|c| puts c.inspect}
        CheckDeposit.nb_to_pick.should == 0
        @check_deposit.destroy
        CheckDeposit.nb_to_pick.should == 3
      end

      it 'l ecriture est détruite'   do
        expect {@check_deposit.destroy}.to change {ComptaLine.count}.by(-2)
      end

    end



    describe "le rattachement à un extrait de compte" do
      before(:each) do
        @check_deposit.should have(3).checks
        @be = @ba.bank_extracts.create!(:end_date=>((Date.today) +15),
           :begin_date=>((Date.today) -15))
        @bel = @be.bank_extract_lines.create!(:compta_line_id=>@check_deposit.debit_line.id)

      end

      it 'fait que la remise de chèque est pointée' do
        @check_deposit.should be_pointed
      end


      it "que la date ne peut plus être modifiée" do
        @check_deposit.deposit_date = Date.today+6
        @check_deposit.should_not be_valid
      end

      it "que la banque ne peut plus être modifiée" do
        @check_deposit.bank_account = find_second_bank
        @check_deposit.should_not be_valid
      end

      it "la remise de chèque ne peut plus être détruite" do
        pending 'ne crée pas d erreur car les cheques sont retirés par nullify avant le test'
#        puts @check_deposit.pointed?.inspect
#        puts @check_deposit.debit_compta_line.inspect
        # @check_deposit.destroy
        expect {@check_deposit.destroy}.to raise_error
      end

      it "on ne peut plus retirer de chèque" do
        expect {@check_deposit.checks.delete(@w2.supportline)}.to raise_error
      end

      it "ni en ajouter" do
        @w5 = create_in_out_writing(44, 'Chèque')
        expect {@check_deposit.checks << @w5.supportline}.to raise_error

      end

    end # fin du rattachement à un extrait de compte
  end





end

