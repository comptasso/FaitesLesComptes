require 'spec_helper'

describe "admin/masks/index" do
  before(:each) do
    assign(:admin_masks, [
      stub_model(Admin::Mask,
        :title => "Title",
        :comment => "MyText",
        :organism => nil
      ),
      stub_model(Admin::Mask,
        :title => "Title",
        :comment => "MyText",
        :organism => nil
      )
    ])
  end

  it "renders a list of admin/masks" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
