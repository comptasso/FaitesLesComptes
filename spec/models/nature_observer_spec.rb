# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|
  #  config.filter =  {wip:true}
end


describe  NatureObserver do
  include OrganismFixtureBis


  let(:cl1) { mock_model(ComptaLine, :account_id=>1) }
  let(:cl2) { mock_model(ComptaLine, :account_id=>1) }



  before(:each) do

    clean_organism
    @nature = Nature.new(name:'ecolo', :account_id => 1, book_id:1)
    @nature.period_id = 1
    @nature.stub(:fix_position) # pour éviter les difficultés de test
    # liées à ce after_create
    @nature.save!
    @nature.stub(:period).and_return(double(Period, organism:@o = double(Organism)))

    @nature.stub(:compta_lines).and_return(@a = double(Arel))

  end


  describe 'le changement de account_id' do

    it 'modifie le account_id des lignes dépendant de nature' do
      @a.stub(:unlocked).and_return([cl1, cl2])
      @nature.account_id = 3
      cl1.should_receive(:update_attributes).with(:account_id=>3)
      cl2.should_receive(:update_attributes).with(:account_id=>3)
      @nature.save!

    end

    it 'sauf pour les compta_lines verrouillées' do
      @a.stub(:unlocked).and_return([cl2])
      @nature.account_id = 3
      cl1.should_not_receive(:update_attributes).with(:account_id=>3)
      cl2.should_receive(:update_attributes).with(:account_id=>3)
      @nature.save!
    end

  end

  describe 'le changement de nom' do

    # cette appel a été replacé dans le modèle

    before(:each) do
      @m = Mask.new
      @a.stub(:unlocked).and_return([])
      @o.stub(:masks).and_return(@ar = double(Arel))
      @old_name = @nature.name
    end

    it 'met à jour les masques qui utilisent ce nature name' do
      @nature.name = 'Cotisations'
      @ar.should_receive(:filtered_by_name).with(@old_name).and_return([@m])
      @m.should_receive(:update_attributes).with(:nature_name=>'Cotisations')
      @nature.save!
    end


  end

end

