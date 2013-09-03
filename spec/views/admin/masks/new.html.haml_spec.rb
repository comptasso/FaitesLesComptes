require 'spec_helper'

describe "admin/masks/new" do
  before(:each) do
    assign(:admin_mask, stub_model(Admin::Mask,
      :title => "MyString",
      :comment => "MyText",
      :organism => nil
    ).as_new_record)
  end

  it "renders new admin_mask form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admin_masks_path, "post" do
      assert_select "input#admin_mask_title[name=?]", "admin_mask[title]"
      assert_select "textarea#admin_mask_comment[name=?]", "admin_mask[comment]"
      assert_select "input#admin_mask_organism[name=?]", "admin_mask[organism]"
    end
  end
end
