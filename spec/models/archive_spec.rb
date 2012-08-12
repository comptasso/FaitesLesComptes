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

   
  end

end

