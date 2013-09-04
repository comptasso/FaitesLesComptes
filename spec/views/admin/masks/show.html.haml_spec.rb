require 'spec_helper'

describe "admin/masks/show" do
  before(:each) do
    assign(:organism, @o = stub_model(Organism))
    @mask = assign(:mask, stub_model(Mask,
      :title => "Title",
      :comment => "MyText",
      :organism_id => @o.to_param
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    rendered.should match(//)
  end
end
