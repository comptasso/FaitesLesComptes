# coding: utf-8 

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |config|  
# config.filter = {wip:true}
end


describe ComptaLine do 

  include OrganismFixtureBis
  let(:per) {mock_model(Period)}
  let(:nat) {mock_model(Nature, period:per,  name:'Petite nature', :account=>acc)}
  let(:acc) {mock_model(Account, period:per, period_id:per.id)}
  let(:des) {mock_model(Destination, name:'Destinée')}
  let(:bo) {mock_model(Book)}

  def valid_attributes
    {writing_id:1, account_id:acc.id, nature:nat, nature_id:nat.id, credit:15.2, payment_mode:'Virement'}
  end

  before(:each) do
 
    @cl = ComptaLine.new(valid_attributes)
    @cl.stub(:account).and_return acc
    @cl.stub(:writing).and_return(@w = mock_model(Writing, date:Date.today, narration:'Ecriture', :book_id=>bo.id))
    @w.stub_chain(:book, :organism, :find_period, :id).and_return(per.id)
  end

  it 'validation' do
    puts @cl.errors.messages unless @cl.valid?
    @cl.should be_valid
  end

  describe 'cohérence comptes et nature avec date' do
    
    it 'une compta line ne peut avoir qu une nature appartenant à l exercice' do
      @w.stub_chain(:book, :organism, :find_period, :id).and_return(per.id + 1)
      @cl.should_not be_valid
      @cl.errors[:nature].should == ["N'appartient pas à l'exercice comprenant #{I18n::l Date.today}"]
    end

    it 'une compta line ne peut avoir qu un compte appartenant à l exercice' do
      @w.stub_chain(:book, :organism, :find_period, :id).and_return(per.id + 1)
      @cl.should_not be_valid
      @cl.errors[:account].should == ["N'appartient pas à l'exercice comprenant #{I18n::l Date.today}"]
    end

  end
    
  describe 'les états d une compta_line' do
    
    
    
    describe 'une compta_line est editable' do
      
      it 'si elle n est pas pointée' do
        @cl.stub(:bank_extract_line).and_return('oui')
        @cl.should_not be_editable
      end
      
      it 'ni verrouillée' do
        @cl.locked = true
        @cl.should_not be_editable
      end
      
      it 'ni associée à une remise de chèque' do
        @cl.check_deposit_id = 1
        @cl.should_not be_editable
      end
      
    end
    
    
  end

  describe 'methods' do
    it 'label renvoie' do
      @cl.label.should == "#{Date.today.strftime('%d-%m')} - Ecriture - 0.00"
    end

    it 'nature_name renvoie le nom de la nature' do
      @cl.should_receive(:nature).at_least(1).times.and_return nat
      @cl.nature_name.should == 'Petite nature'
    end

    it 'nature_name renvoie '' si pas de nature' do
      @cl.should_receive(:nature).and_return nil
      @cl.nature_name.should be_blank
    end

    it 'destination_name renvoie le nom de la destination' do
      @cl.should_receive(:destination).at_least(1).times.and_return des
      @cl.destination_name.should == 'Destinée'
    end

    it 'destination_name renvoie '' si pas de destination' do
      @cl.should_receive(:destination).and_return nil
      @cl.destination_name.should be_blank
    end

    
  end
  
  describe 'scope not_pointed_lines'  do
    
    before(:each) do
      use_test_organism
    end  
    
    after(:each) do
      Writing.delete_all
      ComptaLine.delete_all
    end
    
    context 'pas encore d écritures' do    
      it 'et donc zero lignes non pointées' do
        ComptaLine.not_pointed.count.should == 0
      end
    end
    
    context 'avec une écriture' , wip:true do
                      
      it 'la banque a une ligne non pointée' do
        @ecriture = create_outcome_writing
        @baca.compta_lines.not_pointed.count.should == 1
      end
      
    end
    
    
  end
 
end
