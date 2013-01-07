# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|
#  config.filter = {wip:true}
end


describe InOutWriting do

  include OrganismFixture

  def valid_attributes
    {writing_id:1, account_id:@income_account.id, nature:@n, credit:15.2, payment_mode:'Virement'}
 
  end

  before(:each) do
    create_minimal_organism
    @cl = ComptaLine.new(valid_attributes)
    @cl.stub(:writing).and_return(@w = mock_model(Writing))
    @w.stub(:date).and_return Date.today
    @w.stub_chain(:book, :organism, :find_period, :id).and_return(@p.id)
  end

  it 'validation' do
    @cl.valid?
    puts @cl.errors.messages
    @cl.should be_valid
  end

  describe 'cohérence comptes et nature avec date' do
    
    it 'une compta line ne peut avoir qu une nature appartenant à l exercice' do
      @w.stub_chain(:book, :organism, :find_period, :id).and_return(@p.id + 1)
      @cl.should_not be_valid
      @cl.errors[:nature].should == ["N'appartient pas à l'exercice comprenant #{I18n::l Date.today}"]
    end

    it 'une compta line ne peut avoir qu un compte appartenant à l exercice' do
      @w.stub_chain(:book, :organism, :find_period, :id).and_return(@p.id + 1)
      @cl.should_not be_valid
      @cl.errors[:account].should == ["N'appartient pas à l'exercice comprenant #{I18n::l Date.today}"]
    end

    end

end
