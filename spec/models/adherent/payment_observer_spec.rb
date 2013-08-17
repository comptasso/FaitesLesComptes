# To change this template, choose Tools | Templates
# and open the template in the editor.

# coding: utf-8

require 'spec_helper'   

RSpec.configure do |c| 
  c.filter = {:wip=>true}
end

describe Adherent::Payment do 
  include OrganismFixtureBis 

  def create_member
    @m = @o.members.create!(number:'001', name:'Dupont', forname:'Jean')
  end
  
  def create_destination_for_adherent  #
    @dest = @o.destinations(true).create(name:'Adhérents')
    #|| @o.destinations.create!(name:'Adhérents') 
   
  end
  

  before(:each) do
    create_organism 
    create_member
    create_destination_for_adherent 
  end
  
  it 'on peut enregistrer un payement' do
    p = @m.payments.new(date:Date.today, amount:125.25, mode:'CB')
    expect {p.save}.to change {Adherent::Payment.count}.by(1) 
  end
  
  describe 'la création de payement' do 
    
    before(:each) do
      @pay = @m.payments.new(date:Date.today, amount:125.25, mode:'CB')
    end
  
    it 'crée un in_out_writing' do
      expect {@pay.save}.to change {InOutWriting.count}.by(1)
    end 
  
    it 'crée une écriture conforme aux infos entrées dans le payment' do
      @pay.save
      w = InOutWriting.last
      w.book.should == @ib
      w.narration.should == "Payment adhérent Jean Dupont"
      w.date.should == Date.today
      
     clf =  w.compta_lines.first
     clf.credit.should == @pay.amount
     clf.destination.should == @dest
     clf.nature.name.should == 'Cotisations des adhérents'
     clf.debit.should == 0.0
     
      sl = w.support_line
      sl.account.accountable.class.should == BankAccount
      sl.nature_id.should == nil
      sl.destination_id.should == nil
      sl.debit.should == @pay.amount
      sl.credit.should == 0.0
    end
    
    it 'avec un chèque le accountable est bien remise de chèque' do
      @m.payments.create!(date:Date.today, amount:125.25, mode:'Chèque')
      sl = InOutWriting.last.support_line
      sl.account.should == @p.rem_check_account
    end
    
    it 'et espèces avec des espèces' do
      @m.payments.create!(date:Date.today, amount:125.25, mode:'Espèces')
      sl = InOutWriting.last.support_line
      sl.account.accountable.class.should == Cash
    end
    
  end
  
  describe 'mise à jour de payement', wip:true do
    
    before(:each) do
      @pay = @m.payments.create!(date:Date.today, amount:125.25, mode:'CB')
      @writing_pay = InOutWriting.last
    end
    
    it 'n est pas possible si écriture validée' do
      @writing_pay.lock
      @pay.amount = 135.45
      @pay.save
      Adherent::Payment.last.amount.should == 125.25
    end
    
    it 'met à jour les informations dans le cas contraire'
  end
  
end
