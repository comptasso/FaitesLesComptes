# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::Listing do

     before(:each) do
    @o=Organism.create!(title:'test balance sans table')
    @p= Period.create!(organism_id:@o.id, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
    @a1 = @p.accounts.create!(number:'60', title:'compte 1')


    @listing = Compta::Listing.new
  end

  it "has a virtual attribute date_from_picker et et date_do_picker" do
    @listing.from_date_picker =  '01/01/2012'
    @listing.from_date.should == Date.civil(2012,1,1)
    @listing.to_date_picker =  '01/01/2012'
    @listing.to_date.should == Date.civil(2012,1,1)
  end

  it 'should have a period_id' do
    @listing.valid?
    @listing.should have(1).errors_on(:period_id)
  end

   context 'testing methods and validations' do
      def valid_arguments
      { period_id:@p.id,
        from_date:Date.today.beginning_of_month,
        to_date:Date.today.end_of_month,
        account_id:@a1.id,
      }
    end

      before(:each) do
      @l=Compta::Listing.new(valid_arguments)
    end

    describe 'methods' do
       it 'should retrieve period' do
        @l.period_id.should == @p.id
        @l.period.should == @p
      end

        it 'lines returns a array of lines' do
          @l.lines.should be_an(ActiveRecord::Relation)
        end

        it 'call lines fills different soldes' do
          @l.solde_debit_avant.should == 0
          @l.solde_credit_avant.should == 0
        end

    end

   end

end

