# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=> true }
end

describe BankAccount do
  include OrganismFixtureBis

  def valid_attributes
    {:bank_name=>'Crédit Universel', :number=>'1254LM',
      :nickname=>'Compte courant', sector_id:1, tenant_id:1}
  end

  def new_bank_account
    ba = BankAccount.new(valid_attributes)
    ba.organism_id = 1
    ba
  end

  def find_bac
    @bb = BankAccount.where('number =  ?', '1254LM').first
    @bb ||= new_bank_account
  end

  before(:each) do
    Tenant.set_current_tenant(1)
  end

  describe 'controle des validités' do

    subject {find_bac}

    it {subject.should be_valid}

    it 'should not be_valid without bank_name' do
      subject.bank_name = nil
      subject.should_not be_valid
    end

    it 'should not be_valid without number' do
      subject.number = nil
      subject.should_not be_valid
    end

    it 'nor without nickname' do
      subject.nickname = nil
      subject.should_not be_valid
    end

    it 'nor without sector_id' do
      subject.sector_id = nil
      subject.should_not be_valid
    end

    it "should have a unique number in the scope of bank and organism" do
      use_test_organism
      subject.organism_id = @o.id
      subject.number = @ba.number
      subject.bank_name = @ba.bank_name
      subject.should_not be_valid
    end

  end

  describe 'scope commun', wip:true do
    context 'sans secteur commun' do
      before(:each) do
        use_test_organism
      end

      it 'communs renvoie un tableau vide' do
        expect(BankAccount.communs.to_a).to eq([])
      end
    end

    context 'avec un secteur commun' do

      before(:each) do
        use_test_organism
        @sec = @o.sectors.create!(name:'Commun')
        @bc = @o.bank_accounts.create!(bank_name:'le compte commun', number:'12345XYZ',
          nickname:'compte commun', sector_id:@sec.id)
      end

      after(:each) do
        @bc.accounts.each(&:delete)
        @bc.delete
      end

      it 'communs renvoient les comptes bancaires du secteur commun' do
        expect(BankAccount.communs.to_a).to eq([@bc])
      end
      
      it 'sectored_and_communs renvoie les comptes des deux secteurs' , wip:true do
        sid = @o.sectors.first.id
        expect(BankAccount.sectored_and_communs(sid)).to eq([@ba, @bc])
      end
    end

  end

  describe 'création du compte comptable'  do

    before(:each) do
      use_test_organism
      @bb=@o.bank_accounts.new(valid_attributes)
    end

    after(:each) do
      @bb.accounts.each(&:delete)
      @bb.delete
    end

    it 'la création d un compte bancaire doit entraîner celle d un compte comptable' do
      puts @bb.errors.messages unless @bb.valid?
      expect {@bb.save!}.to change {Account.count}.by @o.periods.count
    end


    # TODO doit être testé dans Utilities Plan Comptable (comme pour Cash)
    it 'incrémente les numéros de compte' do
      pending 'A tester dans PlanComptable'
      numb = @ba.accounts.order(:number).last.number


      @bb.save

      @bb.accounts.first.number.should == numb.succ
    end



    it 'changer le nick_name du compte bancaire change le compte du compte comptable' do
      @ba.nickname = 'Un autre nom'
      @ba.save
      @ba.accounts.last.title.should == 'Un autre nom'
    end



    context 'avec deux exercices' do

      before(:each) do
        @p2 = find_second_period
      end

      it 'créer un nouvel exercice recopie le compte correspondant au compte bancaire' do
        @ba.accounts.count.should == 2
        @ba.accounts.last.number.should == @ba.accounts.first.number
      end

      it 'répond à current_account' do
        @ba.current_account(@p2).period.should == @p2
        @ba.current_account(@p).period.should == @p
      end

    end
  end

  describe 'Les méthodes liées aux lignes non pointées' do

    before(:each) do
      @ba = new_bank_account
    end

    it 'np_lines demande à compta_lines ses lignes non pointées' do
      @ba.should_receive(:compta_lines).and_return(@ar = double(Arel))
      @ar.should_receive(:not_pointed)
      @ba.np_lines
    end

  end

  describe 'new_bank_extract'  do

    before(:each) do
      use_test_organism
    end

    context 'without any bank extract' do

      it 'new_bank_extract returns a bank_extract'  do
        @ba.new_bank_extract(@p).should be_an_instance_of(BankExtract)
      end

      it 'a new bank_extract is prefilled with date and a zero sold' do
        @be = @ba.new_bank_extract(@p)
        @be.begin_sold.should == 0
        @be.begin_date.should == @p.start_date
        @be.end_date.should == @be.begin_date.end_of_month
      end

    end

    context 'with no bank_extract for this period but a previous period' do

      # le premier appel de bank_extract est pour  l'exercice en cours
      # et le second pour l'exercice précédent

      before(:each) do
        @p.stub(:previous_period?).and_return true
        @p.stub(:previous_period).and_return(@pp = mock_model(Period))

      end

      it 'begin_sold est rempli avec le dernier relevé de l exercice precedent' do

        @ba.stub(:last_bank_extract).and_return(nil,
          double(BankExtract, end_sold:123))
        @be = @ba.new_bank_extract(@p)
        @be.begin_sold.should == 123
      end

      it 'ou zero s il n existe pas' do

        @ba.stub(:last_bank_extract).and_return(nil, nil)
        @be = @ba.new_bank_extract(@p)
        @be.begin_sold.should == 0
      end

    end

    context 'with already some bank_extract' do
      before(:each) do
        @last_bank_extract = mock_model(BankExtract,
          :end_date => ((Date.today.beginning_of_month) -1.day),
          :end_sold => 123.45)
      end

      it 'a new bank_extract is prefilled with infos coming from last bank_extract'  do
        @ba.stub(:last_bank_extract).and_return @last_bank_extract
        @be = @ba.new_bank_extract(@p)
        @be.begin_sold.should == @last_bank_extract.end_sold
        @be.begin_date.should == (@last_bank_extract.end_date + 1.day)
        @be.end_date.should == @be.begin_date.end_of_month
      end

    end

    it 'new_bank_extract return nil si on est déja à la fin de l exercice' do
      @last_bank_extract = mock_model(BankExtract, :end_date=>Date.today.end_of_year, :end_sold=>3.14)
      @ba.stub(:last_bank_extract).and_return @last_bank_extract
      @ba.new_bank_extract(@p).should be_nil
    end

  end


end

