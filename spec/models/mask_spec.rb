require 'spec_helper' 

describe Mask do
  
  before(:each) do
    @mask = Mask.new(title:'Le masque', 
      comment:'Avec un commentaire', nature_name:'', mode:'', counterpart:'',
      book_id:'1')
    @mask.stub(:book).and_return(double(IncomeBook, type:'IncomeBook', id:1))
    @mask.organism_id = 1 
    
  end
  
  describe 'validations' do
    subject {@mask}
    it {should be_valid}
    
    specify {@mask.should be_valid}
    
    
    it 'un masque doit avoir un titre' do
      @mask.title = nil
      should_not be_valid
    end
    
    it 'et un organisme' do
      @mask.organism_id = nil
      should_not be_valid
    end
    
    it 'et un book_id' do
      @mask.book_id = nil
      @mask.should_not be_valid
    end
    
    describe 'le titre doit' do
      it 'commencer par une lettre' do
        @mask.title = '- bien'
        @mask.should_not be_valid
      end
      
      it 'ne pas être trop court' do
        @mask.title = 'a'
        @mask.should_not be_valid
      end
      
      it 'ni trop long' do
        @mask.title = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
        @mask.should_not be_valid
      end
      
    end
    
    describe 'cohérences' do
      
      describe 'du type de nature et du livre' do
      
        before(:each) do
          @mask.nature_name = 'test recettes'
          @mask.stub_chain(:organism, :natures).and_return @ar = double(Arel)
        end
      
        it 'valide si le livre de recettes et la nature sont cohérents' do
          @ar.stub(:find_by_name).with('test recettes').and_return(double(Nature, book_id:1))
          @mask.should be_valid
        end
      
        it 'invalide dans le cas contraire' do
          @ar.stub(:find_by_name).with('test recettes').and_return(double(Nature, book_id:2))
          @mask.should_not be_valid
        end
        
        context 'avec un livre de dépenses' do
          
        before(:each) do
          @mask.stub(:book).and_return(double(OutcomeBook, type:'OutcomeBook', id:2))          
        end  
        
        it 'valide si le livre de dépenses et la nature sont cohérents' do
          @ar.stub(:find_by_name).with('test recettes').and_return(double(Nature, book_id:1))
          @mask.should_not be_valid
        end
      
        it 'invalide dans le cas contraire' do
          @ar.stub(:find_by_name).with('test recettes').and_return(double(Nature, book_id:2))
          @mask.should be_valid
        end
        
        end
        
      end
      
      describe 'du mode de paiment et de counterpart' do
        
        describe 'si c est une recette par chèque, la contrepartie doit être chèque à l encaissement' do
          before(:each) do
            @mask.mode = 'Chèque'
          end
          
          it 'valide si pas de contrepartie' do
            @mask.should be_valid
          end
          
          it 'valide si counterpart est une caisse' do
            @mask.counterpart = 'Chèque à l\'encaissement'
            @mask.should be_valid
          end
          
          it 'invalide dans le cas contraire' do
            @mask.counterpart = 'Autre chose que chèque à l encaissement'
            @mask.should_not be_valid 
          end
          
        end
        
        describe 'une dépense par chèque est possible mais doit avoir une banque en contrepartie' do
          
          before(:each) do
            @mask.mode = 'Chèque'
            @mask.counterpart = 'Compte courant'
            @mask.stub(:bank_account).and_return(double(BankAccount))
            
          end
          
          it 'si le livre est un livre de dépenses' do
            @mask.stub(:book).and_return(double(Book, type:'OutcomeBook'))
            @mask.should be_valid
          end
          
          it 'mais pas pour un livre de recettes' do
            @mask.stub(:book).and_return(double(Book, type:'IncomeBook'))
            @mask.should_not be_valid
          end
            
          
        end
        
        describe 'si c est par virement CB ou prélèvement, c est un compte bancaire' do
          before(:each) do
            @mask.mode = 'Virement'
          end
          
          it 'valide si pas de contrepartie' do
            @mask.should be_valid
          end
          
          it 'valide si counterpart est une caisse' do
            @mask.counterpart = 'Compte courant'
            @mask.should_receive(:bank_account).and_return(double(BankAccount))
            @mask.should be_valid
          end
          
          it 'invalide dans le cas contraire' do
            @mask.counterpart = 'Compte courant'
            @mask.stub(:bank_account).and_return(nil)
            @mask.should_not be_valid
          end
        end
        
        describe 'si c est en espèces , c est une caisse' do
          before(:each) do
            @mask.mode = 'Espèces'
            @mask.stub(:bank_account).and_return nil
          end
          
          it 'valide si pas de contrepartie' do
            @mask.should be_valid
          end
          
          it 'valide si counterpart est une caisse' do
            @mask.counterpart = 'Local'
            @mask.should_receive(:cash).and_return(double(Cash))
            @mask.should be_valid
          end
          
          it 'invalide dans le cas contraire' do
            @mask.counterpart = 'Local'
            @mask.stub(:cash).and_return(nil)
            @mask.should_not be_valid
          end
        end
        
        
        
        
      end
      
    end
    
    
  end
  
end
