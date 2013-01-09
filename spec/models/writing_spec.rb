# coding: utf-8

require 'spec_helper'

RSpec.configure do |config|
   # config.filter = {wip:true}
end

describe Writing do
  include OrganismFixture 

  describe 'with stub models' do

  before(:each) do 
    @o = mock_model(Organism) 
    @p = mock_model(Period)
    @b = mock_model(Book, :organism=>@o, :type=>'IncomeBook')
    @o.stub(:find_period).and_return @p
    Writing.any_instance.stub_chain(:compta_lines, :size).and_return 2
    Writing.any_instance.stub(:complete_lines).and_return true
  end

  def valid_parameters
    {book_id:@b.id, narration:'Première écriture', date:Date.today, book:@b}
  end

  

  describe 'presence validator' do

    before(:each) do
       Writing.any_instance.stub(:total_credit).and_return 10
       Writing.any_instance.stub(:total_debit).and_return 10
       Writing.any_instance.stub(:book).and_return @b
       Writing.any_instance.stub_chain(:compta_lines, :each).and_return nil
       
    end

    it 'champs obligatoires' do
      @w = Writing.new(valid_parameters)
      @w.should be_valid
      [:narration, :date, :book_id].each do |field|
        f_eq = (field.to_s + '=').to_sym
        @w = Writing.new(valid_parameters)
        @w.send(f_eq, nil)
        @w.should_not be_valid, "Paramètres obligatoire manquant : #{field}"
      end
    end
  end


  describe 'other validators' do

    before(:each) do
      @w = Writing.new(valid_parameters)
       Writing.any_instance.stub(:total_credit).and_return 10
       Writing.any_instance.stub(:total_debit).and_return 10
       Writing.any_instance.stub_chain(:compta_lines, :each).and_return nil
    end

    it 'doit être valide' do
      @w.valid?
      @w.should be_valid
    end

    it 'non valide si déséquilibrée' do
      @w.stub(:total_debit).and_return(10)
      @w.stub(:total_credit).and_return(20)
      @w.should_not be_valid
    end

    it 'et valide si équilibrée' do
      @w.stub(:total_debit).and_return(10)
      @w.stub(:total_credit).and_return(10)
      @w.should be_valid
    end

describe 'test des compta_lines' do

    it 'doit avoir au moins deux lignes' do
      @w.stub(:compta_lines).and_return([mock_model(ComptaLine, nature:mock_model(Nature, period:@p), account:mock_model(Account, period:@p))])
      @w.should_not be_valid
    end

    it 'la date doit être dans l exercice' do
      @o.should_receive(:find_period).with(@w.date).and_return nil
      @w.should_not be_valid
    end

    it 'valide si les natures sont dans l exercice' do
      @w.stub(:compta_lines).and_return([mock_model(ComptaLine, nature:mock_model(Nature, period:@p), account:mock_model(Account, period:@p)),
          mock_model(ComptaLine, nature:nil, account:mock_model(Account, period:@p))])
      @w.should be_valid
    end

    it 'et invalide dans le cas contraire' do
      @w.stub(:compta_lines).and_return([mock_model(ComptaLine, nature:mock_model(Nature, period:mock_model(Period)), account:mock_model(Account, period:@p)),
          mock_model(ComptaLine, nature:nil, account:mock_model(Account, period:@p))])
      @w.should_not be_valid
      @w.errors[:date].should == ['Incohérent avec Nature']
    end


      it 'invalide si les comptes ne sont pas dans l exercice' do
        @w.stub(:compta_lines).and_return([mock_model(ComptaLine, nature:mock_model(Nature, period:@p), account:mock_model(Account, period:mock_model(Period))),
          mock_model(ComptaLine, nature:nil, account:mock_model(Account, period:@p))])
      @w.should_not be_valid
      @w.errors[:date].should == ['Incohérent avec Compte']
      end

  end

  end

  end

context 'with real models' do

  describe 'save' do

  before(:each) do
    create_minimal_organism
    @l1 = ComptaLine.new(account_id:Account.first.id, debit:0, credit:10)
    @l2 = ComptaLine.new(account_id:Account.last.id, debit:10, credit:0)
    @r = @od.writings.new(date:Date.today, narration:'Une écriture')
    @r.compta_lines<< @l1
    @r.compta_lines<< @l2
  end

    it 'find period' do
      @r.book.organism.should == @o
      @r.should have(2).compta_lines
      @r.compta_lines.size.should == 2

    end

    it 'should save' do
      @r.valid?
      @r.should be_valid
      expect {@r.save}.to change {Writing.count}.by(1)
    end

    it 'should save the lines' do
      expect {@r.save}.to change {ComptaLine.count}.by(2)
    end


  end


    describe 'methods'  do

    before(:each) do
      create_minimal_organism
      @w = create_in_out_writing
     end
     it 'check compta_lines' do
       @w.compta_lines.should be_an(Array)
       @w.compta_lines.first.should be_an_instance_of(ComptaLine)
     end


    it 'total_debit, renvoie le total des debits des lignes' do
       @w.total_debit.should == 99
    end

    it 'total_credit, renvoie le total des debits des lignes' do
      @w.total_credit.should == 99
    end

    it 'balanced? répond false si les deux totaux sont inégaux' do
      @w.stub(:total_debit).and_return 145
      @w.should_not be_balanced

    end

     it 'et true s ils sont égaux' do
      @w.should be_balanced
    end

    it 'lock'  do
      @w.save!
      @w.lock
      @w.compta_lines.all.each {|l| l.should be_locked}
      @w.should be_locked
    end

    it 'locked? est faux si aucune ligne n est verrouillée' do
      @w.stub(:compta_lines).and_return(@a = double(Arel))
      @a.should_receive(:where).with('locked = ?', true).and_return @a
      @a.should_receive(:any?).and_return false
      @w.should_not be_locked
    end

    it 'locked? est vrai si une ligne est verrouillée' do
      @w.stub(:compta_lines).and_return(@a = double(Arel))
      @a.should_receive(:where).with('locked = ?', true).and_return @a
      @a.should_receive(:any?).and_return true
      @w.should be_locked

    end

    it 'lock doit verrouiller toutes les lignes' , wip:true do
      cls = [1,2].map {|i| mock_model(ComptaLine, locked?:false) }
      @w.stub(:compta_lines).and_return(cls)
      cls.each {|cl| cl.should_receive(:update_attribute).with(:locked, true).and_return(true)}
      @w.lock
      
    end




  end
end

end
