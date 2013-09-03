require 'spec_helper'

describe "admin/masks/edit" do
  before(:each) do
    @admin_mask = assign(:admin_mask, stub_model(Admin::Mask,
      :title => "MyString",
      :comment => "MyText",
      :organism => nil
    ))
  end

  it "renders the edit admin_mask form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admin_mask_path(@admin_mask), "post" do
      assert_select "input#admin_mask_title[name=?]", "admin_mask[title]"
      assert_select "textarea#admin_mask_comment[name=?]", "admin_mask[comment]"
      assert_select "input#admin_mask_organism[name=?]", "admin_mask[organism]"
    end
  end
end
