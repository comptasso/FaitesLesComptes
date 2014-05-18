# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|  
  #  config.filter =  {wip:true}
end


describe ImportedBel do    
  include OrganismFixtureBis  
  
  def valid_attributes 
    {date:Date.today,
      cat:'D',
      narration:'une ibel',
      debit:56.25,
      credit:0,
      payment_mode:'CB'}
    
    
  end
  
  describe 'validation' do
    
    subject {ImportedBel.new(valid_attributes)}
    
    it {subject.should be_valid}
    
    it 'les cat peuvent être D, C, T et R' do
      subject.cat = 'D'; subject.should be_valid
      subject.cat = 'C'; subject.should be_valid
      subject.cat = 'T'; subject.should be_valid
      subject.cat = 'R'; subject.should be_valid
      subject.cat = 'v'; subject.should_not be_valid
    end
    
    
  end
  
  describe 'complete?' do
    subject {ImportedBel.new(destination_id:1, nature_id:1, payment_mode:'CB')}
    
    it {subject.should be_complete}
    it {subject.destination_id = nil; subject.should_not be_complete}
    it {subject.nature_id = nil; subject.should_not be_complete}
    it {subject.payment_mode = nil; subject.should_not be_complete}
  end
  
  describe 'reset du payment_mode si changement de catégorie' do
    
    before(:each) {@ibel = ImportedBel.create!(valid_attributes)}
    
    after(:each) {ImportedBel.delete_all}
    
    subject {@ibel}
    
    it 'mettre à jour la catégorie et appeler valid met payment_mode à nil' do
      subject.cat = 'R'
      subject.save
      subject.payment_mode.should be_nil
    end
    
  end
  
  describe 'to write doit donner les paramètres nécessaires à une création d écriture' do
    
    let(:ba) {mock_model(BankAccount)}
    
    before(:each) do
      Organism.stub_chain(:first, :find_period).and_return(@o = mock_model(Organism))
      ImportedBel.any_instance.stub(:bank_account).and_return(ba)
      ba.stub_chain(:current_account, :id).and_return 107
    end
    
    context 'quand l ibel est une dépense' do
      
      subject {ImportedBel.new(date:Date.today, writing_date: Date.today,
          cat:'D', ref:'Ecriture n...', 
          narration:'Ecriture importee',
          bank_account_id:1,
          nature_id:1, destination_id:1, 
          debit:25.45, credit:0, payment_mode:'CB')}
      
    
    
      it 'subject est complet' do
        subject.should be_valid
        subject.should be_complete
      end
    
      it 'to write renvoie les params' do
        subject.to_write.should == {date:Date.today, ref:'Ecriture n...',
          narration:'Ecriture importee',
          compta_lines_attributes:{'0'=> {nature_id:1, destination_id:1,
              debit:25.45, credit:0}, 
            '1'=>{account_id:107, debit:0, credit:25.45, payment_mode:'CB'}
          }
        }
      end
    end
    
    
    
  end
  
  describe 'avec un véritable organisme' do
        
    before(:each) do
      use_test_organism
    end
    
      
    describe 'une dépense' do
    
      subject {ImportedBel.new(date:Date.today, writing_date:Date.today,
          cat:'D', ref:'Ecriture n°...', 
          narration:'Ecriture importée',
          bank_account_id:@ba.id,
          nature_id:@n.id,
          destination_id:@o.destinations.first.id, 
          debit:25.45, credit:0, payment_mode:'CB')}
        
      it 'to_write' do
        w = @ba.sector.outcome_book.in_out_writings.new(subject.to_write)
        w.should be_an_instance_of(InOutWriting)
        w.should be_valid
        w.save!
      end    
    end
    
    describe 'un transfert' do
      
      subject {ImportedBel.new(date:Date.today, 
          writing_date_picker:I18n.l(Date.today),
          cat:'T', ref:'Ecriture n°...', 
          narration:'Transfert',
          bank_account_id:@ba.id,
          nature_id:nil, destination_id:nil, 
          debit:25.45, credit:0, payment_mode:"cash_#{@c.id}")}
      
        
      it 'to_write' do
        
        w = @od.transfers.new(subject.to_write)
        w.should be_an_instance_of(Transfer)
#        puts w.compta_line_from.inspect
#        puts w.compta_line_to.inspect
        puts w.errors.messages unless w.valid?
        
        expect {w.save!}.not_to raise_error
      end    
      
    end
        
  end
  
  
  
end
  