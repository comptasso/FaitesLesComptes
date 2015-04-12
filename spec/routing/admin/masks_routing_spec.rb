require "spec_helper"

describe Admin::MasksController do
  describe "routing" do
    
    it "routes to #index" do
      pending 'attendre le passage à RSpec 3 car ne fonctionne plus depuis Ruby 2.2.'
      expect(:get=>"/admin/organisms/1/masks").to route_to("admin/masks#index", organism_id:'1') 
    end

    it "routes to #new" do
      pending 'attendre le passage à RSpec 3 car ne fonctionne plus depuis Ruby 2.2.'
      get("/admin/organisms/1/masks/new").should route_to("admin/masks#new", organism_id:'1')
    end

    it "routes to #show" do
      pending 'attendre le passage à RSpec 3 car ne fonctionne plus depuis Ruby 2.2.'
      get("/admin/organisms/1/masks/1").should route_to("admin/masks#show", organism_id:'1', :id => "1")
    end

    it "routes to #edit" do
      pending 'attendre le passage à RSpec 3 car ne fonctionne plus depuis Ruby 2.2.'
      get("/admin/organisms/1/masks/1/edit").should route_to("admin/masks#edit", organism_id:'1', :id => "1")
    end

    it "routes to #create" do
      pending 'attendre le passage à RSpec 3 car ne fonctionne plus depuis Ruby 2.2.'
      post("/admin/organisms/1/masks").should route_to("admin/masks#create", organism_id:'1')
    end

    it "routes to #update" do
      pending 'attendre le passage à RSpec 3 car ne fonctionne plus depuis Ruby 2.2.'
      put("/admin/organisms/1/masks/1").should route_to("admin/masks#update", organism_id:'1', :id => "1")
    end

    it "routes to #destroy" do
      pending 'attendre le passage à RSpec 3 car ne fonctionne plus depuis Ruby 2.2.'
      delete("/admin/organisms/1/masks/1").should route_to("admin/masks#destroy", organism_id:'1', :id => "1")
    end

  end
end
