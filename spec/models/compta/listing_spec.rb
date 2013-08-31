# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::Listing do

   def double_compta_line(i)
     double(ComptaLine,
       date:(Date.today-1),
       narration:"Lignen° #{i}",
       ref:'',
       book:double(title:'Recettes'),
       nature_name:'nature',
       destination_name:'dest',
       debit:i,
       credit:0)
   end



   before(:each) do
    @p = mock_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year )
    @a1 = mock_model(Account, :period=>@p, :period_id=>@p.id)
    @a1.stub_chain(:compta_lines, :listing).and_return
    @listing = Compta::Listing.new 
  end

  it "has a virtual attribute date_from_picker et et date_do_picker" do
    @listing.from_date_picker =  '01/01/2012'
    @listing.from_date.should == Date.civil(2012,1,1)
    @listing.to_date_picker =  '01/01/2012'
    @listing.to_date.should == Date.civil(2012,1,1)
  end

  it 'should have a account_id' do
    @listing.valid?
    @listing.should have(1).errors_on(:account_id)
  end

  it 'test de date hors de la période' do
    @listing.from_date_picker = '01/01/2011'
     @listing.to_date_picker =  '31/12/2012'
     @listing.account_id = @a1.id
     @listing.should have(1).errors_on(:from_date)
     
  end

   context 'testing methods and validations' do
      def valid_arguments
      { 
        from_date:Date.today.beginning_of_month,
        to_date:Date.today.end_of_month,
        account_id:@a1.id
      }
    end

      before(:each) do
      @l = Compta::Listing.new(valid_arguments)
      @l.stub(:account).and_return @a1
    end

    describe 'methods' do
       it 'should retrieve period' do
         @l.period.should == @p
      end

        it 'lines returns a array of lines' do
          @a1.stub_chain(:compta_lines, :listing).and_return(ar = double(Arel))
          @l.lines.should == ar
        end

        it 'with_default_values renvoie @l après avoir mis les dates par defaut' do

          listing1 =  Compta::Listing.new(:account_id=>@a1.id)
          listing1.stub(:account).and_return @a1
          listing1.with_default_values
          listing1.from_date.should == Date.today.beginning_of_year
          listing1.to_date.should == Date.today.end_of_year
        end

        it 'connait son solde de départ débit' do
          @l.should_receive(:cumulated_debit_before).with(@l.from_date).and_return 256
          @l.solde_debit_avant.should == 256
        end

         it 'connait son solde de départ credit' do
          @l.should_receive(:cumulated_credit_before).with(@l.from_date).and_return -16256
          @l.solde_credit_avant.should == -16256
        end

        it 'total debit reprend les mouvements de débit' do
          @l.should_receive(:movement).with(@l.from_date, @l.to_date, 'debit').and_return 27.56
          @l.total_debit.should == 27.56
        end

         it 'total credit reprend les mouvements de credit' do
          @l.should_receive(:movement).with(@l.from_date, @l.to_date, 'credit').and_return 277777.56
          @l.total_credit.should == 277777.56
        end

        it 'sait produire un csv' do
          @l.stub(:solde_debit_avant).and_return 0
          @l.stub(:solde_credit_avant).and_return 0
          @l.stub(:total_debit).and_return 27
          @l.stub(:total_credit).and_return 568
          @l.stub(:lines).and_return(1.upto(45).collect {|i| double_compta_line(i)  })
          @l.to_csv.should be_a String
          
        end

  

    end

   end

end

