# coding: utf-8

require 'spec_helper'

describe RoomsController do
    include SpecControllerHelper
 
   before(:each) do
    minimal_instances
   end

  describe 'GET show' do
    it 'current_user should receive rooms and find with the params' do
      @cu.should_receive(:rooms).and_return(@a = double(Arel))
      @a.should_receive(:find).with(@r.id.to_s).and_return @r
      get :show, {user_id:@cu.id, id:@r.id}, valid_session
    end

    it 'controller should check if organism has_changed' do
      @cu.stub(:rooms).and_return @a=double(Arel)
      @a.stub(:find).with(@r.id.to_s).and_return @r
      controller.should_receive(:organism_has_changed?).with(@r).and_return false
      get :show, {user_id:@cu.id, id:@r.id}, valid_session 
    end

     it 'should redirect to organism_path' do
       @cu.stub(:rooms).and_return @a=double(Arel)
       @a.stub(:find).with(@r.id.to_s).and_return @r
       get :show, {user_id:@cu.id, id:@r.id}, valid_session
       response.should redirect_to organism_url(@o)
     end

  end

 

end
