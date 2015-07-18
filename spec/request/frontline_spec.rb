# coding: utf-8

require 'spec_helper' 

RSpec.configure do |c| 
  #   c.filter = {:wip=>true}
end

describe Request::Frontline do  
  include OrganismFixtureBis 
  let(:from_date) {Date.today.beginning_of_month}
  let(:to_date) {Date.today.end_of_month}
  
  before(:each) do
    use_test_organism
    
  end

  describe 'méthode de classe fetch' do
  
    it 'interroge la base de données et retourn un array de tuple' do
      res = Request::Frontline.fetch(@ob.id, from_date, to_date) 
      res.should == []
    end
    
  end
  
  describe 'méthodes d accès aux valeurs' do
    
    context 'avec une écriture' do
      
      before(:each) do
        @w = create_in_out_writing
        @cl = @w.compta_lines.first
        @res = Request::Frontline.fetch(@ib.id, from_date, to_date) 
      end
      
      
      after(:each) do
        Writing.delete_all
      end
      
      it 'renvoie un array de une écriture' do
        @res.size.should == 1
      end
      
      it 'et connait les champs' do
        w = @res.first
        w.writing_type.should == 'InOutWriting'
        w.id.should == @w.id
        w.payment_mode.should == @w.payment_mode
        w.nature_name.should == @cl.nature.name
        w.destination_name.should == nil # car in_out_writing ne remplit pas 
        # sans destination
      end
      
      
      
    end
    
  end
  
  describe 'editable?' do
    
    
    
    before(:each) do
      @w = create_in_out_writing
      @cl = @w.compta_lines.first
      
      
    end
      
      
    after(:each) do
      Writing.delete_all
    end
      
    it 'une nouvelle écriture est éditable' do
      @frontline = Request::Frontline.fetch(@ib.id, from_date, to_date).first
      @frontline.should be_editable 
    end
    
    it 'mais pas si la compta_line est verrouillée' do
      @cl.update_attribute(:locked, true)
      @frontline = Request::Frontline.fetch(@ib.id, from_date, to_date).first
      @frontline.should_not be_editable
    end
    
    it 'ni si la support_line est pointée' do
      BankExtractLine.create!(position:1, bank_extract_id:1, compta_line_id:@w.support_line.id)
      @frontline = Request::Frontline.fetch(@ib.id, from_date, to_date).first
      @frontline.should_not be_editable
    end
    
    it 'ni si le chèque a été remise' do
      @w.support_line.update_attribute(:check_deposit_id, 1)
      @frontline = Request::Frontline.fetch(@ib.id, from_date, to_date).first
      @frontline.should_not be_editable
    end
    
    it 'ni si la support_line est verrouillée' do
      @w.support_line.update_attribute(:locked, true)
      @frontline = Request::Frontline.fetch(@ib.id, from_date, to_date).first
      @frontline.should_not be_editable
    end
    
     
    
    
  end
  
end
