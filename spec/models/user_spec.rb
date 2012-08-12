require 'spec_helper'

describe User do
  # pending "add some examples to (or delete) #{__FILE__}"

  it 'need a name' do
    u = User.new
    u.should_not be_valid
    u.should have(1).errors_on(:name)

  end
  
end
