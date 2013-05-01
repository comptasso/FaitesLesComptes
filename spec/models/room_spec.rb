# -*- encoding : utf-8 -*-
require 'spec_helper' 

describe Room do
  include OrganismFixture

  let(:u) {stub_model(User)}

  def valid_attributes
    {database_name:'foo'}
  end

  it 'has a user' do 
    Room.new.should_not be_valid 
  end

  it 'has a database_name' do
    u.rooms.new.should_not be_valid
  end

  it 'database_name is composed of min letters without space - les chiffres sont autorisés mais pas en début' do
    val= ['nom base', 'Nombase', '1nom1base', 'nombase%']
    val.each do
      u.rooms.new(database_name:val).should_not be_valid
    end
    u.rooms.new(database_name:'unnomdebasecorrect').should be_valid
    u.rooms.new(database_name:'unnom2basecorrect').should be_valid
  end

  it 'le nom de base doit être unique' do
    u.rooms.find_or_create_by_database_name('foo')
    r = u.rooms.new(valid_attributes)
    r.should_not be_valid
    r.errors.messages[:database_name].should == ['déjà utilisé']
  end

  describe 'methods' do

    before(:each) do
      @r = Room.new(:database_name=>'foo')
    end

    it 'db_filename construit le nom de la base de donnée' do
      Rails.application.config.should_receive(:database_configuration).and_return({'test'=>{'adapter'=>'monadapteur'} })
      @r.db_filename.should == 'foo.monadapteur'
    end

    it 'absolute_db_name retourne le chemin complet de la base' do
      Room.stub(:path_to_db).and_return('mon_chemin')
      @r.absolute_db_name.should == File.join('mon_chemin', @r.db_filename)
    end

    it 'la base est en retard si organism_migration est inférieure à room' do
      omv = Organism.migration_version
      @r.stub(:look_for).and_return omv
      Room.should_receive(:jcl_last_migration).and_return(omv+1)
      @r.relative_version.should == :late_migration
    end
    
    it 'en phase si les deux migrations sont égales' do
      omv = Organism.migration_version
      @r.stub(:look_for).and_return omv
      Room.stub(:jcl_last_migration).and_return(omv)
      @r.relative_version.should == :same_migration
    end
    
    it 'en avance si organism_migration est supérieure à celle de room' do
      omv = Organism.migration_version
      @r.stub(:look_for).and_return omv
      Room.stub(:jcl_last_migration).and_return(omv-1)
      @r.relative_version.should == :advance_migration
    end

    it 'et renvoie no_base si elle n est pas trouvée' do
      @r.stub(:look_for).and_return nil
      @r.relative_version.should == :no_base
    end
 
    it 'sait répondre aux questions late?, no_base? et advance_migration?' do
      @r.stub(:relative_version).and_return :late_migration
      @r.should be_late
      @r.stub(:relative_version).and_return :advance_migration
      @r.should be_advanced
      @r.stub(:relative_version).and_return :no_base
      @r.should be_no_base
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
      it 'connect_to_organism retourne true si la base existe' do
        @r.connect_to_organism.should be_true
      end

      it 'renvoie false si le fichier n est pas trouvé' do
        File.stub(:exist?).and_return false
        @r.connect_to_organism.should be_false
      end

      it 'peut se faire avec enter et l id de la Room' do
        Room.should_receive(:find_by_id).with(5).and_return(double(Room, :enter=>true))
        Room.enter(5).should be_true
      end

      it 'renvoie nil si l id n existe pas' do
        Room.should_receive(:find_by_id).with(5).and_return(nil)
        Room.enter(5).should be_nil
      end
      
      
    end

    describe 'create_db' do
      it 'room peut créer une base de données' do
      @r.create_db
    end


    end

    describe 'check_db' do

      it 'check_db contrôle l intégrité de la base' do
        @r.stub(:connect_to_organism).and_return true
        ActiveRecord::Base.connection.should_receive(:execute).with('pragma integrity_check').and_return(['integrity_check'=>'ok'])
        @r.check_db.should be_true
      end

      it 'indique si pas de réponse' do
        @r.stub(:connect_to_organism).and_return true
        ActiveRecord::Base.connection.should_receive(:execute).with('pragma integrity_check').and_return('n importe quoi')
        @r.check_db.should be_false
      end

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


    describe 'version_update and migrate_each' do

      before(:each) do
        Room.find_each {|r| r.destroy}
        @r1 = Room.find_or_create_by_user_id_and_database_name(1, 'assotest1')
        @r2 = Room.find_or_create_by_user_id_and_database_name(1, 'assotest2')
        @r1.look_for {Organism.create!(:title =>'Test ASSO',  database_name:'assotest1',  :status=>'Association') if Organism.all.empty?}
        @r2.look_for {Organism.create!(:title =>'Test ASSO',  database_name:'assotest2',  :status=>'Association') if Organism.all.empty?}
        ActiveRecord::Migrator.any_instance.stub(:pending_migrations).and_return [1]
      end

      it 'met à jour la version' do
        # 3 fois car une fois pour la base principale et une fois pour chaque organisme
        ActiveRecord::Migrator.should_receive(:migrate).with(ActiveRecord::Migrator.migrations_paths).exactly(3).times
        Room.migrate_each
      end

      it 'version_update? est capable de vérifier la similitude des versions' do
        Room.should_not be_version_update
      end

    end
  end

end
