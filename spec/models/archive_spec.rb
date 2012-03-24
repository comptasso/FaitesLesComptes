# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Archive do
  before(:each) do
    @archive = Archive.new
  end

  context "with a well formatted file" do
before(:each) do
       @file_name = 'spec/test_compta.yml'
       @file=File.open(@file_name, 'r')

    end

    after(:each) do
      @file.close
    end

    it "should parse the file" do
      expect {@archive.parse_file(@file)}.to_not raise_error
    end

    it "sould have one income and one outcome book" do
      @archive.parse_file(@file)
      @archive.datas[:income_books].size.should == 1
      @archive.datas[:outcome_books].size.should == 1
      @archive.datas[:income_books].first.should be_an_instance_of(IncomeBook)
      @archive.datas[:outcome_books].first.should be_an_instance_of(OutcomeBook)
    end
  end

  context "testing restore_line" do
    let(:ib) {mock_model(IncomeBook, title: 'Recettes')}
    let(:ob) {mock_model(OutcomeBook, title: 'Dépenses')}
    let(:new_ib) {mock_model(IncomeBook, title: 'Recettes')}
    let(:new_ob) {mock_model(OutcomeBook, title: 'Dépenses')}
    let(:line1) {mock_model(Line, book_id: ib.id)}
    let(:line2) {mock_model(Line, book_id: ob.id)}

    before(:each) do
#       @file_name = 'spec/invalid_test_compta.yml'
#       @file=File.open(@file_name, 'r')
#       @archive.parse_file(@file)
       @archive.datas[:books] = [ib,ob]
       @archive.restores[:books] = [new_ib, new_ob]
    end

    after(:each) do
     # @file.close
    end

    it "substitute_book should find the right book" do
      line1.stub(:book).and_return(ib)
      line2.stub(:book).and_return(ob)
      @archive.substitute_book(line1).should == new_ib.id
      @archive.substitute_book(line2).should == new_ob.id
    end

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

