# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

describe Destination do 
  include OrganismFixtureBis

  let(:o) {stub_model(Organism)}
  
  before(:each) do
    @destination = o.destinations.new(name: 'Destination test')
  end

  it "should be valid" do
    @destination.should be_valid 
  end

  it 'should not be valid without organism' do
    @destination.organism_id = nil
    @destination.should_not be_valid
  end

  it 'should not be valid without name' do
    @destination.name = nil
    @destination.should_not be_valid
  end

 
  context 'with a db connection' do

    describe 'creation de l organisme minimal' do
      before(:each) do
        use_test_organism
      end
      
      after(:each) do
        Destination.delete_all
      end

      it 'une destination peut être créée' do
        expect {@o.destinations.create!(name: 'Destination test')}.to change{Destination.count}
      end

      context 'with already a destination' do

        before(:each) do
          @o.destinations.create!(name: 'Essai')
        end
             
        it 'name should be unique' do
          expect {@o.destinations.create(name: 'Essai')}.not_to change{Destination.count}
        end

       

      end

      describe 'destroy destination' do
        before(:each) do
          @destination = @o.destinations.create!(name: 'Destination test')
        end

        it 'can be destroy when empty' do
          expect {@destination.destroy}.to change {Destination.count}.by(-1)
        end

        it 'cant be destroyed when not empty' do
          @w = create_outcome_writing
          @w.in_out_line.destination = @destination
          @w.save
          @destination.compta_lines.count.should == 1
          expect {@destination.destroy}.not_to change {Destination.count}
        end
 
      end

    end
    
    describe 'name_with_sector', wip:true do
      
      subject do
        Destination.new(name:'mon nom') 
      end
      
      context 'avec un seul secteur' do
      
        before(:each) do
          subject.stub(:organism).and_return(double(Organism, sectored?:false))  
        end
      
        it 'renvoie le nom de la destination' do
          subject.name_with_sector.should == subject.name
        end
      end
      
      context 'avec plusieurs secteurs' do
        
        before(:each) do
          subject.stub(:organism).and_return(double(Organism, sectored?:true))
          subject.stub(:sector).and_return(double(Sector, name:'Gros secteur'))
        end
        
        it 'renvoie le nom de la destination, suivi de celui du secteur' do
          subject.name_with_sector.should == "#{subject.name} (#{subject.sector.name})"
        end
        
      end
      
    end


  end

  
  
end

