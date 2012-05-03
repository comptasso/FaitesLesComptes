# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


RSpec.configure do |c|
  #  c.filter = {:wip => true }
  #  c.exclusion_filter = {:js=> true }
end

describe CashControl do
  include OrganismFixture

  before(:each) do
    create_minimal_organism
    @cash_control = @c.cash_controls.new(date: Date.today, amount: 123.45)
  end

  #  after(:all) do
  #    clean_test_database
  #  end

  
  context 'test constraints' do
    
    it "should be valid" do
      @cash_control.should be_valid
    end

    it 'not valid without date' do
      @cash_control.date = nil
      @cash_control.should_not be_valid
    end

  
    it "nor without amount" do
      @cash_control.amount = nil
      @cash_control.should_not be_valid
    end

    it "nor without cash_id" do
      @cash_control.cash_id = nil
      @cash_control.should_not be_valid
    end

    it 'amount is greater than 0' do
      @cash_control.amount = -45
      @cash_control.should_not be_valid
    end

  end

  describe 'testing scopes' do
    context 'with one period' do

      before(:each) do
        100.times { @c.cash_controls.create(date: (@p.start_date + rand(365)), amount: rand(1000)) }
      end

      it 'mois should get all Lines within specified month' do
        debut = @p.start_date.months_since(2)
        fin= debut.end_of_month
        @c.cash_controls.mois(@p, 2).each do |ccc|
          ccc.date.should <= fin
          ccc.date.should >= debut
        end
      end

      context 'with two periods and 7 cash_controls for @p2' do

        before(:each) do
          start_date = @o.periods.last.close_date + 1.day
          close_date = start_date.end_of_year
          @p2 = @o.periods.create!(start_date: start_date, close_date: close_date)
          7.times { @c.cash_controls.create(date: (@p2.start_date + rand(365)), amount: rand(1000)) }
        end

        it 'for_period returns cash_controls within this period' do
           @c.cash_controls.for_period(@p).should have(100).cash_controls
          @c.cash_controls.for_period(@p2).should have(7).cash_controls
        end
      end
    end
  end


  context 'with a saved cash_control' do
    before(:each) do
      @cash_control.save!
    end

    it 'lock cash control' do
      @cash_control.should_receive(:lock_lines)
      @cash_control.locked = true
      @cash_control.save!
    end

    it 'update another attribute should not lock_lines' do
      @cash_control.should_not_receive(:lock_lines)
      @cash_control.amount = 27
      @cash_control.save!
      
    end

    describe 'lock_lines' do

      before(:each) do
        date = @p.start_date
        # on créé une ligne d'écriture par mois relevant de la caisse
        @p.nb_months.times do |i|
         Line.create!(narration: "test #{i}", debit: i+1, payment_mode: 'Espèces',
            nature_id: @n.id, book_id: @ob.id, line_date: date.months_since(i),
          cash_id: @c.id)
        end
        # création de lignes
      end

      it 'lock cash_control locked lines' do

        Line.where('locked IS ?', false).should have(12).elements
        @cash_control.locked = true
        @cash_control.save
        Line.where('locked IS ?', false).should have(12 - @cash_control.date.month).elements
      end

    end

  end

 

end

