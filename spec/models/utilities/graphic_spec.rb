# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Utilities::Graphic do
  let(:t) {%w(jan fev mar avr mai juin jui aout sept oct nov dec)}
  before(:each) do
    @graphic = Utilities::Graphic.new(t) 
  end

  it "ticks should be attr readable" do
    @graphic.ticks.should == t
  end

  it "adding a serie with success return true" do
    @graphic.add_serie({:legend=>'serie 1', :datas=>[1,2,3,1,2,3,1,2,3,1,2,3]}).should == true
  end

  context "with a malformatted serie" do

    it "tcks should be an array with at least an element" do
      expect {Utilities::Graphic.new('bonjour')}.to raise_error('Ticks should be an array with at least one element')
      expect {Utilities::Graphic.new([])}.to raise_error('Ticks should be an array with at least one element')
    end

    it "missing datas raise error" do
      expect {
        @graphic.add_serie({:legend=>'serie 1'}) }.to raise_error('Missing datas for this serie')
    end
    
    it "missing legend raise error" do
      expect {
        @graphic.add_serie({:datas=>[1,2,3,1,2,3,1,2,3,1,2,3]}) }.to raise_error('Missing legend for this serie')
    end

    it "datas and ticks should have same size" do
      expect {
        @graphic.add_serie({:legend=>'serie 1', :datas=>[1,2,3,1,2,3,1,2,3,1,2,]})
      }.should raise_error('Number of datas and ticks are different')
    end

  end

  context "after adding a serie" do
    let(:p1) {stub_model(Period, :start_date=>Date.civil(2010,01,01), :close_date=>Date.civil(2010,12,31))}

    before(:each) do
      @graphic.add_serie({:legend=>'serie 1', :datas=>[1,2,3,1,2,3,1,2,3,1,2,3], :period_id=>p1.id})
    end

    it "should return the number of serie" do
      @graphic.nb_series.should == 1
    end

    it "the legend is an array with 1 element" do
      @graphic.legend.should == ['serie 1']
    end

    it "returns the id of the period" do
      @graphic.period_ids.should == [p1.id]
    end

    it "datas is an array with the serie 1 datas" do
      @graphic.series.should be_an(Array)
      @graphic.series.should have(1).element
      @graphic.series[0].should == [1,2,3,1,2,3,1,2,3,1,2,3]
    end

    context "after adding another serie" do
      let(:p2) {stub_model(Period, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))}

      before(:each) do
        @graphic.add_serie({:legend=>'serie 2', :datas=> [7,8,9,7,8,9,7,8,9,7,8,9], :period_id=>p2.id})
      end

      it "the legend is now an array with two elements" do
        @graphic.legend.should have(2).elements 
      end

      it "with name serie 1 and serie 2" do
        @graphic.legend.first.should == 'serie 1'
        @graphic.legend.second.should =='serie 2'
      end

      it 'period_ids should return an array' do
        @graphic.period_ids.should == [p1.id,p2.id]
      end

      it "series[0] si still the same" do
        @graphic.series.first.should == [1,2,3,1,2,3,1,2,3,1,2,3]
      end

      it "and there is a serie 2 with valued added" do
        @graphic.series.second.should ==  [7,8,9,7,8,9,7,8,9,7,8,9]
      end

      it "nb_series return now 2" do
        @graphic.nb_series.should == 2
      end

    end

  end

  describe "equality" do
    let(:t) {%w(jan fev mar avr mai juin jui aout sept oct nov dec)}
    let(:p1) {stub_model(Period, :start_date=>Date.civil(2010,01,01), :close_date=>Date.civil(2010,12,31))}
    let(:p2) {stub_model(Period, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))}

    before(:each) do
      @graphic = Utilities::Graphic.new(t)
      @graphic.add_serie({:legend=>'serie 1', :datas=>[1,2,3,1,2,3,1,2,3,1,2,3], :period_id=>p1.id})
      @graphic.add_serie({:legend=>'serie 2', :datas=> [7,8,9,7,8,9,7,8,9,7,8,9], :period_id=> p2.id})
      @graphic2 = Utilities::Graphic.new(t)
    end

    # TODO complete these tests
    it "non similar graphics should not be equal" do
      @graphic2.add_serie({:legend=>'serie 1', :datas=>[1,2,3,1,2,3,1,2,3,1,2,3]})
      @graphic2.add_serie({:legend=>'serie 2', :datas=> [7,8,9,7,8,9,7,8,9,7,8,9]})
      @graphic2.should_not == @graphic
    end

    it "two similar graphics should be equal" do
      @graphic2.add_serie({:legend=>'serie 1', :datas=>[1,2,3,1,2,3,1,2,3,1,2,3], :period_id=>p1.id})
      @graphic2.add_serie({:legend=>'serie 2', :datas=> [7,8,9,7,8,9,7,8,9,7,8,9], :period_id=>p2.id})
      @graphic2.should == @graphic
    end


  end 

  

end

