# -*- encoding : utf-8 -*-
require 'spec_helper' 

describe Room do
  include OrganismFixture 

  def valid_attributes
    {user_id:1, database_name:'foo'}
  end

  it 'has a user' do 
    Room.new.should_not be_valid 
  end

  it 'has a database_name' do
    Room.new(user_id:1).should_not be_valid
  end

  it 'database_name is composed of min letters without space - les chiffres sont autorisés mais pas en début' do
    val= ['nom base', 'Nombase', '1nom1base', 'nombase%']
    val.each do
      Room.new(user_id:1, database_name:val).should_not be_valid
    end
    Room.new(user_id:1, database_name:'unnomdebasecorrect').should be_valid
    Room.new(user_id:1, database_name:'unnom2basecorrect').should be_valid
  end

  it 'le nom de base doit être unique' do
    Room.find_or_create_by_user_id_and_database_name(1, 'foo')
    Room.new(valid_attributes).should_not be_valid 
  end

  describe 'methods' do

    before(:each) do
      @r = Room.find_or_create_by_user_id_and_database_name(1, 'foo')
    end

    it 'db_filename calls the database_configuration' do
      Rails.application.config.should_receive(:database_configuration).and_return({'test'=>{'adapter'=>'monadapteur'} })
      @r.db_filename.should == 'foo.monadapteur'
    end

    it 'absolute db_name' do
      Room.stub(:path_to_db).and_return('mon_chemin')
      @r.absolute_db_name.should == File.join('mon_chemin', @r.db_filename)
    end

  end

  describe 'tools' do
    before(:each) do
      @r = Room.find_or_create_by_user_id_and_database_name(1, 'assotest1')
    end

    describe 'look_forg' do

      it 'should comme back using the main connection' do
        cc = ActiveRecord::Base.connection_config
        Organism.stub(:first).and_return(double(Organism, accountable?:true))
        @r.look_forg {"accountable?"}
        ActiveRecord::Base.connection_config.should == cc 
      end

      it 'should connect to la base assotest1' do
        Organism.stub(:first).and_return(double(Organism, accountable?:true))
        @r.should_receive(:connect_to_organism).and_return true
        @r.look_forg {"accountable?"}
      end

      it 'retourne la valeur trouvée' do
        
        Organism.should_receive(:first).and_return(double(Organism, accountable?:25))
        @r.look_forg {"accountable?"}.should == 25
      end


    end

    describe 'connnect_to_organism' do
      it 'connect_to_organism retourne false ou true'

      it 'check_db'
    end

    describe 'look_for' do

      it 'retourne la valeur demandée par le bloc' do
        Organism.should_receive(:first).and_return('Voilà')
        @r.look_for {Organism.first}.should == 'Voilà'
      end


    end

    describe 'organism' do
      it 'retourne l organisme correspondant à cette base' do
        @r.should_receive(:connect_to_organism).and_return true
        Organism.should_receive(:first).and_return(@o = double(Organism))
        @r.organism.should == @o
      end
    end


    describe 'migrate_each' do

      before(:each) do
        Room.find_each {|r| r.destroy}
        @r1 = Room.find_or_create_by_user_id_and_database_name(1, 'assotest1')
        @r2 = Room.find_or_create_by_user_id_and_database_name(1, 'assotest2')
        @r1.look_for {Organism.create!(:title =>'Test ASSO',  database_name:'assotest1',  :status=>'Association') if Organism.all.empty?}
        @r2.look_for {Organism.create!(:title =>'Test ASSO',  database_name:'assotest2',  :status=>'Association') if Organism.all.empty?}
      end

      

      it 'met à jour la version' do
        
        @r1.connect_to_organism
        Organism.first.update_attribute(:version, 'test')
        @r1.organism.version.should == 'test'
        @r2.connect_to_organism.should be_true
        Organism.create!(title:'mon asso', database_name:'assotest2', status:'Association' ) if Organism.all.empty?
        Organism.first.update_attribute(:version, 'test')
        @r2.organism.version.should == 'test'

        Room.migrate_each
        @r1.organism.version.should == VERSION
        @r2.organism.version.should == VERSION
      end

      it 'version_update? est capable de vérifier la similitude des versions' do
        Room.should be_version_update
        @r2.organism.update_attribute(:version, 'test')
        Room.should_not be_version_update
      end

    end
  end

end
