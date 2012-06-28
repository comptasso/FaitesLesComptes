# coding: utf-8

require "spec_helper"

describe UsersController do
  describe "routing" do
 it "routes to #new" do
      get("/cashes/1/cash_controls/new").should route_to("cash_controls#new", :cash_id=>"1")
    end
  end
end