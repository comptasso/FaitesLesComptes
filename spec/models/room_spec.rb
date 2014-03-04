# -*- encoding : utf-8 -*-
require 'spec_helper' 

RSpec.configure do |c| 
   c.filter = {wip:true}
end

describe Room  do
  include OrganismFixtureBis   

  let(:u) {stub_model(User)}

  def valid_attributes
    {database_name:'foo_11112233444555'}
  end

  before(:each) do
    Apartment::Database.reset
  end

  it 'test de l existence des bases'  do
    Apartment::Database.db_exist?('public').should == true
  end

  describe 'les validations' do

    before(:each) do
      Room.any_instance.stub(:user).and_return u
    end

    it 'has a user' do
      Room.new.should_not be_valid
    end

    it 'has a database_name' do
      u.rooms.new.should_not be_valid
    end

    it 'database_name is composed of min letters without space - les chiffres sont autorisés mais pas en début' do
      val= ['nom base', 'Nombase', '1nom1base', 'nombase%']
      val.each do |db_name|
        u.rooms.new(database_name:db_name).should_not be_valid
      end
      u.rooms.new(database_name:'unnomdebasecorrect').should be_valid
      
    end

    it 'le nom est strippé avant la validation' do
      u.rooms.new(database_name:'  unnomdebasecorrect  ').should be_valid
    end

    context 'avec un nom correct, la création de la room' do
      
      before(:each) do
        unnom = 'unnomdebasecorrect'
        @new_room = u.rooms.new(database_name:unnom)
        @new_room.save
      end
      
      after(:each) do
        Apartment::Database.drop(@new_room.database_name) if Apartment::Database.db_exist?(@new_room.database_name)
      end
    
      it 'entraîne celle du schéma' do
        Apartment::Database.db_exist?(@new_room.database_name).should == true
      end
          
    end

  end

  describe 'methods' do
    
    subject {Room.new(:database_name=>'foofoo_19991212123456')}

    it 'racine' do
      subject.racine.should == 'foofoo'
    end
    
    it 'racine=' do
      subject.racine = 'barabar'
      subject.database_name.should =~ /\Abarabar_\d{14}\z/
    end


    it 'la base est en retard si organism_migration est inférieure à room' do
      omv = Organism.migration_version
      subject.stub(:look_for).and_return omv
      Room.should_receive(:jcl_last_migration).and_return(omv+1)
      subject.relative_version.should == :late_migration
    end
    
    it 'en phase si les deux migrations sont égales' do
      omv = Organism.migration_version
      subject.stub(:look_for).and_return omv
      Room.stub(:jcl_last_migration).and_return(omv)
      subject.relative_version.should == :same_migration
    end
    
    it 'en avance si organism_migration est supérieure à celle de room' do
      omv = Organism.migration_version
      subject.stub(:look_for).and_return omv
      Room.stub(:jcl_last_migration).and_return(omv-1)
      subject.relative_version.should == :advance_migration
    end

    it 'et renvoie no_base si elle n est pas trouvée' do
      subject.stub(:look_for).and_return nil
      subject.relative_version.should == :no_base
    end
 
    it 'sait répondre aux questions late?, no_base? et advance_migration?' do
      subject.stub(:relative_version).and_return :late_migration
      subject.should be_late
      subject.stub(:relative_version).and_return :advance_migration
      subject.should be_advanced
      subject.stub(:relative_version).and_return :no_base
      subject.should be_no_base
    end

  end

  describe 'tools' do
    before(:each) do
      create_user 
    end
    
    it 'liste des schemas'  do
      puts Apartment::Database.list_schemas      
    end

    describe 'connnect_to_organism' , wip:true do
      it 'connect_to_organism retourne true si la base existe' do
        @r.connect_to_organism.should be_true
      end

      it 'appelle Apartment.reset si le fichier n est pas trouvé' do
        @r.database_name = nil
        @r.connect_to_organism
        Apartment::Database.current.should == "public" 
      end
     
    end    

    describe 'look_for' do

      it 'retourne la valeur demandée par le bloc'  do
        Organism.should_receive(:first).and_return('Voilà')
        @r.look_for {Organism.first}.should == 'Voilà'
      end


    end

    describe 'organism' do
      it 'retourne l organisme correspondant à cette base' do
        Organism.stub(:first).and_return('un organisme')
        @r.organism.should == 'un organisme'
      end
    end


    describe 'gestion des schemas'  do
      before(:each) do
        create_user
        create_organism
        Apartment::Database.switch('public') 
        
      end
         

      it 'un changement de nom de base est interdit' do
        @r.racine = 'newvalue'
        @r.should_not be_valid
      end

      

    end



  end

  describe 'version_update'  do 

    it 'version_update? est capable de vérifier la similitude des versions' do
      ActiveRecord::Migrator.any_instance.stub(:pending_migrations).and_return ['quelquechose']
      Room.should_not be_version_update
    end

    it 'version_update? retourne true s il n y a pas de migration en attente' do
      ActiveRecord::Migrator.any_instance.stub(:pending_migrations).and_return []
      Room.should be_version_update
    end


  end

    

  describe 'verification des bases après les tests de room' do

    it 'la base assotest1 doit exister' do
      Apartment::Database.db_exist?(SCHEMA_TEST).should be_true
    end


  end
end
