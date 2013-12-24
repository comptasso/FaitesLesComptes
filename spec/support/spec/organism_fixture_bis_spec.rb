# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
   c.filter = {wip:true}
end

# fichier destiné à tester les méthodes de support

describe OrganismFixtureBis do 
  include OrganismFixtureBis


  describe 'create_user' do
  

    before(:each) do
      create_user
    end


    it 'should create a user' do
      @cu.should be_an_instance_of(User)
    end

    it 'should create room' do
      @r.should be_an_instance_of(Room)
    end

    it 'les deux sont reliées' do
      @cu.rooms.should == [@r]
      @cu.rooms.first.should == @r
    end


  end

  describe 'create_organism' do
    before(:each) do
      create_organism
    end

    it 'a un organisme dans la base assotest1' do
      Apartment::Database.switch('assotest1')
      Organism.should have(1).elements
    end
    
    it 'et n en a pas dans la base principale' do
      pending 'il y a une création d organisme dans la base principale'
      Apartment::Database.switch()
      Organism.should have(0).elements
    end

    it '@o représente cet organisme' do
      @o.should be_an_instance_of(Organism)
    end
    
    it 'les instances existent' , wip:true do
    @ba.should be_an_instance_of(BankAccount) 
    @ib.should be_an_instance_of(IncomeBook) 
    @od.should be_an_instance_of(OdBook)
    
    @c.should be_an_instance_of(Cash)
    @baca.should be_an_instance_of(Account) # pour baca pour BankAccount Current Account
    @caca.should be_an_instance_of(Account)  # pour caca pour CashAccount Current Account
    @n.should be_an_instance_of(Nature)
    end


  end

  

  describe 'create_minimal_organism' do
    before(:each) do
      create_minimal_organism
    end

    it 'check organism' do
      Organism.count.should == 1
      @o.should be_an_instance_of(Organism)
    end

    it 'remplit les variables d instance' do
      @ib.should be_an_instance_of(IncomeBook)
    end


  end


end