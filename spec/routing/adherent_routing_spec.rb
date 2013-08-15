# coding: utf-8

require "spec_helper"

describe "routes for adherent engine" do  
  routes { Adhrent::Engine.routes }
  
  it "routes application to adherent engine" do
    { :get => "/adherent" }.should route_to(:controller => "adherent/members", :action => "index")
  end
end
