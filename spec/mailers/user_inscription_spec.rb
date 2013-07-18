require "spec_helper"

describe UserInscription do
  before(:each) do
    @user = mock_model(User, name:'spec', e_mail:'spec@example.com')
  end 

  describe 'new_user_advice retourne un objet mail' do

    before(:each) do
      @mail = UserInscription.new_user_advice(@user)
    end

    it 'destiné à expert@faiteslescomptes.fr' do
      @mail[:to].to_s.should == 'expert@faiteslescomptes.fr'
    end

    it 'le sujet est l ouverture d un nouveau compte' do
      @mail[:subject].to_s.should == 'ouverture d\'un nouveau compte'
    end

    it 'le corps du mail contient' do
     pending 'attente de email_spec'
    end


  end
end
