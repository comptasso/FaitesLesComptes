# To change this template, choose Tools | Templates
# and open the template in the editor.

# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

#RSpec.configure do |c|
# c.filter_run_excluding :broken => true
#end


describe "routes for application root" do 
  
  it "routes application to organisms controller" do
    pending 'attendre le passage à RSpec 3 car ne fonctionne plus depuis Ruby 2.2.'
    { :get => "/" }.should route_to(:controller => "devise/sessions", :action => "new")
  end
end


