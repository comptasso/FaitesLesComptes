require 'spec_helper'

describe "transfers/show" do
  before(:each) do
    @transfer = assign(:transfer, stub_model(Transfer,
      :narration => "Narration",
      :debited_id => 1,
      :credited_id => 1,
      :amount => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Narration/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1.5/)
  end
end
