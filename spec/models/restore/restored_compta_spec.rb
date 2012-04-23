# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'

describe Restore::RestoredCompta do

  describe 'creation' do
    before(:each) do
      f = File.dirname(__FILE__) + '/../../test_compta.yml'
      @rc = Restore::RestoredCompta.new(f)
      File.open(f, 'r') do |f|
        @datas = YAML.load(f)
      end
    end

    it 'check values' do
      @datas.should have(17).elements
      @datas[:organism].should be_an_instance_of(Organism)
    end

    it 'restore compta is created with a file to load' do
      @rc.should be_an_instance_of(Restore::RestoredCompta)
    end

    it 'has attribute basename' do
      @rc.basename.should == 'test_compta.yml'
    end

    it 'can read test_compta.yml' do
      pending
      # @rc.file_name.should ==
    end

    it 'can_build datas' do
      @rc.datas.should have(17).elements  
    end

   

    it 'check initilize restored_records' do  
      Organism.count.should == 0
      @datas[:organism].title.should == 'Mes comptes perso restauration'  
      rr = Restore::RestoredRecords.new
      expect {rr.restore_data(@datas[:organism])}.to change {Organism.count}
    end

    

    it 'create organism should skip call backs' do 
      expect {@rc.create_organism}.not_to change{Book.count}
    end

    it 'create direct children' do
      @rc.create_organism
      expect {@rc.create_child(:destinations)}.to change{Destination.count}.by(@datas[:destinations].size)
      @rc.restores[:destinations].records.each do |d|
        d.organism_id.should == @rc.organism_new_id
      end
    end

    
    it 'create_all_direct_children' do
      @rc.create_organism
      @rc.create_all_direct_children
      @rc.restores[:destinations].should have(@datas[:destinations].size).records
      @rc.restores[:income_books].should have(@datas[:income_books].size).records
      @rc.restores[:income_books].records.first.title.should == 'Recettes'
      @rc.restores[:income_books].records.first.organism_id.should == @rc.organism_new_id
    end

    # on vérifie avec le controle de caisse, enfant de caisse, qu'il existe
    # puis qu'on peut bien le retrouver en descendant l'arborescence organism->cash->cash_control
    it 'create_sub_children' do
      @rc.create_organism
      @rc.create_all_direct_children
      @rc.create_sub_children
      @rc.restores[:cash_controls].records.should have(1).element
      @rc.restores[:organism].records.first.cashes.first.cash_controls.first.should == @rc.restores[:cash_controls].records.first
    end



  end
end
