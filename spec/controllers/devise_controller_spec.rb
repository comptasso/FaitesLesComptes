# coding: utf-8

require 'spec_helper'
require 'support/spec_controller_helper'

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe Admin::OrganismsController do

  include SpecControllerHelper

  let(:cu) {mock_model(User)}

  describe 'sign_in' do

    it 'should redirect without user (filter log_in?)' do
      get :index #'on utilise une action quelconque (ici rooms)'
      response.should redirect_to new_user_session_url
    end

    it 'assign user si la session existe' do
      minimal_instances
      get :index
      response.should render_template('index')
    end

  end


end
