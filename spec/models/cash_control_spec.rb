# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


RSpec.configure do |c|
  # c.filter = {:wip => true }
  #  c.exclusion_filter = {:js=> true }
end

describe CashControl do 
  include OrganismFixture

  before(:each) do
    create_minimal_organism
    @cash_control = @c.cash_controls.new(date: Date.today, amount: 123.45)
  end

  
  context 'test constraints' do
    
    it "should be valid" do
      @cash_control.should be_valid
    end

    it 'not valid without date' do
      @cash_control.date = nil
      @cash_control.should_not be_valid
    end

    it 'not valid if date before min_date' do
      @cash_control.date = @cash_control.min_date - 1
      @cash_control.should_not be_valid
    end

     it 'not valid if date after max_date' do
      @cash_control.date = @cash_control.max_date + 1.day
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
        laps = Date.today - @p.start_date
        10.times { @c.cash_controls.create(date: (@p.start_date + rand(laps).days), amount: rand(1000)) }
      end

      it 'mois should get all Lines within specified month' do
        debut = @p.start_date.months_since(2)
        fin= debut.end_of_month
        @c.cash_controls.mois(@p, 2).each do |ccc|
          ccc.date.should <= fin
          ccc.date.should >= debut
        end
      end

      it 'cash_controls order date' , wip:true do
        @c.cash_controls.create(date:Date.today, amount:0)
        @c.cash_controls.create(date:(Date.today - 1), amount:0)
        @c.cash_controls.create(date:(Date.today + 1), amount:0)
        my = MonthYear.from_date(Date.today)
        ccs = @c.cash_controls.monthyear(my).all
        ccs.each_with_index do |cc, i|
          cc.date.should <= ccs[i+1].date if ccs[i+1]
        end
      end

      context 'with two periods and 7 cash_controls for @p2' do

        before(:each) do
          # création d'un deuxième exercice
          start_date = @o.periods.last.close_date + 1.day
          close_date = start_date.end_of_year
          @p2 = @o.periods.create!(start_date: start_date, close_date: close_date)
          # on fait sauter la limite max_date = Date.today pour pouvoir créer des cash controls
          # qui sont dans le futur
          CashControl.any_instance.stub(:max_date).and_return(@p2.close_date)
          7.times { @c.cash_controls.create(date: (@p2.start_date + rand(365)), amount: rand(1000)) }
        end

        it 'for_period returns cash_controls within this period' do
          @c.cash_controls.for_period(@p).should have(10).cash_controls
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
    
    describe 'period' do

      it 'should knows its period' do
      @cash_control.send(:period).should == @p
      end
    end

    describe 'difference' do
      it 'difference revnoie l ecart entre le contrôle et la valeur de la caisse' do
        @cash_control.difference.should == @cash_control.amount - @c.sold_at(@cash_control.date)
      end
    end

    describe 'min_ and max_date' do 

      it 'la date est le début de l exercice' do
        @cash_control.min_date.should == @p.start_date
      end

      it '@max_date doit être la fin de l exercice ou la date du jour' do
        @cash_control.max_date.should == Date.today
      end

      it '@max_date doit être la fin de l exercice ou la date du jour' do
        @cash_control.max_date.should == Date.today
      end

    end

    describe 'previous' do

      it 'returns the previous cash_control' do
        previous_cash_control = @c.cash_controls.create!(date: Date.today - 1.day, amount: 1)
        @cash_control.previous.should == previous_cash_control
      end
      
      it 'but nil if no previous cash_control' do
        @cash_control.previous.should be_nil
      end

      it 'a new cash_control also knows the previous one' do
        previous_cash_control = @c.cash_controls.create!(date: Date.today - 2.day, amount: 1)
        @c.cash_controls.new(date: Date.today - 1.day).previous.should == previous_cash_control
      end

      it 'if it has a date, nil otherwise' do
       @c.cash_controls.new.previous.should be_nil
      end
    end

    describe 'lock_lines' do

      before(:each) do
        date = @p.start_date
        # on créé une ligne d'écriture par mois relevant de la caisse
        @p.nb_months.times do |i|
          d = date.months_since(i)
         Line.create!(narration: "test #{i}", counter_account:@c.current_account(@p),  debit: i+1, payment_mode: 'Espèces',
            nature_id: @n.id, book_id: @ob.id, line_date:d ,
          cash_id: @c.id)
        end
        # création de lignes
      end

      it 'lock cash_control locked lines anterior to cash_control' do
        Line.where('locked IS ?', false).should have(24).elements
        @cash_control.locked = true
        @cash_control.save
        Line.where('locked IS ?', false).should have(24 - 2*@cash_control.date.month).elements
      end

      
    end

  end

 

end

