require 'spec_helper'

describe "writings/new" do
  before(:each) do
    assign(:writing, stub_model(Writing).as_new_record)
  end

  it "renders new writing form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => writings_path, :method => "post" do
    end
  end
end
