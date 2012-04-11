# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/periods/new'  do
  let(:o) {stub_model(Organism)}

  before(:each) do
    assign(:period, stub_model(Period, :organism_id=>1, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year) ).as_new_record
  end

  it "GET new" do
    render
    rendered.should have_content('Nouvel exercice')
  end

  it 'form shows janvier' do
    render
    rendered.should have_selector('form select', :content=>"janvier", :id=>'period_start_date_2i')
  end

  it 'form shows the year' do
    render
    rendered.should have_selector('form select', :content=>"#{Date.today.year}", :id=>'period_start_date_1i')
  end
  
  it 'form shows the field close_date' do
    render
    rendered.should have_selector('form select', :content=>"décembre", :id=>'period_close_date_2i')
  end

  it 'form shows the year for close date' do
    render
    rendered.should have_selector('form select', :content=>"#{Date.today.year}", :id=>'period_close_date_1i')
  end

  it 'form shoudl have submit button' do
    render
    rendered.should have_selector('input', :class=>'btn btn-primary span2', :value=>"Créer l'exercice")
  end
end

