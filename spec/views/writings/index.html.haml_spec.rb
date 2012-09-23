require 'spec_helper'

describe "writings/index" do
  before(:each) do
    assign(:writings, [
      stub_model(Writing),
      stub_model(Writing)
    ])
  end

  it "renders a list of writings" do
    render
  end
end
