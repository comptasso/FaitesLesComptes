require 'spec_helper'

describe Admin::OrganismsHelper do
  describe 'last_data_build' do
    
    let(:o) {mock_model(Organism)}
    before(:each) do
      o.stub(:nomenclature).and_return(@nomen = Nomenclature.new)
    end
    
    it 'renvoie jamais si le champ job_finished_at est nil' do
      @nomen.job_finished_at = nil 
      last_data_build(o).should == 'jamais'
    end
    
    it 'renvoie la date et l heure autrement' do
      @nomen.job_finished_at = Time.mktime(1955,6,6, 11, 10)
      last_data_build(o).should == 'il y a plus de 59 ans'
    end
    
    
  end
end
