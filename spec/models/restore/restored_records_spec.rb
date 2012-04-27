# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml' 
require File.expand_path(File.dirname(__FILE__) + '/../../support/similar_model.rb')




describe Restore::RestoredRecords do
  before(:each) do
    f = File.dirname(__FILE__) + '/../../test_compta.yml' 
    File.open(f, 'r') do |f|
      @datas = YAML.load(f)
    end
    @rc = Restore::RestoredCompta.new(@datas) 
  end

 
  it 'compta référence le restore_compta' do
    @rr = Restore::RestoredRecords.new(@rc)
    @rr.compta.should == @rc 
  end

  describe 'ability to analyse and build a record to restore' do

   


    before(:each) do
      @rr = Restore::RestoredRecords.new(@rc)
      @d = @datas[:destinations].first
       @rc.create_organism
    end

    describe 'similar_to' do

      it 'deux destinations identiques should be_similar' do
        @d.should be_similar_to @d
      end

      it '@d et la restoration de @d devraient être similaires' do
        @rr.restore_array(@datas[:destinations])
        @rr.all_records.first.should be_similar_to @d
      end

    end

    describe 'restore_array' do

      it 'le tableau reconstruit  a la même taille que la source' do
        @rr.restore_array(@datas[:destinations]).should == @datas[:destinations].size
      end

      it 'chaque élément est de même type' do
        @rr.restore_array(@datas[:destinations])
        @rr.all_records.each {|r| r.should be_an_instance_of(Destination)}
      end

      it 'chaque record doit être similaire à la source' do
        @rr.restore_array(@datas[:destinations])
        @rr.all_records.each_with_index { |r,i| r.similar_to?(@datas[:destinations][i]).should be_true }
        @rr.all_records.each_with_index {|r, i| r.should be_similar_to @datas[:destinations][i] }
      end


    end
  end

end