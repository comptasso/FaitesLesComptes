require 'spec_helper'

describe Mask do
  
  before(:each) do
    @m = Mask.new(title:'Le masque', 
      comment:'Avec un commentaire', nature_name:'', mode:'', counterpart:'',
      book_id:'1')
    @m.stub(:book).and_return(double(IncomeBook, type:'IncomeBook'))
    @m.organism_id = 1
    
  end
  
  describe 'validations' do
    it '@m est valide' do
      @m.should be_valid
    end
    
    
    it 'un masque doit avoir un titre' do
      @m.title = nil
      @m.should_not be_valid
    end
    
    it 'et un organisme' do
      @m.organism_id = nil
      @m.should_not be_valid
    end
    
    it 'et un book_id' do
      @m.book_id = nil
      @m.should_not be_valid
    end
    
    describe 'le titre doit' do
      it 'commencer par une lettre' do
        @m.title = '- bien'
        @m.should_not be_valid
      end
      
      it 'ne pas être trop court' do
        @m.title = 'a'
        @m.should_not be_valid
      end
      
      it 'ni trop long' do
        @m.title = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
        @m.should_not be_valid
      end
      
    end
    
    describe 'cohérences' do
      
      describe 'du type de nature et du livre' do
      
        before(:each) do
          @m.nature_name = 'test recettes'
          @m.stub_chain(:organism, :natures).and_return @ar = double(Arel)
        end
      
        it 'valide si le livre de recettes et la nature sont cohérents' do
        
          @ar.stub(:find_by_name).with('test recettes').and_return(double(Nature, :income_outcome=>true))
          @m.should be_valid
        end
      
        it 'invalide dans le cas contraire' do
          @ar.stub(:find_by_name).with('test recettes').and_return(double(Nature, :income_outcome=>false))
          @m.should_not be_valid
        end
        
        context 'avec un livre de dépenses' do
          
        before(:each) do
          @m.stub(:book).and_return(double(OutcomeBook, type:'OutcomeBook'))          
        end  
        
        it 'valide si le livre de dépenses et la nature sont cohérents' do
          @ar.stub(:find_by_name).with('test recettes').and_return(double(Nature, :income_outcome=>true))
          @m.should_not be_valid
        end
      
        it 'invalide dans le cas contraire' do
          @ar.stub(:find_by_name).with('test recettes').and_return(double(Nature, :income_outcome=>false))
          @m.should be_valid
        end
        
        end
        
      end
      
      describe 'du mode de paiment et de counterpart' do
        
        describe 'si c est une recette par chèque, la contrepartie doit être chèque à l encaissement' do
          before(:each) do
            @m.mode = 'Chèque'
          end
          
          it 'valide si pas de contrepartie' do
            @m.should be_valid
          end
          
          it 'valide si counterpart est une caisse' do
            @m.counterpart = 'Chèque à l\'encaissement'
            @m.should be_valid
          end
          
          it 'invalide dans le cas contraire' do
            @m.counterpart = 'Autre chose que chèque à l encaissement'
            @m.should_not be_valid 
          end
          
        end
        
        describe 'une dépense par chèque est possible mais doit avoir une banque en contrepartie' do
          
          before(:each) do
            @m.mode = 'Chèque'
            @m.counterpart = 'Compte courant'
            @m.stub(:bank_account).and_return(double(BankAccount))
            
          end
          
          it 'si le livre est un livre de dépenses' do
            @m.stub(:book).and_return(double(Book, type:'OutcomeBook'))
            @m.should be_valid
          end
          
          it 'mais pas pour un livre de recettes' do
            @m.stub(:book).and_return(double(Book, type:'IncomeBook'))
            @m.should_not be_valid
          end
            
          
        end
        
        describe 'si c est par virement CB ou prélèvement, c est un compte bancaire' do
          before(:each) do
            @m.mode = 'Virement'
          end
          
          it 'valide si pas de contrepartie' do
            @m.should be_valid
          end
          
          it 'valide si counterpart est une caisse' do
            @m.counterpart = 'Compte courant'
            @m.should_receive(:bank_account).and_return(double(BankAccount))
            @m.should be_valid
          end
          
          it 'invalide dans le cas contraire' do
            @m.counterpart = 'Compte courant'
            @m.stub(:bank_account).and_return(nil)
            @m.should_not be_valid
          end
        end
        
        describe 'si c est en espèces , c est une caisse' do
          before(:each) do
            @m.mode = 'Espèces'
            @m.stub(:bank_account).and_return nil
          end
          
          it 'valide si pas de contrepartie' do
            @m.should be_valid
          end
          
          it 'valide si counterpart est une caisse' do
            @m.counterpart = 'Local'
            @m.should_receive(:cash).and_return(double(Cash))
            @m.should be_valid
          end
          
          it 'invalide dans le cas contraire' do
            @m.counterpart = 'Local'
            @m.stub(:cash).and_return(nil)
            @m.should_not be_valid
          end
        end
        
        
        
        
      end
      
    end
    
    
  end
  
end
