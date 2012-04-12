# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/periods/new'  do
  include JcCapybara
  let(:o) {stub_model(Organism)}

  before(:each) do
    assign(:period, stub_model(Period, :organism_id=>1, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year) ).as_new_record
  end

  it "GET new" do
    render
    page.should have_content('Nouvel exercice')
  end

  it 'form shows janvier' do
    render
    page.find('form select#period_start_date_2i option[selected="selected"]').text.should  == "janvier"
  end

  it 'form shows the year' do
    render
    page.find('form select#period_start_date_1i').value.should == "#{Date.today.year}"
  end
  
  it 'form shows the field close_date' do
    render
    page.find('form select#period_close_date_2i option[selected="selected"]').text.should == "décembre"
  end

  it 'form shows the year for close date' do
    render
    page.find('form select#period_close_date_1i').value.should == "#{Date.today.year}"
  end

  it 'form shoudl have submit button' do
    render
    page.find('input[class="btn btn-primary span2"]').value.should == "Créer l'exercice"
  end
end

