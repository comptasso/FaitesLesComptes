# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Archive do
  include OrganismFixture

  before(:each) do
    create_minimal_organism
    @archive = @o.archives.new
    @archive.save!
  end
 
  context 'creation of an archive' do
 
    it 'title doit etre consitué du titre et du timestamp' do
      d=@archive.created_at.to_s
      e=d[/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/].gsub(' ', '_')
      @archive.title.should == "#{@o.title.split(' ').join('_')}_" + e + '_UTC'
    end

    it 'archive can ask the restored compta the datas read' do
      @archive.collect_datas
      @archive.collect.should be_an_instance_of(Hash)
    end

    it 'can read indivual arrays' do  
      @archive.collect_datas
      @archive.collect[:destinations].should be_an_instance_of(Array)
    end


    describe 'collect_datas' do

      it 'MODELS should be define' do
        MODELS.size.should == 16
      end
      
      it 'should called each model' do
       expect { @archive.collect_datas}.not_to raise_error
      end
      
    end
  end

end

