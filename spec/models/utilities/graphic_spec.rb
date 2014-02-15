# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Utilities::Graphic do
  
  def monthly_datas
    {'01-2014'=> '1', '10-2014'=>'10', '11-2014'=>'11' }
  end
  
  let(:obj) {Book.new}
  
  let(:period) {Period.new(start_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year)}
  
  let(:previous_period) {Period.new(start_date:Date.today.beginning_of_year << 12,
      close_date:Date.today.end_of_year << 12)}

    
  before(:each) do
    period.stub(:previous_period?).and_return false
    obj.stub(:query_monthly_datas).and_return(monthly_datas)
  end
  
  subject {Utilities::Graphic.new(obj, period, :bar)}
   
    
  it 'les ticks sont calculés à partir des ListMonths' do
    period.stub('previous_period?').and_return false
    subject.ticks.should == period.list_months.to_abbr
  end
  
  
  describe 'build_series' do
    
    context 'sans exercice précédent' do
      
      it 'construit une seule série' do
        subject.should_receive(:add_serie)
        subject.build_series
      end
      
    end
    
    context 'avec exercice precedent' do
      
      before(:each) do
        period.stub(:previous_period?).and_return true
        period.stub(:previous_period).and_return previous_period
      end
      
      it 'construit deux séries' do
        subject.should_receive(:add_serie).exactly(2).times
        subject.build_series
      end
      
    end
    
    
  end
  
  describe 'add_serie' do
    
   
    
    before(:each) do
      period.stub(:short_exercice).and_return '2014'
      period.stub(:id).and_return 127
      
    end
    
    it 'ajoute un élément à la légende' do
      subject.legend.should == ['2014'] 
    end
    
    it 'ajoute l id de l exercice à ' do
      subject.period_ids.should == [127]
    end
    
    it 'ajoute les month_years de l exercice' do
      subject.month_years.should == [ListMonths.new(period.start_date, period.close_date).to_list('%m-%Y')]
    end
    
    it 'demande les datas à l object' do
      obj.should_receive(:query_monthly_datas).with(period).and_return(monthly_datas)
      subject.add_serie(period)      
    end
    
    it 'comlète la série avec des zeros' do
      subject.series.should == [%w(1 0 0 0 0 0 0 0 0 10 11 0)]
    end
    
    it 'ajoute les datas à series' do
      subject.should_receive(:build_datas).with(obj, period).and_return 'le tableau de données'
      subject.add_serie(period)
    end
    
    # TODO compléter ces tests avec la gestion du type de graphique
    
    describe 'graphes de type line' do
      
      before(:each) do
        period.stub('previous_period?').and_return true
        period.stub(:previous_period).and_return previous_period
        previous_period.stub(:short_exercice).and_return '2013'
        previous_period.stub(:id).and_return 126
        obj.stub(:query_monthly_datas).with(previous_period).and_return({'09-2013'=> '25', '10-2013'=>'10' })
      end
       
      context 'quand l exercice précédent est ouvert' do
         
        before(:each) do
          previous_period.stub(:open).and_return true
        end  
       
        subject {Utilities::Graphic.new(obj, period, :line)}
       
        it 'les valeurs de la série sont accumulées' do
          subject.series.first.should == ["0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "25.0", "35.0", "35.0", "35.0"]
        end
       
        it 'y compris pour la deuxième série' do
          subject.series.last.should == %w(36.0 36.0 36.0 36.0 36.0 36.0 36.0 36.0 36.0 46.0 57.0 57.0)
        end
       
      end
       
      context 'mais lorsque l exercice précédent est clos' do
         
        before(:each) do
          previous_period.stub(:open).and_return false
        end
         
        subject {Utilities::Graphic.new(obj, period, :line)}
         
        it 'la deuxième série n accumule pas ses valeurs avec la première' do
          subject.series.should ==  [["0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "25.0", "35.0", "35.0", "35.0"],
            ["1.0", "1.0", "1.0", "1.0", "1.0", "1.0", "1.0", "1.0", "1.0", "11.0", "22.0", "22.0"]] 
        end
         
      end
       
       
       
       
    end
    
  end
    


end

