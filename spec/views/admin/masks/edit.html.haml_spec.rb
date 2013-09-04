require 'spec_helper'

describe "admin/masks/edit" do
  include JcCapybara
  
  before(:each) do
    assign(:organism, @o = stub_model(Organism))
    assign(:mask, @ma = stub_model(Mask,
      :title => "MyString",
      :comment => "MyText",
      :organism_id => @o.to_param 
    ))
  end

  it "renders edit admin_mask form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admin_organism_mask_path(@o, @ma), "post" do
      assert_select "input#mask_title[name=?]", "mask[title]"
      assert_select "textarea#mask_comment[name=?]", "mask[comment]"
      
    end
  end
  
end
