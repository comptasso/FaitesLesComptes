# coding: utf-8

require "spec_helper"

describe "routes for adherent engine" do  
  routes { Adherent::Engine.routes }
  
  it "routes application to adherent engine" do
    pending 'rspec ne supporte pas le routing des engines pour Rails 3'
    { :get => "/adherent" }.should route_to(:controller => "session/members", :action => "index")
  end
  
  it 'test du path' do
    pending 'non supporté par rspec'
    adherent.members_path.should == 'bonjout'
  end
end


