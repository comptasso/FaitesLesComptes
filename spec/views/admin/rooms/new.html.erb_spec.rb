# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')


describe '/admin/rooms/new' do
  include JcCapybara

  let(:r) { mock_model(Room, title:'', comment:'', status:'', racine:'') }

  before(:each) do
    assign(:room, r)
    render
  end

  it "page should have a a title and a firm" do
    page.should have_content 'Nouvel organisme'
    page.all('form').should have(1).form 
  end

end