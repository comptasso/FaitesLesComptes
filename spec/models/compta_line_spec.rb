# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|
#  config.filter = {wip:true}
end


describe InOutWriting do

  include OrganismFixture

  before(:each) do
    create_minimal_organism
    @w1 = create_in_out_writing
  end

  it 'faire les spec de compta_line'


  it 'appeler lock_writing appelle lock_writing sur l écriture' do
     l = @w1.supportline
     l.lock
     @w1.should be_locked
  end
end
