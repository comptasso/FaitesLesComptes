# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PeriodsController do

  context 'testing with 3 periods how to change form one to another period' do

  before(:each) do  
    
    Period.count.should == 0
    @organism= Organism.create!(title: 'nouveTest Asso') 
    @p_2010= @organism.periods.create(start_date: Date.civil(2010,04,01), close_date: Date.civil(2010,12,31))
    Period.count.should == 1
      @p_2010.close   
    @p_2010.should be_is_closed
    @p_2011= @organism.periods.create(start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31))
     Period.count.should == 2
    @p_2012= @organism.periods.create(start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))
    Period.count.should == 3 
   
  end

  describe 'GET next' do

  # HTTP_REFERER sert à résourdre la question du lien vers back


  it "should select 2011 if 2010"  do
    request.env["HTTP_REFERER"]=organisms_url
    get :change, :organism_id=>@organism.id, :id=>@p_2011.id
    session[:period].should == @p_2011.id
  end

   it "should select 2012 if 2011"  do
    request.env["HTTP_REFERER"]=organisms_url
    get :change, :organism_id=>@organism.id, :id=>@p_2012.id
    session[:period].should == @p_2012.id
      end
 

      it "should select 2012 if 2012"  do
        request.env["HTTP_REFERER"]=organisms_url
    get :change, :organism_id=>@organism.id, :id=>@p_2010.id
    session[:period].should == @p_2010.id
  end
end
  end
end

