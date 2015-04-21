# coding: utf-8

require 'spec_helper'


# To change this template, choose Tools | Templates
# and open the template in the editor.
RSpec.configure do |c| 
  #  c.filter = {:wip => true }
  #  c.exclusion_filter = {:js=> true }
end

describe 'Request::FrontLine' do
  include OrganismFixtureBis
  
  before(:each) do
    @book_id = 1
    @from_date = Date.today.beginning_of_year
    @to_date = Date.today.end_of_year
  end
  
  it 'execute la requête' do
    Request::Frontline.fetch(@book_id, @from_date, @to_date)
  end
  
  context 'avec un adhérent et un paiement' do
    before(:each) do
      use_test_organism 
      @am = Adherent::Member.create!(name:'Dupont',
        forname:'Aline', number:'002', organism_id:@o.id)
      @pay = @am.payments.create!(date:Date.today, amount:11, mode:'CB')
    end
    
    after(:each) do
      Adherent::Member.delete_all
    end
    
    it 'la requete renvoie une ligne' do
      rfl = Request::Frontline.fetch(@ib.id, @from_date, @to_date)
      expect(rfl.size).to eq(1)
    end
    
    describe 'les attributs' do
      before(:each) do
        @tuple = Request::Frontline.fetch(@ib.id, @from_date, @to_date).first
      end
      
      it 'sont correct' do 
        expect(@tuple.writing_type).to eq('Adherent::Writing')
        expect(@tuple.nature_name).to eq('Cotisations des adhérents')
        expect(@tuple.date).to eq(Date.today)
        expect(@tuple.destination_name).to eq('Adhérents')
        expect(@tuple.payment_mode).to eq('CB')
        expect(@tuple.credit).to eq(11)
        expect(@tuple.adherent_payment_id).to eq(@pay.id)
        expect(@tuple.adherent_member_id).to eq(@am.id)
        expect(@tuple.member_id).to eq(@am.id)
      end
    end
    
    context 'quand l adhérent a été supprimé' do
      before(:each) do
        @amid = @am.id
        @am.destroy
        @tuple = Request::Frontline.fetch(@ib.id, @from_date, @to_date).first
      end
      
      it 'adherent_member_id est présent mais pas member_id' do
        expect(@tuple.adherent_member_id).to eq(@amid)
        expect(@tuple.member_id).to be_nil
      end
    end
  end
end
