# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'
require File.expand_path(File.dirname(__FILE__) + '/../../support/similar_model.rb')

class RestoreError < StandardError; end


RSpec.configure do |c| 
  #  c.filter = {:wip => true }
end

describe Restore::ComptaRestorer do 

  
  describe 'creation' do

    before(:each) do
      File.open('spec/fixtures/files/test_compta2.yml', 'r') do |f|
        @datas = YAML.load(f)
      end
      @rc = Restore::ComptaRestorer.new(@datas)
    end

    it 'check values' do
      @datas.should have(19).elements
      @datas[:organism].should be_an_instance_of(Organism)
    end

    
   
    describe 'rebuild all records' do 

      before(:each) do
        @rc.compta_restore
        @ro = @rc.restores[:organism].records.first
        @do = @datas[:organism]
        # on part de MODELS mais on enlève books
        @plural_model = MODELS.map {|m| m.pluralize}
        @plural_model.delete('books')
      end

      it 'recreate organism similar to' do
        @ro.should be_similar_to @do
      end

      it 'with the exact number of records' do 
        @plural_model.each do |m|
          @rc.restores[m.to_sym].should_not be_nil
          @rc.restores[m.to_sym].should have(@datas[m.to_sym].size).records if @datas[m.to_sym]
        end
      end

      it 'all records are similar' do
        @plural_model.each do |m|
          @rc.restores[m.to_sym].records.each_with_index do |r, i|
             r.should be_similar_to @datas[m.to_sym][i]
          end
        end
      end

      it 'chek the arborescence' do
        @ro.destinations.should be_similar_to @datas[:destinations]
        @ro.natures.should be_similar_to @datas[:natures]
        @ro.income_books.should be_similar_to @datas[:income_books] 
      end

describe 'ask_for_if' do

      it 'returns the right value' do
        @rc.ask_id_for('organism', @datas[:organism].id).should == @rc.restores[:organism].records.first.id
        @rc.ask_id_for('destination', @datas[:destinations].first.id).should == @rc.restores[:destinations].records.first.id
      end

        it 'raise an error when the model is not there'  do
          expect { @rc.ask_id_for('model_inconnu', 1) }.to raise_error RestoreError,
            'Aucun enregistrement du type ModelInconnu'
        end

        it 'raise an error when the id is not present'  do
         
         expect { @rc.ask_id_for('destination', 999) }.to raise_error(RestoreError,
           'Impossible de trouver un enregistrement du type Destination avec comme id 999')
        end

end
      it 'checks balance' do
        pending 'en attente d avoir un fichier test structuré pour pouvoir utiliser la balance comme moyen de controle'

      end

   

    end

  end
end
