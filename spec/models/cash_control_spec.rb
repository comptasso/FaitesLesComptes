# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


RSpec.configure do |c| 
  #  c.filter = {:wip => true }
  #  c.exclusion_filter = {:js=> true } 
end

describe CashControl do   
  include OrganismFixtureBis

  before(:each) do
    use_test_organism
    @cash_control = @c.cash_controls.new(date: Date.today, amount: 123.45)
  end
  
  after(:each) {CashControl.delete_all}

  
  context 'test constraints' do
    
    it "should be valid" do
      @cash_control.should be_valid
    end

    it 'not valid without date' do
      @cash_control.date = nil
      @cash_control.should_not be_valid
    end

    it 'not valid if date before min_date' do
      @cash_control.date = @cash_control.min_date(@p) - 1
      @cash_control.should_not be_valid
    end

    it 'not valid if date after max_date' do
      @cash_control.date = @cash_control.max_date(@p) + 1.day
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

      
      it 'cash_controls order date' , wip:true do
        @c.cash_controls.create(date:Date.today, amount:0)
        @c.cash_controls.create(date:(Date.today - 1), amount:0)
        @c.cash_controls.create(date:(Date.today + 1), amount:0)
        my = MonthYear.from_date(Date.today)
        ccs = @c.cash_controls.monthyear(my).load
        ccs.each_with_index do |cc, i|
          cc.date.should <= ccs[i+1].date if ccs[i+1]
        end
      end

      context 'with two periods and 7 cash_controls for @p2' do

        before(:each) do
          @p2 = find_second_period
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

    describe 'difference'  do
      it 'difference revnoie l ecart entre le contrôle et la valeur de la caisse' do
        @cash_control.should_receive(:cash_sold).and_return 10
        @cash_control.difference.should == (@cash_control.amount - 10)
      end

      it 'different? renvoie un boolean' do
        @cash_control.should_receive(:difference).and_return 0
        @cash_control.should_not be_different
        @cash_control.should_receive(:difference).and_return 0.004
        @cash_control.should be_different
      end
    end

    describe 'min_ and max_date' do 

      it 'la date est le début de l exercice' do
        @cash_control.min_date(@p).should == @p.start_date
      end

      it '@max_date doit être la fin de l exercice ou la date du jour' do
        @cash_control.max_date(@p).should == Date.today
      end

      it '@max_date doit être la fin de l exercice si la date du jour est postérieure à l exercice' do
        eve = Date.civil(1999,12,31)
        p = mock_model(Period, :close_date=>eve)
        @cash_control.max_date(p).should == eve
      end

    end

    describe 'previous' do
      
      

      it 'returns the previous cash_control' do
        previous_cash_control = @c.cash_controls.create!(date: Date.today - 1.day, amount: 1)
        @cash_control.previous.should == previous_cash_control
        previous_cash_control.delete
      end
      
      it 'but nil if no previous cash_control' do
        @cash_control.previous.should be_nil
      end

      it 'a new cash_control also knows the previous one' do
        @c.cash_controls.new(date:Date.today).previous.should == @cash_control
        
      end

      it 'if it has a date, nil otherwise' do
        @c.cash_controls.new.previous.should be_nil
      end
    end

    describe 'lock_lines' do

      before(:each) do
        Writing.delete_all
        ComptaLine.delete_all
        date = @p.start_date
        @income_account = @p.accounts.classe_7.first
        # on créé une ligne d'écriture par mois relevant de la caisse
        @p.nb_months.times do |i|
          d = date.months_since(i)
          @ib.in_out_writings.create!({date:d,
              piece_number:12, narration:"test #{i}",
              :compta_lines_attributes=>{'0'=>{account_id:@income_account.id, nature:@n, debit:i+1, payment_mode:'Espèces'},
                '1'=>{account_id:@caca.id, credit:i+1, payment_mode:'Espèces'} } })
        end
      end
      
      after(:each) do 
        Writing.delete_all
        ComptaLine.delete_all 
      end 

      it 'vérification de la recherche des lignes à verrouiller' do
        @cash_control.cash.compta_lines.count.should == @p.nb_months
        @cash_control.cash.compta_lines.before_including_day(Date.today).should have(Date.today.month).elements
      end

      it 'lock cash_control locked lines anterior to cash_control'  do 
        ComptaLine.where('locked = ?', false).should have(24).elements
        @cash_control.locked = true
        @cash_control.save
        ComptaLine.where('locked = ?', false).should have(24 - 2*@cash_control.date.month).elements
      end

      
    end

  end

 

end

