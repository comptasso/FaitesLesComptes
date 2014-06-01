# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe Admin::RoomsController do
  
  include SpecControllerHelper 
  
  let(:cu) {mock_model(User, 'up_to_date?'=>true)}
  
  describe 'sign_in' do

    it 'should redirect without user (filter log_in?)' do
      sign_in(nil)
      get :index #'on utilise une action quelconque (ici rooms)'
      response.should redirect_to new_user_session_url
    end
    
    it 'assign user si la session existe' do
      cu.stub_chain(:rooms, :count).and_return 2
      sign_in(cu)

      get :index
      response.should render_template('index')
    end

  end
  
  
end