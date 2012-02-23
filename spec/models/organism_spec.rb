# To change this template, choose Tools | Templates
# and open the template in the editor.

# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organism do
   before(:each) do
      @organism= Organism.create(title: 'test asso')
      @p_2010 = @organism.periods.create!(start_date: Date.civil(2010,04,01), close_date: Date.civil(2010,12,31))
      @p_2011= @organism.periods.create!(start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31))
      @organism.periods.count.should == 2
    end

  it "doit trouver l'exercice avec une date" do
    @organism.find_period(Date.civil(2010,5,15)).should == @p_2010
    @organism.find_period(Date.civil(2011,6,15)).should == @p_2011
    @organism.find_period(Date.civil(1990,5,15)).should == nil
    
  end
end

