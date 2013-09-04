require 'spec_helper'

describe "admin/masks/new" do
  include JcCapybara
  
  before(:each) do
    assign(:organism, @o = stub_model(Organism))
    assign(:mask, stub_model(Mask,
      :title => "MyString",
      :comment => "MyText",
      :organism_id => @o.to_param 
    ).as_new_record)
  end

  it "renders new admin_mask form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admin_organism_masks_path(@o), "post" do
      assert_select "input#mask_title[name=?]", "mask[title]"
      assert_select "textarea#mask_comment[name=?]", "mask[comment]"
      
    end
  end
  
end
