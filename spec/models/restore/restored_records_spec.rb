# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'

describe Restore::RestoredRecords do
  before(:each) do
    f = File.dirname(__FILE__) + '/../../test_compta.yml'
    @rc = Restore::RestoredCompta.new(f)
    File.open(f, 'r') do |f|
      @datas = YAML.load(f)
    end
  end

 it 'restore a simple record record' do
    @rc.create_organism
    @rc.restores[:organism].compta.should == @rc
    @rc.restores[:organism].records.first.should be_an_instance_of(Organism)
  end

  it 'restore record knows the compta' do
    pending
  end

end