# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml' 
require File.expand_path(File.dirname(__FILE__) + '/../../support/similar_model.rb')




describe Restore::RecordsRestorer do

 before(:each) do
    f ='spec/fixtures/files/test_compta2.yml'  
    File.open(f, 'r') do |f|
      @datas = YAML.load(f)
    end
    @rc = Restore::ComptaRestorer.new(@datas) 
  end

 
  it 'compta référence le restore_compta' do
    @rr = Restore::RecordsRestorer.new(@rc)
    @rr.compta.should == @rc  
  end

  it 'restore_organism' do
    @rr = Restore::RecordsRestorer.new(@rc)
    @o = mock_model(Organism, title: 'asso des essais', comment: 'mon premier essai')
    @o.stub(:attributes).and_return('id'=>"#{@o}_id", 'title'=>'asso des essais', 'description'=>'mon premier essai')
    expect { @rr.restore(@o) }.to change {Organism.count}
  end



  describe 'ability to analyse and build a record to restore' do 

     before(:each) do
       @rr = Restore::RecordsRestorer.new(@rc)
       @d = @datas[:destinations].first
       @rc.stub(:ask_id_for).and_return(1) 
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