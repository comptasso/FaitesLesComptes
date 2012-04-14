require 'spec_helper'

describe "transfers/edit" do
  before(:each) do
    @transfer = assign(:transfer, stub_model(Transfer,
      :narration => "MyString",
      :debited_id => 1,
      :credited_id => 1,
      :amount => 1.5
    ))
  end

  it "renders the edit transfer form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => transfers_path(@transfer), :method => "post" do
      assert_select "input#transfer_narration", :name => "transfer[narration]"
      assert_select "input#transfer_debited_id", :name => "transfer[debited_id]"
      assert_select "input#transfer_credited_id", :name => "transfer[credited_id]"
      assert_select "input#transfer_amount", :name => "transfer[amount]"
    end
  end
end
