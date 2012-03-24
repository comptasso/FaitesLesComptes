# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Archive do
  before(:each) do
    @archive = Archive.new
  end

  context "with a malformatted file" do
    before(:each) do
       @file_name = 'spec/invalid_test_compta.yml'
       @file=File.open(@file_name, 'r')
    end

    after(:each) do
      @file.close
    end

    it "should raise Psych::Error" do
      @archive.parse_file(@file)
       @archive.errors.size.should > 0
    end

    it "archive should have errors" do
      @archive.parse_file(@file)
      @archive.errors[:base].should == ["Une erreur s'est produite lors de la lecture du fichier, impossible de reconstituer les données de l'exercice"]
    end

    it "check list_errors" do
      @archive.parse_file(@file)
      @archive.list_errors.should == "Une erreur s'est produite lors de la lecture du fichier, impossible de reconstituer les données de l'exercice"
    end

end

  
end

