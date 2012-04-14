require "spec_helper"

describe TransfersController do
  describe "routing" do

    it "routes to #index" do
      get("/transfers").should route_to("transfers#index")
    end

    it "routes to #new" do
      get("/transfers/new").should route_to("transfers#new")
    end

    it "routes to #show" do
      get("/transfers/1").should route_to("transfers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/transfers/1/edit").should route_to("transfers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/transfers").should route_to("transfers#create")
    end

    it "routes to #update" do
      put("/transfers/1").should route_to("transfers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/transfers/1").should route_to("transfers#destroy", :id => "1")
    end

  end
end
