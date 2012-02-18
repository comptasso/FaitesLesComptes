# To change this template, choose Tools | Templates
# and open the template in the editor.

# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Period do

  before(:each) do
      @organism= Organism.create(title: 'test asso')
      @p_2010 = @organism.periods.create!(start_date: Date.civil(2010,04,01), close_date: Date.civil(2010,12,31))
      @p_2011= @organism.periods.create!(start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31))
      @organism.periods.count.should == 2
    end

  context "avec  2 exercices" do
    
    it 'should respond is_closed when closed' do
      @p_2010.is_closed?.should be_false
      @p_2010.closable? #.should be_true
      @p_2010.errors[:close].should == [] 
      @p_2010.close
      @p_2010.is_closed?.should be_true
    end
  end

  context "avec un troisieme exercice" do
    before(:each) do
      @p_2010.close # il faut fermer 2010 pour pouvoir créer 2012
      @p_2012= @organism.periods.create!(start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))
      @organism.periods.count.should == 3
    end

    describe 'period_next' do
      it "2010 doit repondre 2011" do
        @p_2010.next_period.should == @p_2011
      end
  
      it "2011 doit repondre 2012" do
        @p_2011.next_period.should == @p_2012
      end
      it "2012, le dernier doit repondre lui meme" do
        @p_2012.next_period == @p_2012
      end
    end
  end

  # result est un module qui est destiné à produire les résultats mensuels d'un exercice
  describe "resultat" do
      it "a period can produce a result for each_month" do
        @p_2011.monthly_results.should be_an_instance_of(Array)
        @p_2011.monthly_results.size.should == @p_2011.nb_months
        @p_2010.monthly_results.size.should == @p_2010.nb_months
      end

      it "without datas, a period can produce a monthly result" do
        @p_2010.monthly_result(3).should be(0)
      end

    context 'the result is calculated from books' do
      def feed_datas(period, factor)
         period.nb_months.times.map {|t| {'Month'=>"#{format('%02d',t)}", 'total_month'=> factor*t } }
      end

      before(:each) do
        @recettes= @organism.income_books.first
        @depenses=@organism.outcome_books.first
        @recettes.stub(:monthly_datas).with(@p_2011).and_return(feed_datas(@p_2011, 10))
        @depenses.stub(:monthly_datas).with(@p_2011).and_return(feed_datas(@p_2011, 5))

      end

      it "check the monthly result" do
        @p_2011.monthly_result(3).should == 20 
      end

    end
  end
 
end
