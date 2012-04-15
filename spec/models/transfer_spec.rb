require 'spec_helper'

describe Transfer do

  def valid_attributes
    {}
  end

  context 'virtual attribute pick date' do
  
    before(:each) do
      @transfer=Transfer.new(valid_attributes)
    end
    
    it "should store date for a valid pick_date" do
      
      @transfer.pick_date = '06/06/1955'
      @transfer.date.should == Date.civil(1955,6,6)
   end

    it 'should return formatted date' do
      @transfer.date =  Date.civil(1955,6,6)
      @transfer.pick_date.should == '06/06/1955'
    end
 
  end

  describe 'virtual attribute fill_debitable' do

     before(:each) do
      @transfer=Transfer.new(:debitable_type=>'Model', :debitable_id=>'9')
    end
    

    it 'fill_debitable = ' do
      @transfer.fill_debitable=('Model_6')
      @transfer.debitable_id.should == 6
      @transfer.debitable_type.should == 'Model'
    end

    it 'debitable concat type and id' do
      @transfer.fill_debitable.should == 'Model_9'
    end

  end
describe 'virtual attribute creditable' do

     before(:each) do
      @transfer=Transfer.new(:creditable_type=>'Model', :creditable_id=>'9')
    end


    it 'fill_creditable = ' do
      @transfer.fill_creditable= 'Model_6'
      @transfer.creditable_id.should == 6
      @transfer.creditable_type.should == 'Model'
    end

    it 'fill_creditable concat type and id' do
      @transfer.fill_creditable.should == 'Model_9'
    end

  end


end
