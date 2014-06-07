RSpec.configure do |c|  
  # c.filter = {wip:true} 
end

describe UserInscription do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:user){mock_model(User, name:'spec', email:'spec@example.com')}
  

  describe 'new_user_advice retourne un objet mail' do 

    let(:email) { UserInscription.new_user_advice(user) }  
    

    it 'destiné à expert@faiteslescomptes.fr' do
      email.should deliver_to 'expert@faiteslescomptes.fr'
    end

    it 'le sujet est l ouverture d un nouveau compte' do
      email.should have_subject 'ouverture d\'un nouveau compte'
    end

    it 'le corps du mail contient' do
     email.should have_body_text(/Bonjour/)
     email.should have_body_text(/inscrit : spec/)
    end

    it 'le corps du mail donne le mail du nouvel user' do
      email.should have_body_text(/spec@example.com/)  
    end


  end
  
  describe 'welcome_user', wip:true do  

    let(:email) { UserInscription.welcome_user(user) } 
    

    it 'destiné à expert@faiteslescomptes.fr' do
      email.should deliver_to 'spec@example.com'
    end

    it 'le sujet est l ouverture d un nouveau compte' do
      email.should have_subject 'Bienvenue sur FaitesLesComptes !'
    end

    it 'le corps du mail contient une partie texte' do 
      bd = email.body.parts.first.body.to_s
      bd.should =~ /Vous venez de confirmer/
    # email.should have_body_text(/inscrit : spec/) 
    end
    
    it 'et une partie html' do
      bd = email.body.parts.last.body.to_s
      bd.should =~ /<p>Notre objectif/ 
    end

    


  end
end
