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

    it 'la counter_line doit avoir un mode de payment' do
      @w.counter_line.payment_mode = nil
      @w.valid?
      @w.errors.messages[:counter_line].should == ['erreur sur la counter_line']
      @w.should_not be_valid
      @w.counter_line.errors.messages[:payment_mode].should == ['obligatoire']
    end


    describe 'création avec de mauvais paramètres' do


      context 'dans la vue new, on fait enter' do

        before(:each) do
          @w = @ob.in_out_writings.new("date_picker"=>"01/03/2013", "ref"=>"",
            "narration"=>"essa",
            "compta_lines_attributes"=>{'0'=>{"nature_id"=>"", "destination_id"=>"", "credit"=>"0", "debit"=>"0", "payment_mode"=>"" },
              '1'=>{"account_id"=>"144", "check_number"=>"", "credit"=>"0", "debit"=>"0", "payment_mode"=>"" }})
        end

        it 'in_out_line doit néanmoins exister' do
          @w.in_out_line.should be_an_instance_of(ComptaLine)
        end

      end




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
