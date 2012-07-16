# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Stats::Page do
  def stat_lines
    1.upto(20).collect {|i| ['ligne', 1, 2, 3, 6]}
  end

  def title
    %w(Ligne val1 val2 val3 Total)
  end


  before(:each) do
    @page = Stats::Page.new(1, title,  stat_lines)
  end

  it "should create a Page" do
    @page.should be_an_instance_of(Stats::Page)
  end

  it 'page should have a number' do
    @page.number.should == 1
  end

  it 'les pages sont ordonnées' do
    Stats::Page.new(2, title, nil).should > @page
  end


  it 'should have lines' do
    @page.should have(20).formatted_lines
  end

  it 'should have title line' do
    @page.title.should == title
  end
  
  it 'should have total_page' do
    @page.total_page_line.should == ['Total page', '20,00', '40,00' , '60,00' , '120,00']
  end

  it 'la première page n a pas de report' do
    @page.report_values = [1, 2 ,3,4]
    @page.report_line.should == nil
  end

  context 'la page n est pas la première' do

  before(:each) do
     @page = Stats::Page.new(2, title,  stat_lines)
  end

  it 'should have report=' do
    @page.report_values = [1, 2 ,3,4]
    @page.report_line.should == ['Reports', '1,00', '2,00' ,'3,00','4,00']
  end

  it 'report non initialisé renvoie nil' do
    @page.report_line.should == nil
  end

  it 'should have to_report_line' do
    @page.report_values = [1, 2 ,3,4]
    @page.to_report_line.should == ['A reporter', '21,00', '42,00', '63,00', '124,00']
  end

  it 'should have also a total_page_line' do
    @page.report_values = [1, 2 ,3,4]
    @page.report_line.should == ['Reports', '1,00', '2,00' ,'3,00','4,00']
    @page.total_page_line.should == ['Total page', '20,00', '40,00' , '60,00' , '120,00']
    @page.to_report_line.should == ['A reporter', '21,00', '42,00', '63,00', '124,00']
  end

  it 'la dernière page renvoie total_général et non à reporter' do
    @page.is_last
    @page.report_values = [1, 2 ,3,4]
    @page.to_report_line.should == ['Total général', '21,00', '42,00', '63,00', '124,00']
  end

  end

  it 'par défaut une page n est pas la dernière' do
    @page.should_not be_is_last
  end


  it 'mais elle peut être désignée comme la dernière' do
    @page.is_last
    @page.should be_is_last
  end

 


  


end

