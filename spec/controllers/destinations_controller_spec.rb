require 'spec_helper'

describe DestinationsController do  
  include SpecControllerHelper
    
  describe "GET index" do
    
    let(:sd) {double(Stats::Destinations,
        lines:[['Participation des salariés', 56, 12.25, 56, 0, 124.25],
               ['Subvention ASC', 0,0,0,1500,1500]]
           )}

    before(:each) do
      minimal_instances
    end
    
    it 'le controller affecte le secteur' do
      @o.should_receive(:sectors).and_return(@ar = double(Arel))
      @ar.should_receive(:find).with(@sect.to_param).and_return(@sect)
      Stats::Destinations.stub(:new).and_return(sd)
      get :index ,
        {:organism_id=>@o.to_param, :period_id=>@p.to_param, sector_id:@sect.to_param},
        session_attributes
    end
    
    it 'puis crée une Stats::Destinations' do
      @o.stub(:sectors).and_return(double(Arel, find:@sect)) 
      Stats::Destinations.should_receive(:new).with(@p, sector:@sect).and_return sd
      get :index ,
        {:organism_id=>@o.to_param, :period_id=>@p.to_param, sector_id:@sect.to_param},
        session_attributes
    end
  
    it 'répond avec succès ' do 
      @o.stub(:sectors).and_return(double(Arel, find:@sect)) 
      Stats::Destinations.stub(:new).and_return(sd)
      get :index ,
        {:organism_id=>@o.to_param, :period_id=>@p.to_param, sector_id:@sect.id},
        session_attributes
      response.should be_success
    end
    
    it 'sans lignes un flash annonce' do
      @o.stub(:sectors).and_return(double(Arel, find:@sect)) 
      Stats::Destinations.stub(:new).and_return(sd)
      sd.stub(:lines).and_return([])
      get :index ,
        {:organism_id=>@o.to_param, :period_id=>@p.to_param, sector_id:@sect.id},
        session_attributes
      flash[:alert].should == 'Aucune donnée à afficher'
    end
    
    
  end
  
end