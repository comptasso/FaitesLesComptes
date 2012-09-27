require 'spec_helper'

describe "writings/edit" do
  before(:each) do
    @writing = assign(:writing, stub_model(Writing))
  end

  it "renders the edit writing form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => writings_path(@writing), :method => "post" do
    end
  end
end
