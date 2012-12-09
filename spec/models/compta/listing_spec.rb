# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::Listing do
include OrganismFixture
     before(:each) do
    create_organism
    @p= Period.create!(organism_id:@o.id, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
    @a1 = @p.accounts.find_by_number('60') 


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
        account_id:@a1.id,
      }
    end

      before(:each) do
      @l=Compta::Listing.new(valid_arguments)
    end

    describe 'methods' do
       it 'should retrieve period' do
         @l.period.should == @p
      end

        it 'lines returns a array of lines' do
          @l.lines.should be_an(ActiveRecord::Relation)
        end

  

    end

   end

end

