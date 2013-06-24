require 'spec_helper'

describe Admin::VersionsController do
  include SpecControllerHelper

  before(:each) do
    sign_in(double(User))
  end


  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'migrate_each'" do
    it "redirect to admin_organisms_url" do
      
      get 'migrate_each'
      response.should redirect_to admin_rooms_url
    end

    it 'appelle migrate_each sur Room' do
      Room.should_receive(:migrate_each)
      get 'migrate_each' 
    end

    it 'efface le cache version_update' do
      Rails.cache.write('version_update', 'bonjour')
      Rails.cache.read('version_update').should == 'bonjour'
      get 'migrate_each'
      Rails.cache.read('version_update').should == nil
    end
  end

end
