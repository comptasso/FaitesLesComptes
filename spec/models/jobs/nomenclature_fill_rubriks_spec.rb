# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |config| 
  #  config.filter =  {wip:true}
end



describe Jobs::NomenclatureFillRubriks do  
  
  let(:p) {mock_model(Period)}
  let(:nomen) {mock_model(Nomenclature)}
  let(:r1) {mock_model(Rubrik)}
  let(:r2)  {mock_model(Rubrik)}
  
  subject {Jobs::NomenclatureFillRubriks.new()}
  
  before(:each) do
    subject.instance_variable_set('@period', p)
    subject.instance_variable_set('@nomenclature', nomen)
  end
  
  describe 'perform' do
  
    it 'appelle toutes les rubriques ' do
      nomen.should_receive(:rubriks).and_return []
      subject.perform 
    end
  
    it 'et met à jour les valeurs' do
      nomen.stub(:rubriks).and_return([r1, r2])
      r1.should_receive(:fill_values).with(p)
      r2.should_receive(:fill_values).with(p)
      subject.perform 
    end
  
  end
  
  describe 'success' do
    
      let(:nomen) {mock_model(Nomenclature)}

    subject {Jobs::NomenclatureFillRubriks.new()}
    
    before(:each) do
      subject.instance_variable_set('@nomenclature', nomen)
      Time.stub(:current).and_return(Time.mktime(2014,1,1))
    end
    
    it 'remplit le champ de job_finished_at de Nomenclature avec Time.current' do
      nomen.should_receive(:update_attribute).with(:job_finished_at, 
        Time.mktime(2014,1,1)).and_return
      subject.success(1)
    end
    
  end

end