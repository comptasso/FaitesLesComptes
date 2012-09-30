require "spec_helper"

describe Compta::WritingsController do
  describe "routing" do

    it "routes to #index" do
      get("/compta/books/1/writings").should route_to("compta/writings#index" ,:book_id=>"1" )
    end

    it "routes to #new" do
      get("compta/books/1/writings/new").should route_to("compta/writings#new",  :book_id=>"1")
    end

    it "routes to #show" do
      get("compta/books/1/writings/1").should route_to("compta/writings#show", :book_id=>"1", :id => "1")
    end

    it "routes to #edit" do
      get("compta/books/1/writings/1/edit").should route_to("compta/writings#edit",:book_id=>"1", :id => "1")
    end

    it "routes to #create" do
      post("compta/books/1/writings").should route_to("compta/writings#create", :book_id=>"1")
    end

    it "routes to #update" do
      put("compta/books/1/writings/1").should route_to("compta/writings#update", :book_id=>"1",:id => "1")
    end

    it "routes to #destroy" do
      delete("compta/books/1/writings/1").should route_to("compta/writings#destroy",:book_id=>"1", :id => "1")
    end

  end
end
