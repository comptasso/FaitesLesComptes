# coding: utf-8

require 'spec_helper'

describe User do
  
  let(:o) {mock_model(Organism)}

  def valid_attributes_for_user
    {name:'Jean-Claude', email:'bonjour@example.com', password:'Bonjour53'}
  end

  before(:each) do
    Apartment::Database.switch()
    User.delete_all
    @u = User.new(valid_attributes_for_user)
  end

  describe 'validations' do
  
    it 'exige un nom' do
      @u.name =  nil
      @u.should_not be_valid
      @u.should have(3).errors_on(:name) # Obligatoire, caractère non admis et trop court
    end

    it 'ni trop court' do
      @u.name ='Ab'
      @u.should_not be_valid
      @u.errors.messages[:name].should == ['Trop court']
    end

     it 'ni trop long' do
      @u.name ='Abcdefghijklmnopqrstuvwxyzabcde'
      @u.should_not be_valid
      @u.errors.messages[:name].should == ['Trop long']
    end

     it 'ni avec des caractères interdits' do
      @u.name ='Abc\\de'
      @u.should_not be_valid
      @u.errors.messages[:name].should == ['Caractères non admis']
    end

    it 'non valide sans e_mail' do
      @u.email = 'super'
      @u.should_not be_valid
      @u.errors.messages[:email].should == ['Caractères non admis']
    end

    it 'non valide sans password' do
      @u.password = nil
      @u.should_not be_valid
      @u.errors.messages[:password].should == ['obligatoire']
    end

    it 'mais juste comme il faut' do
     @u.valid?
     puts @u.errors.messages unless @u.valid?
     @u.should be_valid

    end

  end

  describe 'up_to_date' do

    it 'est à jour s il n y a pas de base' do
      
      @u.stub(:status).and_return []
      @u.should be_up_to_date
    end

    it 'est à jour si status retourne [:same_migration]' do
      @u.stub(:status).and_return [:same_migration]
      @u.should be_up_to_date
    end

    it 'ne l est pas autrement' do
      @u.stub(:status).and_return [:same_migration, :late]
      @u.should_not be_up_to_date
    end


  end

  describe 'organisms_with_rooms' do

    it 'forme un hash avec les rooms du User' do
    @u.stub(:rooms).and_return([@r = mock_model(Room, :organism=>o)])
    @u.organisms_with_room.should == [{:organism=>o, :room=>@r}]
    end

  end

  describe 'accountable_organisms_with_rooms' do
    before(:each) do
      @r = mock_model(Room, :organism=>o)
      @u.stub(:organisms_with_room).and_return [{:organism=>o, :room=>@r}]
    end


    it 'garde les organismes si accountabls?' do
      @r.stub(:look_for).and_return true
      @u.accountable_organisms_with_room.should ==  [{:organism=>o, :room=>@r}]

    end

    it 'mais le retire sinon' do
      @r.stub(:look_for).and_return false
      @u.accountable_organisms_with_room.should ==  []
    end

  end

  describe ':status' do
    it 'appelle rooms et relative version' do
      @u.stub(:rooms).and_return([mock_model(Room, :relative_version=>:same_migration), mock_model(Room, :relative_version=>:late)])
      @u.status.should == [:same_migration, :late]
    end

    it 'et compacte la réponse' do
      @u.stub(:rooms).and_return([mock_model(Room, :relative_version=>:same_migration), mock_model(Room, :relative_version=>:same_migration)])
      @u.status.should == [:same_migration]
    end


  end
  
end
