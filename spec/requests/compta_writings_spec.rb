# coding: utf-8

require 'spec_helper'

describe "Writings" do
  include OrganismFixture


  before(:each) do
    create_user
    create_minimal_organism
    login_as('quidam')
  end

  describe "GET compta/writings" do
    it "works! (now write some real specs)" do
      pending 'faire une méthode préparant les datas pour accéder à la zone compte'
      get compta_book_writings_path(@od) 
      save_and_open_page
      response.status.should == 200
    end
  end
end
