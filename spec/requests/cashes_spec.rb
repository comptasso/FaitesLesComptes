# coding: utf-8

require 'spec_helper'
include JcCapybara
include OrganismFixture

describe "Cashes" do

  before(:each) do
   
    create_minimal_organism
   
  end


  describe "GET /cash_cash_lines" do
    it "works! (I try now write some real specs)" do
      get cash_cash_lines_path(@c)
      response.status.should == 302
    end

    it 'get with a month params' do
      get cash_cash_lines_path(@c, :mois=>'3')
      response.status.should == 200 
    end
  end
end
