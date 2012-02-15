# coding: utf-8

# To change this template, choose Tools | Templates
# and open the template in the editor.



require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Book do

  def datas(period)
    
    (1..12).map {|t| {'Month'=>"#{format('%02d',t)}", 'total_month'=> (t%2 == 0) ? 100+t*10 : 100-t*5 } }
  end

  context "un exercice de 12 mois commencant le 1er janvier" do

    let(:p1) {stub_model(Period, :start_date=>Date.civil(2010,01,01), :close_date=>Date.civil(2010,12,31))}

    before(:each) do
      @book = Book.new
    end

    describe "monthly_datas_for_chart" do
      before(:each) do
        @book.stub(:monthly_datas).with(p1).and_return(datas(p1))
      end

      it "monthly_datas_for_chart return a twelve months series" do
        p1.list_months('%m').should == (1..12).map {|i| format('%02d',i) }
      end
    end
 
    it "should have a ticks method with argument period" do
      @book.ticks(p1).should be_an(Array)
    end

    
    # deux exercices de 12 mois commençant en janvier chacun
    context "testing monthly_graphic with two periods of the same length" do

      let(:p2) {stub_model(Period, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))}

 
      before(:each) do
#        p2.stub(:list_months).with('%b').and_return(%w(jan fev mar avr mai juin jui aout sept oct nov dec))
#        p2.stub(:list_months).with('%m').and_return((1..12).map {|i| format('%02d',i) })
#        p1.stub(:exercice).and_return('Exercice 2010')
#        p2.stub(:exercice).and_return('Exercice 2011')
        p2.stub(:previous_period).and_return(p1)
        @book.stub(:monthly_datas).with(p2).and_return(datas(p2))
        @book.stub(:monthly_datas).with(p1).and_return(datas(p1))
     
      end

      it "should have a two_years_monthly_graphic method" do
        @book.two_years_monthly_graphic(p2)
      end

      context "check the two_years_monthly_graphic method" do
        before(:each) { @graphic=@book.two_years_monthly_graphic(p2)}

        it "monthly_graphic has a two series and ticks coming from period" do
          @graphic.legend.should ==['Exercice 2010', 'Exercice 2011']
        end

        it "monthly_graphic should have two series of datas" do
          @graphic.nb_series.should == 2
        end

        it "second datas serie is equal to datas build from period" do
          @graphic.series[0].should == (1..12).map {|t| t=t.to_i; (t%2 == 0) ? 100+t*10 : 100-t*5 }
        end


      end

    end
  end

  context "deux exercices de 12 mois décalés" do
    def period_datas(period)
      
      (4..12).map {|t| {"Month"=>"#{format('%02d',t)}", 'total_month'=> t}  } +  (1..3).map {|t| {"Month"=>"#{format('%02d',t)}", 'total_month'=> t } }
    end

    let(:p1) {stub_model(Period, :start_date=>Date.civil(2010,04,01), :close_date=>Date.civil(2011,03,31))}
    let(:p2) {stub_model(Period, :start_date=>Date.civil(2010,04,01), :close_date=>Date.civil(2011,03,31))}

    before(:each) do
      @book = Book.new
      @book.stub(:monthly_datas).with(p1).and_return(period_datas(p1))
      @book.stub(:monthly_datas).with(p2).and_return(period_datas(p2))
      @graphic=@book.two_years_monthly_graphic(p2)
    end

    it "each serie should be 4,5,6,7 to 12 then 1,2,3" do
      @graphic.series[0].should == [4,5,6,7,8,9,10,11,12,1,2,3]
      @graphic.series[1].should == [4,5,6,7,8,9,10,11,12,1,2,3]
    end
  
  end

  # on vérifie ici que lorsque la base de données ne renvoie pas d'information sur un mois,
  # parce qu'il n'y a pas eu d'écritures sur ce mois, alors les valeurs sont initalisées à zero
  context "deux exercices avec des trous" do
    def period_datas(period)
      
      (4..12).map {|t| {"Month"=>"#{format('%02d',t)}", 'total_month'=> t*2}  }
    end

    let(:p1) {stub_model(Period, :start_date=>Date.civil(2010,04,01), :close_date=>Date.civil(2011,03,31))}
    let(:p2) {stub_model(Period, :start_date=>Date.civil(2010,04,01), :close_date=>Date.civil(2011,03,31))}

    before(:each) do
      p2.stub(:previous_period).and_return(p1)
      p2.stub(:previous_period?).and_return(true)
      @book = Book.new
      @book.stub(:monthly_datas).with(p1).and_return(period_datas(p1))
      @book.stub(:monthly_datas).with(p2).and_return(period_datas(p2))
      @graphic=@book.two_years_monthly_graphic(p2)
    end

    it "each serie should be 4,5,6,7 to 12 then 0" do
      @graphic.series[0].should == [8,10,12,14,16,18,20,22,24,0,0,0]
      @graphic.series[1].should == [8,10,12,14,16,18,20,22,24,0,0,0]
    end

  end

  context "un premier exercice plus court que l'autre" do
    def range_period_datas(range)
      range.map {|t| {"Month"=>"#{format('%02d',t)}", 'total_month'=> 2*t}  }
    end

 
    let(:p1) {stub_model(Period, :start_date=>Date.civil(2010,04,01), :close_date=>Date.civil(2010,12,31))}
    let(:p2) {stub_model(Period, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))}

    before(:each) do
      p2.stub(:previous_period).and_return(p1)
      p2.stub(:previous_period?).and_return(true)
      @book = Book.new
      @book.stub(:monthly_datas).with(p1).and_return(range_period_datas(4..12))
      @book.stub(:monthly_datas).with(p2).and_return(range_period_datas(1..12))
    end

   
    it "first serie should be completed with 0" do
      @graphic=@book.two_years_monthly_graphic(p2)
      @graphic.legend.should == ["de avr. 2010 à déc. 2010", 'Exercice 2011']
      @graphic.series[0].should == [0,0,0,8,10,12,14,16,18,20,22,24]
      @graphic.series[1].should == [2,4,6,8,10,12,14,16,18,20,22,24] 
    end 

  end

  context "un exercie de douze précédé d'un exercice de 15 mois" do

     def range_period_datas(range)

      range.map {|t| {"Month"=>"#{format('%02d',t)}", 'total_month'=> 2*t}  }
    end


    let(:p1) {stub_model(Period, :start_date=>Date.civil(2009,9,01), :close_date=>Date.civil(2010,12,31))} # exercice de 15 mois,
    let(:p2) {stub_model(Period, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))} # exercice de 12 mois
    before(:each) do
      @book = Book.new
      p2.stub(:previous_period).and_return(p1)
      p2.stub(:previous_period?).and_return(true)
      @book.stub(:monthly_datas).with(p1).and_return(range_period_datas(9..12) + range_period_datas(1..12))
      @book.stub(:monthly_datas).with(p2).and_return(range_period_datas(1..12))
    end

     # FIXME ceci devrait créer un bug difficile car on a plusieurs mois 09, 10, 11, 12

    it "should build a two_years_monthly_graph" do
      @graphic=@book.two_years_monthly_graphic(p2)
      @graphic.legend.should == ["de sept. 2009 à déc. 2010", 'Exercice 2011']
      @graphic.series[0].should == [2,4,6,8,10,12,14,16,18,20,22,24]
      @graphic.series[1].should == [2,4,6,8,10,12,14,16,18,20,22,24]
    end

  end

   describe "default_graphic" do
     

        def range_period_datas(range)

      range.map {|t| {"Month"=>"#{format('%02d',t)}", 'total_month'=> 2*t}  }
    end


    let(:p1) {stub_model(Period, :start_date=>Date.civil(2009,9,01), :close_date=>Date.civil(2010,12,31))} # exercice de 15 mois,
    let(:p2) {stub_model(Period, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))} # exercice de 12 mois
    before(:each) do
      @book = Book.new
     
      @book.stub(:monthly_datas).with(p1).and_return(range_period_datas(9..12) + range_period_datas(1..12))
      @book.stub(:monthly_datas).with(p2).and_return(range_period_datas(1..12))

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

end

