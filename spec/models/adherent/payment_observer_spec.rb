# To change this template, choose Tools | Templates
# and open the template in the editor.

# coding: utf-8

require 'spec_helper'   

RSpec.configure do |c| 
  #  c.filter = {:wip=>true}
end

describe Adherent::Payment do 
  include OrganismFixtureBis

  def create_member
    @m = @o.members.create!(number:'001', name:'Dupont', forname:'Jean')
  end
  
  def create_destination_for_adherent  
    @o.destinations.create!(name:'Adhérents') 
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
  
  describe 'lien entre payment et writing' do 
  
    it 'sauvegarder un payment crée un in_out_writing' do
      p = @m.payments.new(date:Date.today, amount:125.25, mode:'CB')
      expect {p.save}.to change {InOutWriting.count}.by(1)
    end 
  
    it 'crée une écriture conforme aux infos entrées dans le payment'
    
  end
  
end
