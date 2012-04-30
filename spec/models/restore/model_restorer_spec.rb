# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'

describe Restore::ModelRestorer do
  before(:each) do
    f = 'spec/fixtures/files/test_compta2.yml'
    File.open(f, 'r') do |f|
      @datas = YAML.load(f)
    end
    @rc = Restore::ComptaRestorer.new(@datas)
    @rc.compta_restore
  end

  it 'create organism should skip call backs' do
    expect { @rc.restores[:organism] }.not_to change{Book.count}
  end

 
  it 'restore compta create a restore model by create_organism' do
    @rc.restores[:organism].should be_an_instance_of(Restore::ModelRestorer)
    @rc.restores[:organism].records.first.title.should == @datas[:organism].title
    @rc.restores[:organism].records.first.id.should_not == @datas[:organism].id
  end

  it 'restore model knows the compta' do
    @rc.restores[:organism].compta.should == @rc
  end

  it 'can give access to the restored_records' do
    @rc.restores[:organism].id_records.should == [{:old_id=>@datas[:organism].id, :record=>@rc.restores[:organism].records.first }]
  end

  

end