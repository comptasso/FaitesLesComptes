require 'spec_helper'

describe "admin/masks/show" do
  before(:each) do
    @admin_mask = assign(:admin_mask, stub_model(Admin::Mask,
      :title => "Title",
      :comment => "MyText",
      :organism => nil
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
