# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec_helper'

describe Utilities::Filler::Organism do
  include OrganismFixtureBis


  describe 'remplissage des différentes tables' do

    def create_comite
      clean_organism
      @o = Organism.create!(title: 'ASSO TEST', database_name:SCHEMA_TEST,
        comment: 'Un comité', status:'Comité d\'entreprise')
      @p = @o.periods.create!(start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
      @p.create_datas

    end

    before(:each) do
      create_comite
    end

    subject {@o.nomenclature}

    it {should have(5).folios}

    describe 'les folios de resultats sont sectorisés' do

      subject {@o.nomenclature.folios.where('sector_id IS NOT NULL')}

      it {subject.count.should == 2}
      it {subject.order(:title).first.sector.name.should == 'ASC'}
      it {subject.order(:title).last.sector.name.should == 'Fonctionnement'}

    end

  end
end
