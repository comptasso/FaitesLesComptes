require 'spec_helper'

describe "admin/subscriptions/new" do
  include JcCapybara
  
  before(:each) do
    assign(:organism, @o = stub_model(Organism))
    assign(:subscription, stub_model(Subscription,
      :title => "MyString",
      :day => 6,
      :organism_id => @o.to_param 
    ).as_new_record)
  end

  it "renders new admin_subscription form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admin_organism_subscriptions_path(@o), "post" do
      assert_select "input#subscription_title[name=?]", "subscription[title]"
      assert_select "select#subscription_day[name=?]", "subscription[day]" 
      assert_select "select#subscription_mask_id[name=?]", "subscription[mask_id]"
      assert_select "select#subscription_end_date_2i"
      assert_select "select#subscription_end_date_1i"
      
    end
  end
  
end