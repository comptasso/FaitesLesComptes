# coding: utf-8

require "spec_helper"

RSpec.configure do |c|
   # c.filter = {wip:true} 
end

describe Stats::StatsNatures do
  include OrganismFixtureBis
  
  before(:each) do
    use_test_organism 
  end
  
  
  describe 'création sans secteur' do
    
    context 'sans écriture' do
    
      before(:each) do
        @sd = Stats::Destinations.new(@p)
      end
      
      it 'la ligne de titres comprend Nature' do
        @sd.title_line.first.should == 'Natures'
      end
    
      it 'la ligne de titres se termine par Total' do
        expect(@sd.title_line.last).to eq 'Total'
      end
    
      it 'suivie de zero destinations et d une colonne Total'do
        expect(@sd.title_line.size).to eq 2
      end
    
    end
    
    context 'avec une écriture sans destination' do
      
      before(:each) do
        create_outcome_writing
        @sd = Stats::Destinations.new(@p)
      end
      
      after(:each) do
        Writing.delete_all
      end
      
      it 'une seule destination Aucune' do
        expect(@sd.dests.size).to eq 1 
        expect(@sd.dests.first.name).to eq 'Aucune'
      end
      
      it 'la table a 1 seule ligne' do
        expect(@sd.lines.size).to eq 1
      end
      
      it 'formée de ' do
        expect(@sd.lines.first).to eq [@n.name, -99, -99]
      end
      
      it 'la ligne de total est ' do
        expect(@sd.total_line).to eq(['Total', -99, -99])
      end
      
    end
    
    context 'avec une écriture avec destination'  do
      
      before(:each) do
        @d = Destination.first
        @w1 = create_outcome_writing(99, 'Virement', @d.id)
        @sd = Stats::Destinations.new(@p)
      end
      
      after(:each) do
        Writing.delete_all
      end
      
      it 'les dests ' do
        expect(@sd.dests.collect(&:name)).to eq [@d.name]
      end
      
      context 'avec une deuxième écriture sans destination', wip:true do
      
        before(:each) do
          @w2 = create_outcome_writing(10.11)
          @sd = Stats::Destinations.new(@p)
        end
        
        it 'la ligne de titre ' do
          expect(@sd.title_line).to eq ['Natures', @d.name, 'Aucune', 'Total']
        end
        
        it 'la ligne total_line' do
          expect(@sd.total_line).to eq ['Total', -99.0, -10.11, -109.11]
        end
        
      
      end
      
    end
    
    
  
  end
  
  describe 'avec secteur' do
    
    before(:each) do
        @sect  = Sector.first
    end
    
    after(:each) {Writing.delete_all}
    
    it 'la recherche appelle les livres' do
      @sect.should_receive(:books).and_return(@ar = double(Arel))
      @ar.should_receive(:order).with(:type).and_return([Book.first, Book.last])
      @sd = Stats::Destinations.new(@p, sector:@sect)
    end
    
    it 'et fonctionne correctement' do
      @d = Destination.first
      @w1 = create_outcome_writing(99, 'Virement', @d.id)
      expect {Stats::Destinations.new(@p)}.not_to raise_error
    end
    
    
    
  end
  
  
end