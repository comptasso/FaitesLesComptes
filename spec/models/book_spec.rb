# coding: utf-8

# To change this template, choose Tools | Templates
# and open the template in the editor.



require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Book do

  def datas2010
    (1..12).map {|t| 2010 } #(t%3 == 0) ? 100+t*10 : 100-t*5 }
  end

  def datas2011
     (1..12).map {|t| 2011} #(t%2 == 0) ? 100+t*10 : 100-t*5 }
  end

  context "un exercice de 12 mois commencant le 1er janvier" do
    let(:p2010) {stub_model(Period, :start_date=>Date.civil(2010,01,01), :close_date=>Date.civil(2010,12,31))}

    before(:each) do
      @book = Book.new
    end

    it "should have a ticks method with argument period" do 
      @book.ticks(p2010).should be_an(Array)
# TODO contoler la qualité des ticks
    end
   
    # deux exercices de 12 mois commençant en janvier chacun
    context "testing monthly_graphic with two periods of the same length" do

      let(:p2011) {stub_model(Period, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))}

 
      before(:each) do
        p2011.stub(:previous_period).and_return(p2010)
        @book.stub(:monthly_datas_for_chart).with(p2011.list_months('%m-%Y')).and_return(datas2011)
        @book.stub(:previous_year_monthly_datas_for_chart).with(p2011.list_months('%m-%Y')).and_return(datas2010)
      end

      it "should have a two_years_monthly_graphic method" do
        @book.two_years_monthly_graphic(p2011)
      end

      it "check previous_year_monthly..." do
        @book.previous_year_monthly_datas_for_chart(p2011.list_months('%m-%Y')).should == datas2010
      end

      context "check the two_years_monthly_graphic method" do
        before(:each) { @graphic=@book.two_years_monthly_graphic(p2011)}

        it "monthly_graphic has a two series and ticks coming from period" do
          @graphic.legend.should ==['Exercice 2010', 'Exercice 2011']
        end

        it "monthly_graphic should have two series of datas" do
          @graphic.nb_series.should == 2
        end

        it "verfi de graphic" do
          puts @graphic.inspect
        end

        it "second datas serie is equal to datas build from period" do
          @graphic.series[0].should == datas2010
        end
        it "first datas serie is equal to datas build from period" do
          @graphic.series[1].should == datas2011
        end

      end
    end
  end

  context "deux exercices de 12 mois décalés" do
    

    def period_datas
      (4..12).map {|t|  t}   +  (1..3).map {|t| t  }
    end

    let(:p1) {stub_model(Period, :start_date=>Date.civil(2010,04,01), :close_date=>Date.civil(2011,03,31))}
    let(:p2) {stub_model(Period, :start_date=>Date.civil(2011,04,01), :close_date=>Date.civil(2012,03,31))}

    before(:each) do
      @book = Book.new
     @book.stub(:monthly_datas_for_chart).with(p2.list_months('%m-%Y')).and_return(period_datas)
        @book.stub(:previous_year_monthly_datas_for_chart).with(p2.list_months('%m-%Y')).and_return(period_datas)
      @graphic=@book.two_years_monthly_graphic(p2)
    end

    it "each serie should be 4,5,6,7 to 12 then 1,2,3" do
      @graphic.series[0].should == [4,5,6,7,8,9,10,11,12,1,2,3]
      @graphic.series[1].should == [4,5,6,7,8,9,10,11,12,1,2,3]
    end
  
  end

 describe "default_graphic" do
     
    def range_period_datas(range)
      range.map {|t|  2*t  }
    end


    let(:p1) {stub_model(Period, :start_date=>Date.civil(2009,9,01), :close_date=>Date.civil(2010,12,31))} # exercice de 15 mois,
    let(:p2) {stub_model(Period, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))} # exercice de 12 mois
    before(:each) do
      @book = Book.new
     
      @book.stub(:monthly_datas_for_chart).with(p2.list_months('%m-%Y')).and_return(range_period_datas(1..12))
      @book.stub(:previous_year_monthly_datas_for_chart).with(p2.list_months('%m-%Y')).and_return(range_period_datas(1..12))

    end

        context "when there are two periods" do
          before(:each) do
            p2.stub(:previous_period).and_return(p1)
            @book.stub_chain(:organism, :periods).and_return([p1,p2])
          end
        

       it "build a two_years_monthly_graphic" do
         @book.organism.periods.count.should == 2 
         @book.default_graphic.should == @book.two_years_monthly_graphic(p2)
       end
     end

     context "when there is one period" do
        before(:each) do
           p2.stub(:previous_period?).and_return(false)
            @book.stub_chain(:organism, :periods).and_return([p2])
          end
       it "build a one_year_graphic" do
         @book.organism.periods.count.should == 1
         @book.default_graphic.should == @book.one_year_monthly_graphic
       end
     end

   end

  # FIXME voir ce qu'on peut faire pour gérer les exercices de plus de douze mois (cas fréquent à la création)
  # TODO tester monthly_datas en situation réelle pour s'assurer que le stub répond bien à la réalité
  
  # je veux que monthly datas retourne
  describe "monthly_datas" do

    def data_arrays(period)
      year=period.start_date.year
      (1..12).map {|t| {"Month"=>"#{format('%02d',t)}-#{year}", 'total_month'=> 2*t}  }
    end

    def hash_datas_arrays(period)
      year=period.start_date.year
      h={}
      (1..12).map {|t| h["#{format('%02d',t)}-#{year}"]=70 }
      h
    end

    let(:period) {stub_model(Period, :start_date=>Date.civil(2012,01,01), :close_date=>Date.civil(2012,12,31))}
    let(:arl) {double(Arel)}

    before(:each) do
     @book = Book.new
     (1..12).map {|t| "#{format('%02d',t)}-#{2012}"}.each do |m| 
        @book.stub_chain(:lines,:month).with(m).and_return(arl)

     end
      arl.stub(:sum).with(:credit).and_return(120)
      arl.stub(:sum).with(:debit).and_return(50)

    end

    it 'checks list months' do
      period.list_months('%m-%Y').should == (1..12).map {|i| "#{format('%02d',i)}-2012"}
    end

    it "monthly_datas returns a hash" do
      @book.monthly_datas(period).should == hash_datas_arrays(period)
    end
    
  end
  
  describe 'monthly_sold' do

    def hash_datas 
      h={}
      (1..12).map {|t| h["#{format('%02d',t)}-#{2012}"]=700*t }
      h
    end

    before(:each) do
      @book=Book.new
      @book.stub(:monthly_solds).and_return(hash_datas)
    end

    it "monthly_sold return the sold of a specific month" do
     
      @book.monthly_solds.should be_a(Hash)
      (1..12).each do |i|
        @book.monthly_solds["#{format('%02d',i)}-2012"].should == 700*i
      end
     
    end

   end

end

