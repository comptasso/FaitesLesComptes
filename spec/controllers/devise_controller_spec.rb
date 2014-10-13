# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe Admin::RoomsController do
  
  include SpecControllerHelper 
  
  let(:cu) {mock_model(User)}
  
  describe 'sign_in' do

    it 'should redirect without user (filter log_in?)' do
      sign_in(nil)
      get :index #'on utilise une action quelconque (ici rooms)'
      response.should redirect_to new_user_session_url
    end
    
    it 'assign user si la session existe' do
      cu.stub_chain(:rooms, :includes).and_return [
        double(Room, relative_version: :same_migration),
        double(Room, relative_version: :same_migration)] 
      sign_in(cu)

      get :index
      response.should render_template('index')
    end

  end
  
  
end