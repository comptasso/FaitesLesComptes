# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'

describe Restore::RestoredModel do
  before(:each) do
    f = File.dirname(__FILE__) + '/../../test_compta.yml'
    File.open(f, 'r') do |f|
      @datas = YAML.load(f)
    end
    @rc = Restore::RestoredCompta.new(@datas)
  end
 
  it 'restore compta create a restore model by create_organism' do
      @rc.create_organism
      @rc.restores[:organism].should be_an_instance_of(Restore::RestoredModel)
      @rc.restores[:organism].records.first.title.should == @datas[:organism].title
      @rc.restores[:organism].records.first.id.should_not == @datas[:organism].id
    end

  it 'restore model knows the compta' do
    @rc.create_organism
    @rc.restores[:organism].compta.should == @rc
  end

  it 'can give access to the restored_records' do
    @rc.create_organism
    @rc.restores[:organism].id_records.should == [{:old_id=>@datas[:organism].id, :record=>@rc.restores[:organism].records.first }]
  end

  

end