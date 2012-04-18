# coding: utf-8

require 'spec_helper'
include JcCapybara
include OrganismFixture

describe "Cashes" do

  before(:each) do
    Cash.count.should == 0
    create_minimal_organism
    @ca = @o.cashes.create!(:name=>'Magasin')
  end


  describe "GET /cash_cash_lines" do
    it "works! (I try now write some real specs)" do
      get cash_cash_lines_path(@ca)
      response.status.should == 302
    end

    it 'get with a month params' do
      get cash_cash_lines_path(@ca, :mois=>'3')
      response.status.should == 200 
    end
  end
end
