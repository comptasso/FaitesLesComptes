# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'pdf_document/base'
require 'pdf_document/page'

describe PdfDocument::Base do

  let(:o) {mock_model(Organism, title:'Organisme test')}
  let(:p) {mock_model(Period, organism:o,
      start_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year,
      exercice:'Exercice 2012')}

  def valid_options
    {
      title:'PDF Document' ,
      subtitle:'Le sous titre'
    }
  end

  context 'minimal_options et pas encore de source' do

    before(:each) do
      @base = PdfDocument::Base.new(p, nil, valid_options)
    end

    it "should exists" do
      @base.should be_an_instance_of (PdfDocument::Base) 
    end

    it 'respond_to title' do
      @base.title.should == 'PDF Document'
    end

    it 'respond to sub_title' do
      @base.subtitle.should == 'Le sous titre'
    end

    it 'respond to organism_name' do
      @base.organism_name.should == 'Organisme test'
    end

    it 'respond to exercice' do
      @base.exercice.should == 'Exercice 2012'
    end

    it 'give the time of creation au format 25 juillet 2012 07:54:14' do
      @base.created_at.should match(/^\d{1,2}\s\w*\s\d{4}\s\d{2}:\d{2}:\d{2}$/)
    end

    it 'default from_date and to_date are from period' do
      @base.from_date.should == p.start_date
      @base.to_date.should == p.close_date
    end

    it 'has a default value nb_lines_per_page' do
      @base.nb_lines_per_page.should == 22
    end





    describe 'validations' do
      it 'should have a title' do
        @base.title =  nil
        @base.should_not be_valid
      end
    end


  end

  context 'options complémentaires' do
    it 'accepts options from_date' do
      h = valid_options.merge({:from_date=>Date.today.beginning_of_month})
      @base = PdfDocument::Base.new(p, nil, h)
      @base.from_date.should == Date.today.beginning_of_month
    end

    it 'accepts options to_date' do
      h = valid_options.merge({:to_date=>Date.today.end_of_month})
      @base = PdfDocument::Base.new(p,nil, h)
      @base.to_date.should == Date.today.end_of_month
    end

    it 'accepts options nb_lines_per_page' do
      h = valid_options.merge({:nb_lines_per_page=>30})
      @base = PdfDocument::Base.new(p,nil, h)
      @base.nb_lines_per_page.should == 30
    end
  end

  context 'création des pages' do

    let(:arel) {double(Arel, count:100, first:mock_model(Line))}
    let(:source) {mock_model(Account, title:'Achats', number:'60',
        lines:arel )}

    before(:each) do
      @base = PdfDocument::Base.new(p, source, valid_options) 
    end

    it 'connaît son nombre de pages' do
      @base.nb_pages.should == 5
    end

    it 'est capable de fournir une page pour le nb_pages' do
      1.upto(@base.nb_pages) do |i|
        @base.page(i).should be_an_instance_of PdfDocument::Page
      end
    end

    it 'appelé une page hors limite déclenche une erreur' do
      expect {@base.page(6)}.to raise_error ArgumentError
      expect {@base.page(0)}.to raise_error ArgumentError
    end

    describe 'stamp' do
      it 'has a nil default stamp' do
        @base.stamp.should == nil
      end

      it 'une option peut permettre de préciser le stamp' do
        pdf = PdfDocument::Base.new(p, source, valid_options.merge(stamp:'Provisoire'))
        pdf.stamp.should == 'Provisoire'
      end
    end


    it 'un doc doit pouvoir énumérer ses pages'

    it 'default select_method' do
      @base.select_method.should == :lines
    end

    it 'raise error si source ne repond pas à select method'

    it 'on peut modifier la select_method = ' do
      @base.select_method = :autre
      @base.select_method.should == :autre
    end

    # TODO ici on fait lines mais on devrait s'appuyer sur select_method
    it 'Par défaut les colonnes demandées sont celle de la classe retournée par select_method' do
      @base.columns.should == Line.column_names
    end

    it 'on peut sélectionner les colonnes' do
      @base.set_columns   %w(line_date ref nature_id destination_id debit credit)
      @base.columns.should == %w(line_date ref nature_id destination_id debit credit)
    end

    it 'choisir des colonnes crée un tableau des alignements' do
      @base.set_columns   %w(line_date ref nature_id destination_id debit credit)
      @base.columns_alignements.should == [:left, :left,:left,:left,:right, :right]
    end

   
    describe 'les méthodes sur les colonnes' do
      it 'par défaut les colonnes utilisent le nom de la colonne' do 
        @base.columns_methods.should == @base.columns
      end

      it 'mais on peut définir d autres méthodes' do
        @base.set_columns   %w(line_date ref nature_id destination_id debit credit)
        @base.set_columns_methods([nil, nil, 'nature.name','destination.name', 'debit.to_f',nil])
        @base.columns_methods.should == ['line_date','ref', 'nature.name','destination.name', 'debit.to_f', 'credit']
      end

      it 'raise error si columns_methods n est pas de la bonne taille'

    end

    describe 'les largeurs de colonnes' do

      before(:each) do
        @base.set_columns   %w(line_date ref nature_id destination_id debit credit)
      end

      it 'on a une largeur de colonnes par défaut' do
        @base.columns_widths.should == 6.times.collect {|t| 100.0/6 }
      end

      it 'on peut imposer les 6 colonnes' do
        @base.set_columns_widths([10,20,30,10,15,15])
        @base.columns_widths.should == [10,20,30,10,15,15]
      end

      it 'on peut n imposer que les 4 premières' do
        @base.set_columns_widths([10,20,30,10])
        @base.columns_widths.should == [10,20,30,10,15,15]
      end

      it 'gestion des erreurs des size'

    end

    

    describe 'gestion des totaux' do

      before(:each) do
        @base.set_columns  %w(line_date ref nature_id destination_id debit credit)
        @base.set_columns_widths([10,20,30,10])
      end

      it 'set avec un array vide génère une erreur' do
        expect { @base.set_columns_to_totalize []}.to raise_error 'Le tableau des colonnes ne peut être vide'
      end

      it 'définir les colonnes permet de définir les largeurs' do
        bcw4 = @base.columns_widths[4]
        bcw5 = @base.columns_widths[5]
        @base.set_columns_to_totalize [4,5]
        @base.total_columns_widths.should == [100 - bcw4 - bcw5, bcw4, bcw5 ]
      end

      it 'définir une colonne qui n est pas la dernière' do
        bcw4 = @base.columns_widths[4]
        bcw5 = @base.columns_widths[5]
        @base.set_columns_to_totalize [4]
        @base.total_columns_widths.should == [100 - bcw4 - bcw5, bcw4 ]
      end

      it 'peut fixer la première ligne de report' do
        @base.first_report_line = ['Soldes', 100, 20]
        @base.first_report_line.should ==  ['Soldes', 100, 20]
      end

    end

    it 'peut créer un fichier pdf' do
      @base.should respond_to(:render) 
    end

    # l'action de render est testée dans la un spec de vue
  end



  
end

