require "spec_helper"

describe WritingsController do
  describe "routing" do

    it "routes to #index" do
      get("/writings").should route_to("writings#index")
    end

    it "routes to #new" do
      get("/writings/new").should route_to("writings#new")
    end

    it "routes to #show" do
      get("/writings/1").should route_to("writings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/writings/1/edit").should route_to("writings#edit", :id => "1")
    end

    it "routes to #create" do
      post("/writings").should route_to("writings#create")
    end

    it "routes to #update" do
      put("/writings/1").should route_to("writings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/writings/1").should route_to("writings#destroy", :id => "1")
    end

  end
end
