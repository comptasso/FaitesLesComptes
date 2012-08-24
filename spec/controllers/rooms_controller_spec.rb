require 'spec_helper'

describe RoomsController do
  
 let(:cu) {mock_model(User)}
 let(:ro) {mock_model(Room, user_id:cu.id)}
 let(:o)  {mock_model(Organism)}

   def valid_session
    {user:cu.id}
  end

   before(:each) do
     ActiveRecord::Base.stub!(:use_org_connection).and_return(true)  # pour éviter
    # l'appel d'establish_connection dans le before_filter find_organism

    Organism.stub(:first).and_return(o)
    User.stub(:find_by_id).with(cu.id).and_return(cu)
    
    o.stub_chain(:periods, :last).and_return(mock_model(Period))
    o.stub_chain(:periods, :any?).and_return true
  
   end

  describe 'GET show' do
    it 'current_user should receive rooms and find with the params' do
      cu.should_receive(:rooms).and_return(@a = double(Arel))
      @a.should_receive(:find).with(ro.id.to_s).and_return ro
      get :show, {user_id:cu.id, id:ro.id}, valid_session
    end

    it 'controller should check if organism has_changed' do
      cu.stub(:rooms).and_return @a=double(Arel)
      @a.stub(:find).with(ro.id.to_s).and_return ro
      controller.should_receive(:organism_has_changed?).with(ro).and_return false
      get :show, {user_id:cu.id, id:ro.id}, valid_session
    end

     it 'should redirect to organism_path' do
       cu.stub(:rooms).and_return @a=double(Arel)
       @a.stub(:find).with(ro.id.to_s).and_return ro
       get :show, {user_id:cu.id, id:ro.id}, valid_session
       response.should redirect_to organism_url(o)
     end

  end

end
