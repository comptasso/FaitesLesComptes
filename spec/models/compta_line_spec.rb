# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|
#  config.filter = {wip:true}
end


describe InOutWriting do

  include OrganismFixture

  def valid_attributes
    {book_id:@ib.id, date:Date.today, narration:'ligne créée par la méthode vaild_attributes',
      :compta_lines_attributes=>{'0'=>{account_id:@income_account.id, nature:@n, credit:15.2, payment_mode:'Virement'},
        '1'=>{account_id:@baca.id, debit:15.2, payment_mode:'Virement'}
      }
    }
  end

  before(:each) do
    create_minimal_organism
    @w1 = create_in_out_writing
    @w2 = InOutWriting.new(valid_attributes) 
  end

  it 'validation' do
    @w2.should be_valid
  end
  
  describe 'cohérence comptes et nature avec date' do
    
    before(:each) do
      begin_next_period = @p.close_date + 1 
      @p2 = Period.create!(start_date:begin_next_period, close_date:begin_next_period.end_of_year, organism_id:@o.id)
    end
    
    it 'une compta line ne peut avoir qu une nature appartenant à l exercice' do
      
      invalid = valid_attributes
      invalid[:compta_lines_attributes]['0'][:nature] = @p2.natures.recettes.first
      w = Writing.new(invalid)
      w.valid?
      errors = 0
      w.compta_lines.each do |cl|
         if cl.errors.any?
           puts cl.errors.messages
           errors += 1
         end
      end
      errors.should == 1
    end

    it 'une compta line ne peut avoir qu un compte appartenant à l exercice' do
      pending
      c2 = @p2.recettes_accounts.first
      va = valid_attributes
      va[:compta_lines_attributes]['0'][:account_id] = c2.id
      Writing.new(va).should_not be_valid
    end

    end


  it 'appeler lock_writing appelle lock_writing sur l écriture' do
     l = @w1.support_line
     l.lock
     @w1.should be_locked 
  end
end
