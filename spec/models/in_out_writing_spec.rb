# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|
#  config.filter = {wip:true}
end


describe InOutWriting do
  include OrganismFixture 

  def valid_attributes
    {date:Date.today, narration:'spec',
      :compta_lines_attributes=>{'0'=>{account_id:@acc.id, debit:145, payment_mode:'Virement'},
      '1'=>{account_id:@baca.id, credit:145, payment_mode:'Virement'}}}
  end


  before(:each) do
    create_minimal_organism
    @acc = @p.accounts.classe_6.first
  end

  describe "creation de ligne" do

    before(:each) do
      @w = @ob.in_out_writings.new(valid_attributes)
    end

    it 'should be valid' do
      @w.should be_valid
    end

    it 'not valid without date' do
      @w.date  = nil
      @w.should_not be_valid
    end

    it 'not valid without narration' do
      @w.narration  = nil
      @w.should_not be_valid
    end

    it 'not balanced' do
      @w.compta_lines.first.debit = 1455
      @w.should_not be_valid
    end

    it 'two lines' , wip:true do
     v = Writing.new date:Date.today, narration:'test', book_id:@ob.id
     v.should have(1).errors_on(:base)
     v.errors.messages[:base].should == ['Une écriture doit avoir au moins deux lignes']
    end

    describe 'save' do

      it 'ajoute une écriture' do
        expect {@w.save}.to change {Writing.count}.by 1
      end

      it 'et deux lignes' do
        expect {@w.save}.to change {ComptaLine.count}.by 2
      end


    end

  end

end
