# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Archive do
  include OrganismFixtureBis 

  before(:each) do
    create_minimal_organism
    @archive = @o.archives.new
 
  end

  describe 'préparation d une archive' do
    
    it 'archive_filename' do
      case ActiveRecord::Base.connection_config[:adapter]
      when 'sqlite3'
        @archive.archive_filename.should =~ /^assotest1[a-z0-9:\s]*\.sqlite3$/
      when 'postgresql'
        @archive.archive_filename.should =~ /^assotest1[a-z0-9:\s]*\.dump$/
      end
    end

    it 'si l adapter n est pas trouvé, retourne une erreur' do
      ActiveRecord::Base.stub(:connection_config).and_return({:adapter=>'inconnu'})
      expect {@archive.archive_filename}.to raise_error Apartment::AdapterNotFound
    end
    
  end


 
  context 'creation of an archive' do


 
    it 'title doit etre consitué du titre et du timestamp' do
      @archive.save!
      d=@archive.created_at.to_s
      e=d[/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/].gsub(' ', '_')
      @archive.title.should == "#{@o.title.split(' ').join('_')}_" + e + '_UTC'
    end

   
  end

end

