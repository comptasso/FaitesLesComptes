# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |config|
  # config.filter = {wip:true}
end


describe InOutWriting do
  include OrganismFixtureBis

  def valid_attributes
    {date:Date.today, narration:'spec',
      :compta_lines_attributes=>{'0'=>{account_id:@acc.id, debit:145, payment_mode:'Virement'},
      '1'=>{account_id:@baca.id, credit:145, payment_mode:'Virement'}}}
  end




  describe 'support' , wip:true do

    before(:each) do
      @w = InOutWriting.new
      
    end

    it 'interroge counter_line et account' do
      @w.should_receive(:counter_line).at_least(1).times.and_return(@cl = mock_model(ComptaLine))
      @cl.should_receive(:account).at_least(1).times.and_return(mock_model(Account, :title=>'chèque', :number=>'511'))
      @w.support
    end

    it 'renvoie le title pour le compte 511' do
      @w.stub_chain(:counter_line, :account).and_return(mock_model(Account, :title=>'chèque', :number=>'511'))
      @w.support.should == 'chèque'
    end

    it 'cherche le nick_name si compte 51 ' do
      @w.stub_chain(:counter_line, :account).and_return(@acc = mock_model(Account, :title=>'chèque', :number=>'5101'))
      @acc.stub_chain(:accountable, :nickname).and_return('Bonjour la banque')
      @w.support.should == 'Bonjour la banque'
    end

    it 'également si compte 53 ' do
      @w.stub_chain(:counter_line, :account).and_return(@acc = mock_model(Account, :title=>'chèque', :number=>'5301'))
      @acc.stub_chain(:accountable, :nickname).and_return('Bonjour la caisse')
      @w.support.should == 'Bonjour la caisse'
    end

    it 'demande le long_name autrement' do
      @w.stub_chain(:counter_line, :account).and_return(@acc = mock_model(Account, :title=>'chèque', :number=>'55'))
      @acc.stub_chain(:long_name).and_return('55 un compte')
      @w.support.should == '55 un compte'
    end


  end

  describe "creation de ligne" do

    before(:each) do
    use_test_organism
    @acc = @p.accounts.classe_6.first
    @w = @ob.in_out_writings.new(valid_attributes)
    end
    
    after(:each) do
      Writing.delete_all
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
  
  describe 'une écriture est editable' do
    let(:cl1) {double(ComptaLine, editable?:true)}
    let(:cl2) {double(ComptaLine, editable?:true)}
    
    before(:each) do
      @w = InOutWriting.new
      
      
    end
    
    it 'si toutes ses compta lines sont editable' do
      @w.stub(:comptalines).and_return([cl1, cl2])
      @w.should be_editable
    end
    
    it 'mais pas dans le cas  contraire' do
      cl2.stub('editable?').and_return false
      @w.stub(:compta_lines).and_return([cl1, cl2])
      @w.should_not be_editable
    end
  end

end
