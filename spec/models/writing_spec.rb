# coding: utf-8

require 'spec_helper'

describe Writing do

  before(:each) do
    @o = mock_model(Organism)
    @b = mock_model(Book, :organism=>@o)
    @o.stub(:find_period).and_return true
    Writing.any_instance.stub_chain(:compta_lines, :count).and_return 2
   

  end

  def valid_parameters
    {book_id:@b.id, narration:'Première écriture', date:Date.today, book:@b}
  end

  

  describe 'basic validator' do

    before(:each) do
       Writing.any_instance.stub(:total_credit).and_return 10
       Writing.any_instance.stub(:total_debit).and_return 10
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
      @w.stub_chain(:compta_lines, :count).and_return 1
      @w.should_not be_valid
    end

    it 'la date doit être dans l exercice' do
      @o.should_receive(:find_period).with(@w.date).and_return nil
      @w.should_not be_valid
    end

  end

  describe 'methods' do

    before(:each) do
      @w = Writing.new(valid_parameters)
      @w.stub(:compta_lines).and_return(@a = double(Arel))
    end

    it 'total_debit, renvoie le total des debits des lignes' do
      @a.should_receive(:sum).with(:debit).and_return 145
      @w.total_debit.should == 145
    end

    it 'total_credit, renvoie le total des debits des lignes' do
      @a.should_receive(:sum).with(:credit).and_return 541
      @w.total_credit.should == 541
    end

    it 'balanced? répond false si les deux totaux sont inégaux' do
      @w.stub(:total_credit).and_return 541
      @w.stub(:total_debit).and_return 145
      @w.should_not be_balanced

    end

    it 'et true s ils sont égaux' do
      @w.stub(:total_credit).and_return 541
      @w.stub(:total_debit).and_return 541
      @w.should be_balanced
    end


  end



end
