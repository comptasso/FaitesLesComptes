# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Account do 
  include OrganismFixture

   before(:each) do
      create_minimal_organism
   end

  it "un account non valide peut être instancié" do
    Account.new.should_not be_valid
  end

  def valid_attributes
    {number:'60',
     title:'Titre du compte',
     period_id:@p.id
    }
  end

  describe 'validations' do

    before(:each) do
      @account = Account.new(valid_attributes)
      puts @account.errors.messages unless @account.valid?
    end
  
    it "should be valid"  do
      @account.should be_valid
    end

    describe 'should not be valid lorsque' do

      it 'sans number' do
        @account.number = nil
        @account.should_not be_valid
      end

      it 'sans title' do
        @account.title =  nil
        @account.should_not be_valid
      end

      it 'sans exercice' do
        @account.period = nil
        @account.should_not be_valid
      end
    end
  end

  describe 'fonctionnalités natures' do
    before(:each) do
      @account = Account.create!(valid_attributes)
      @n.account_id = @account.id
      @n.save!
    end

    it 'un compte peut avoir des natures' do
      @account.should have(1).natures
    end
    
    it 'un compte a des lignes à travers natures' do
      create_lines(10)
      @account.should have(10).lines
    end
  end

  describe 'fonctionnalité pdf' do
    before(:each) do
      @account = Account.create!(valid_attributes)
      @n.account_id = @account.id
      @n.save!
      create_lines(50)
    end

    it 'un compte peut produire un pdf' do
      @account.to_pdf.should be_an_instance_of(PdfDocument::Base)
    end

    it 'le pdf comprend 3 pages' do
      @account.to_pdf.nb_pages.should == 3
    end

  end

end 

