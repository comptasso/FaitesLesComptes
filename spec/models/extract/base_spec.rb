# coding: utf-8



RSpec.configure do |config|
#  config.filter = {wip:true}

end

describe Extract::Base do

  before(:each) do
    @b = Extract::Base.new()
  end

  it 'lines lève une erreur' do
    expect {@b.lines}.to raise_error 'implement this method in children class'
  end

  it 'total debit fait la somme des débit des lines' do
    @b.stub(:lines).and_return(@ar = double(Arel))
    @ar.should_receive(:sum).with(:debit)
    @b.total_debit
  end

  it 'total debit fait la somme des débit des lines' do
    @b.stub(:lines).and_return(@ar = double(Arel))
    @ar.should_receive(:sum).with(:credit)
    @b.total_credit
  end
end