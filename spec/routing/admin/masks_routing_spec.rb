require "spec_helper"

describe Admin::MasksController do
  describe "routing" do

    it "routes to #index" do
      get("/admin/masks").should route_to("admin/masks#index")
    end

    it "routes to #new" do
      get("/admin/masks/new").should route_to("admin/masks#new")
    end

    it "routes to #show" do
      get("/admin/masks/1").should route_to("admin/masks#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/masks/1/edit").should route_to("admin/masks#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin/masks").should route_to("admin/masks#create")
    end

    it "routes to #update" do
      put("/admin/masks/1").should route_to("admin/masks#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/masks/1").should route_to("admin/masks#destroy", :id => "1")
    end

  end
end
