require 'spec_helper'

describe "writings/show" do
  before(:each) do
    @writing = assign(:writing, stub_model(Writing))
  end

  it "renders attributes in <p>" do
    render
  end
end
