# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Archive do
  before(:each) do
    @archive = Archive.new
    @file_name = 'spec/test_compta.yml'

  end

  context 'creation of an archive' do


  
  describe "title" do
    before(:each) do
      @org=Organism.create(title: 'test spec')
      @archive=@org.archives.new
      @archive.save!
    end


    it 'title doit etre consitué du titre et du timestamp' do
      d=@archive.created_at.to_s
      e=d[/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/].gsub(' ', '_')
      @archive.title.should == 'test_spec_' + e + '_UTC'
    end
  end

  end


  context 'rebuild from an archive' do

    it 'archive is able to create a restored_compta' do
      @archive.restore_compta(@file_name).should be_an_instance_of Restore::RestoredCompta

    end

    context 'restore_compta has been called' do
      before(:each) do
        @archive.restore_compta(@file_name)
      end

    it 'archive can ask the restored compta the datas read' do
      @archive.datas.should be_an_instance_of(Hash)
    end

    it 'can read indivual arrays' do
      @archive.datas[:destinations].should be_an_instance_of(Array)
    end

    it 'can read restored models' do
      @archive.rebuild_all_records
      @archive.restores(:destinations).should have(7).elements
      @archive.restores(:natures).each {|n| puts n.inspect}
      @archive.restores(:lines).should have(@archive.datas[:lines].size).elements
    end
end

  end
end

