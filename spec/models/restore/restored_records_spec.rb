# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'

LINE_ATTRIBUTES =  ["id", "line_date", "narration", "nature_id", "destination_id",
  "debit", "credit", "book_id", "locked", "created_at", "updated_at",
  "copied_id", "multiple", "bank_extract_id", "payment_mode",
  "check_deposit_id", "cash_id", "bank_account_id"]


describe Restore::RestoredRecords do
  before(:each) do
    f = File.dirname(__FILE__) + '/../../test_compta.yml' 
    
    File.open(f, 'r') do |f|
      @datas = YAML.load(f)
    end
    @rc = Restore::RestoredCompta.new(@datas)
  end

 it 'restore a simple record record' do
    @rc.create_organism
    @rc.restores[:organism].compta.should == @rc
    @rc.restores[:organism].records.first.should be_an_instance_of(Organism) 
  end

  it 'restore record knows the compta' do
    @rr = Restore::RestoredRecords.new(@rc)
    @rr.compta.should == @rc 
  end

  describe 'ability to analyse and build a record to restore' do

    before(:each) do
      @rr = Restore::RestoredRecords.new(@rc)
      @d = @datas[:destinations].first
    end

    describe 'rebuild new attributes' do

      it 'recrée une une destination' do
       @rc.create_organism 
       d =  @rr.restore(@d)
       d.first[:record].should be_an_instance_of(Destination)
      end

      it 'recrée children et subchildren' do
        @rc.create_organism
        @rc.create_direct_children
         @rc.create_sub_children
         @rc.restores[:natures].records.should have(@datas[:natures].size).elements
      end

      it 'recrée une ligne' do
        @l=@datas[:lines].first
        puts @l.inspect
         @rc.create_organism
        @rc.create_direct_children
        @rc.create_sub_children
        @rc.restores.restore(@l).records.first.should be_an_instance_of(Line)

      end

    end
  end

end