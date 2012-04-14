require 'spec_helper'

describe "transfers/index" do
  before(:each) do
    assign(:transfers, [
      stub_model(Transfer,
        :narration => "Narration",
        :debited_id => 1,
        :credited_id => 1,
        :amount => 1.5
      ),
      stub_model(Transfer,
        :narration => "Narration",
        :debited_id => 1,
        :credited_id => 1,
        :amount => 1.5
      )
    ])
  end

  it "renders a list of transfers" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Narration".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
