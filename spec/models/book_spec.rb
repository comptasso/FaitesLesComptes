# coding: utf-8

# To change this template, choose Tools | Templates
# and open the template in the editor.
RSpec.configure do |c| 
  #   c.filter = {:wip => true }
  #  c.exclusion_filter = {:js=> true }
end


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

describe Book do
      subject do 
        bo = Book.new(title:'Autre titre', abbreviation:'CE')
        bo.organism_id = 1
        bo
      end
  
  describe 'validations' do
    
    it('est valide') {subject.should be_valid}
    
    it 'mais pas sans organisme' do
      subject.organism_id = nil
      subject.should_not be_valid
    end
    
    it 'mais pas sans titre' do 
      subject.title = nil
      subject.should_not be_valid
    end 
    
    it 'ni si le titre contient des caractères interdits' do
      subject.title = 'Bonsoi\r'
      subject.should_not be_valid
    end
    
    it 'ni sans abbréviation' do
      subject.abbreviation = nil
      subject.should_not be_valid
    end
    
    it 'ni si l abbréviation contient plus de 3 caractères' do
      subject.abbreviation = 'bonsoir'
      subject.should_not be_valid
    end
    
    it 'ni si l abbreviation ne respecte pas le format AAX' do
      subject.abbreviation = 'AZ1'; subject.should be_valid
      subject.abbreviation = 'AZ'; subject.should be_valid
      subject.abbreviation = 'Az'; subject.should_not be_valid
      subject.abbreviation = '1AZ'; subject.should_not be_valid
    end
    
    describe 'uniqueness' do
      
      before(:each) do
        @book_test = Book.new(title:'Un livre de test', abbreviation:'TE')
        @book_test.organism_id = 1
        @book_test.save!
      end
      
      after(:each) do
        @book_test.destroy
      end
      
      it('est valide') {subject.should be_valid}
      
      it 'le titre est unique' do
        subject.title = 'Un livre de test'
        subject.should_not be_valid
      end
      
      it 'l abbreviation est unique' do
        subject.abbreviation = 'TE'
        subject.should_not be_valid
      end
      
      
    end
    
    
  end


  
  

end

