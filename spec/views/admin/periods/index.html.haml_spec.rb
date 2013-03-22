# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/periods/index" do 
    include JcCapybara

    before(:each) do
      assign(:organism, stub_model(Organism))
      @p = mock_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year,
      'open?'=>true, 'closable?'=>false )
    end

  it 'rend la vue index' do
    assign(:periods, [@p])
    render 

  end

  it 'seule la ligne active a des icones d actions' do
    pending 'A faire'
  end

  describe 'icone supprimer' do

  before(:each) do
    @ps = [1,2,3].collect do |i|
      d = Date.today.beginning_of_year.years_since i
      mock_model(Period, start_date:d, close_date:d.end_of_year, 'open?'=>true, 'closable?'=>false)
    end
    
    @ps[0].stub(:destroyable?).and_return true
    @ps[1].stub(:destroyable?).and_return false
    @ps[2].stub(:destroyable?).and_return true
    assign(:periods, @ps)
  end


  it 'l icone destroy est disponible pour le premier' do
    
    assign(:period, @ps[0])
    render
    page.all('tbody tr:first img').first[:src].should match /\/assets\/icones\/supprimer.png/
    
  end

  it 'pour le dernier exercice' do
    assign(:period, @ps[2])
    render
    page.all('tbody tr:last img').first[:src].should match /\/assets\/icones\/supprimer.png/
  end

  it 'mais pas pour le second' do
    assign(:period, @ps[1])
    render
    page.all('tbody tr:nth-child(1) img').should have(0).element
  end
 

  end

end
