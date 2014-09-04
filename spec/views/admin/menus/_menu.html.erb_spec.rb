# coding: utf-8

require 'spec_helper' 


RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe "admin/menus/_menu.html.erb" do   
  include JcCapybara 
  
  let(:o) {mock_model(Organism, main_bank_id:1, status:'Association', room:mock_model(Room),
      writings:[], created_at:Time.now, updated_at:Time.now) }
  let(:cu) {mock_model(User, name:'jcl', 'allowed_to_create_room?'=>true)}

  before(:each) do
    assign(:user, cu)
    view.stub(:current_user).and_return cu 
    view.stub('user_signed_in?').and_return true
    view.stub('owner?').and_return true
    assign(:organism, o)
    @request.path = '/admin/organisms/show'
  end
  
  describe 'bridge' do
    
    before(:each) do
      cu.stub(:organisms_with_room).and_return []
      o.stub(:periods).and_return []
      o.stub('max_open_periods?').and_return false
      o.stub(:nomenclature).and_return(double(Nomenclature, :job_finished_at=>DateTime.civil(2014,6,6)))
      
    end
    
    context 'l organisme est une association' do
      
      before(:each) do
        render :template=>'/admin/organisms/show', :layout=>'admin/layouts/application'
      end
    
      it 'le menu doit avoir un item Paramètres' do
        page.find('ul#main-nav li a', text:'PARAMETRES')
      end
    
      it 'avec un sous item Bridge' do
        page.find('a', text:'Adhérents')
      end
    
      it 'qui mène à Adherent::Bridge.members' do
        rendered.should have_selector('a[href="/adherent/members"]')
      end
    
    end
    
    context 'l organisme n est pas une association' do
      let(:o) {mock_model(Organism, main_bank_id:1, status:'Entreprise', room:mock_model(Room),
      writings:[], created_at:Time.now, updated_at:Time.now) }
      
      before(:each) do
        
        assign(:organism, o)
        render :template=>'/admin/organisms/show', :layout=>'admin/layouts/application'
      end
      
      it 'le menu n a pas d item Paramètres' do
        page.should_not have_content('PARAMETRES')
      end
    end
    
  end 
   
   
end