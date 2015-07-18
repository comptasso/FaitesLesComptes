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
  
  describe 'to_csv', wip:true do
   
    it 'peut produire un csv' do
      expect {subject.to_csv}.not_to raise_error
    end
    
    it 'la première ligne du fichier est' do
      subject.to_csv.split("\n").first.should == 
        "Date\tPièce\tRéf\tLibellé\tCompte\tIntitulé\tDébit\tCrédit"
    end
    
    context 'avec des lignes' do
      
      before(:each) do
        subject.stub(:compta_lines).and_return   [double(Object, 
               writing:double(Object, id: 12, date:'12/04/2013', piece_number:125, ref:125, narration:'une écriture'),
               account:double(Account, number:621, title:'Intérim'),
               debit:12.25, credit:0), 
             double(Object, 
               writing:double(Object, id:13, date:'12/04/2013', piece_number:126, ref:125, narration:'une écriture'),
               account:double(Account, number:531, title:'Caisse'),
               debit:0, credit:12.25)] 
             
      end
      
      it 'le csv comporte 3 lignes' do
        subject.to_csv.split("\n").should have(3).lines
      end
      
      
    end
    
    
  end


  
  

end

