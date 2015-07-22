# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe User do

  let(:o) {mock_model(Organism)}

  def valid_attributes_for_user
    {name:'Jean-Claude', email:'bonjour@example.com', password:'Bonjour53'}
  end

  before(:each) do
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

    it 'non valide sans role' do
      @u.role = nil
      @u.should_not be_valid
    end

    it 'un user peut etre expert' do
      @u.role = 'expert'
      @u.should be_valid
    end

    it 'mais pas autre chose que standard et expert' do
      @u.role = 'autrrechose'
      @u.should_not be_valid
    end

    it 'mais juste comme il faut' do
     @u.valid?
     puts @u.errors.messages unless @u.valid?
     @u.should be_valid

    end

  end


  describe 'allowed_to_create_organism' do

    subject {u = User.new(); u.role = 'standard'; u}

    it 'si moins de 4 rooms pour un user standard' do
      pending 'à finaliser avec noschema'
      subject.stub(:holders).and_return(@ar = double(Arel))
      @ar.stub(:where).and_return [1,2,3]
      subject.should be_allowed_to_create_room
    end

    it 'sans limite pour un user expert' do
      pending 'à finaliser avec noschema'
      subject.role = 'expert'
      subject.should be_allowed_to_create_room
    end

    it 'mais pas si 4 ou plus pour un user standard' do
      pending 'à finaliser avec noschema'
      subject.stub(:holders).and_return(@ar = double(Arel))
      @ar.stub(:where).and_return [1,2,3,4]
      subject.allowed_to_create_room?.should == false
    end


  end

end
