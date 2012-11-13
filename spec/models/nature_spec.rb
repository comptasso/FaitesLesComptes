# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

describe Nature do
  include OrganismFixture

  let(:p) {mock_model(Period)}
  
  before(:each) do
    @nature = Nature.new(period_id: p.id, name: 'Nature test', income_outcome: false)
  end

  it "should be valid" do
    @nature.should be_valid 
  end

  it 'should not be valid without period' do
    @nature.period_id = nil
    @nature.should_not be_valid
  end

  it 'should not be valid without name' do
    @nature.name = nil
    @nature.should_not be_valid
  end

  it 'should not be valid without income_outcome' do
    @nature.income_outcome = nil
    @nature.should_not be_valid
  end

  context 'with a db connection' do

    describe 'create nature' do
      before(:each) do
        create_minimal_organism
      end

      it 'a valid nature can be created' do
        expect {@p.natures.create!(name: 'Nature test', income_outcome: false)}.to change{Nature.count}
      end

      context 'with already a nature' do

             
        it 'name should be unique with the same outcome income' do
            expect {@p.natures.create(name: 'Essai', income_outcome: false)}.not_to change{Nature.count}
        end

        it 'can have the same name with different outcome_income' do
          expect {@p.natures.create!(name: 'Essai', income_outcome: true)}.to change{Nature.count}
        end

        it 'can also have the same name with different periods' do
          Nature.count.should == 18 # les deux de minimal organisme
          @o.periods.create!(start_date: @p.start_date.years_since(1), close_date: @p.close_date.years_since(1))
          Nature.count.should == 36 # avec la recopie automatique des natures par Period
        end

      end

      describe 'destroy nature' do
        before(:each) do
          create_minimal_organism
        end

        it 'can be destroy when empty' do
          expect {@n.destroy}.to change {Nature.count}.by(-1)
        end

        it 'cant be destroyed when not empty' do
          create_outcome_writing(152, 'Chèque')
          @n.compta_lines.count.should == 1
          expect {@nature.destroy}.not_to change {Nature.count}
        end

      end

    end


  end

  it 'tester les méthodes statistiques de natures'
  
end

