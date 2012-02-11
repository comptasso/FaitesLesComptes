# To change this template, choose Tools | Templates
# and open the template in the editor.

# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#RSpec.configure do |c|
# # c.filter = { :wip=>true}
#end


describe "routes for application root" do
  it "routes application to organisms controller" do
    { :get => "/" }.should route_to(:controller => "organisms", :action => "index") 
  end
end


