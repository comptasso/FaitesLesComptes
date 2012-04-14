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


end
