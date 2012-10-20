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
    @b = mock_model(Book, :organism=>@o, :type=>'IncomeBook')
    @o.stub(:find_period).and_return true
    Writing.any_instance.stub_chain(:compta_lines, :size).and_return 2
    Writing.any_instance.stub(:complete_lines).and_return true
  end

  def valid_parameters
    {book_id:@b.id, narration:'Première écriture', date:Date.today, book:@b}
  end

  

  describe 'basic validator' do

    before(:each) do
       Writing.any_instance.stub(:total_credit).and_return 10
       Writing.any_instance.stub(:total_debit).and_return 10
       Writing.any_instance.stub(:book).and_return @b
       
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
    end

    it 'doit être valide' do
      @w.valid?
      @w.should be_valid
    end

    it 'ne doit pas être équilibrée' do
      @w.stub(:total_debit).and_return(10)
      @w.stub(:total_credit).and_return(20)
      @w.should_not be_valid
    end

    it 'doit être équilibrée' do
      @w.stub(:total_debit).and_return(10)
      @w.stub(:total_credit).and_return(10)
      @w.should be_valid
    end



    it 'ne doit pas être vide' do
      @w.stub_chain(:compta_lines, :size).and_return 1
      @w.should_not be_valid
    end

    it 'la date doit être dans l exercice' do
      @o.should_receive(:find_period).with(@w.date).and_return nil
      @w.should_not be_valid
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

    it 'lock' , wip:true do
      @w.save!
      @w.lock
      @w.compta_lines.all.each {|l| l.should be_locked}
      @w.should be_locked
    end

    it 'locked? est vrai si une ligne est verrouillée'

    it 'lock doit verrouiller toutes les lignes'




  end
end

end
