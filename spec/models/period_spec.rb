# To change this template, choose Tools | Templates
# and open the template in the editor.

# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Period do

  context "avec 3 exercices" do
    before(:each) do
      @organism= Organism.create(title: 'Test Asso')
      @p_2010= @organism.periods.create(start_date: Date.civil(2010,04,01), close_date: Date.civil(2010,12,31))
      @p_2010.close
      @p_2011= @organism.periods.create(start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31))
      @p_2012= @organism.periods.create(start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))

      Period.count.should == 3
    end

    describe 'period_next' do
      it "2010 doit repondre 2011" do
        @p_2010.next_period.should == @p_2011
      end
  
      it "2011 doit repondre 2012" do
        @p_2011.next_period.should == @p_2012
      end
      it "2012, le dernier doit repondre lui meme" do
        expect @p_2012.next_period == nil
      end
    end
  end

end
