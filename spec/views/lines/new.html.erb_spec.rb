# coding: utf-8

require 'spec_helper'

describe "lines/new.html.erb" do
  before(:each) do
    assign(:line, stub_model(Line,
      :date => Date.today
    ).as_new_record)
  end

  it "renders new line  form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => lines_path, :method => "post" do
      assert_select "input#user_name", :name => "user[name]"
    end
  end
end

