require 'spec_helper'

describe "admin/masks/show" do
  before(:each) do
    
    assign(:organism, @o = stub_model(Organism)) 
    view.stub(:virgule).and_return('5,25') # car virgule est un helper de controller
    # également accessible par helper_method dans les vues par helper_method mais pas pour les specs
    @mask = assign(:mask, stub_model(Mask,
      :title => "Title",
      :comment => "MyText",
      :organism_id => @o.to_param
    ))
  end 

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    
  end
end
