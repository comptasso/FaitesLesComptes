# coding: utf-8

require 'spec_helper' 

require 'pdf_document/default'

RSpec.configure do |config|
 # config.filter = {wip:true}
end

describe PdfDocument::Page do 
  let(:o) {mock_model(Organism, title:'Organisme test')}
  let(:p) {mock_model(Period, organism:o,
      from_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year,
      exercice:'Exercice 2012')}
  let(:arel) {double(Arel, count:100, first:mock_model(ComptaLine,  debit:12, credit:0))}
  let(:source) {mock_model(Account, title:'Achats', number:'60',
      compta_lines:arel )}


  let(:doc) { PdfDocument::Default.new(p, source, {title:'Le titre de la page'}) }
  let(:now) {Time.now}



  before(:each) do
    doc.columns_methods =  %w(date debit credit)
    doc.columns_titles =   %w(Date Débit Crédit)
    doc.stub(:nb_pages).and_return 5
    @page = PdfDocument::Page.new(2, doc)
  end

  it "should desc" do
    @page.should be_an_instance_of(PdfDocument::Page)
  end

  it 'should know his page number' do
    @page.number.should == 2
  end

  describe 'doit être capable de fournir toutes les informations au template' do
    it 'répond à left_top' do
      @page.top_left.should ==  "Organisme test\nExercice 2012"
    end

    it 'répond à top middle' do
      @page.title.should == 'Le titre de la page'
    end

    it 'délègue columns_widths' do
      doc.stub(:columns_widths).and_return 'bonjour'
      @page.table_columns_widths.should == 'bonjour'
    end

    it 'avec un sous titre s il existe' do
      doc.stub(:subtitle).and_return'Le sous titre'
      @page.subtitle.should == "Le sous titre"
    end 

    it "répond à top_right" do
      @page.top_right.should == "#{I18n::l(Date.today, :format=>:long)}\n#{now.strftime('%H:%M:%S')}"
    end

    it "repond à table_title" do
      @page.table_title.should == %w(Date Débit Crédit)
    end

    it 'repond à stamp' do
      @page.stamp.should == doc.stamp
    end

    describe 'lines total et reports'  do

      before(:each) do
        @l = mock_model(ComptaLine,  debit:10, credit:0)
        @w = mock_model(Writing, date:Date.today, ref:'référence')
        @l.stub(:writings).and_return @w
        arel.stub(:joins).and_return arel
        arel.stub_chain(:select, :range_date, :offset, :limit).and_return 1.upto(22).collect {|i| @l}
        doc.columns_methods = %w(writings.date writings.ref debit credit)
        doc.columns_to_totalize = [2]
      
      end

      it 'total_line' , wip:true do
        doc.page(1).table_total_line.should == ['Totaux', "220,00"] 
      end

      it 'to_report' do
        doc.page(1).table_to_report_line.should == ['A reporter', "220,00"]
      end

      it 'to_report_line' do
        doc.page(2).table_report_line.should == ['Reports', "220,00"]
      end

      it 'la page 1 n a pas de ligne report' do
        doc.page(1).table_report_line.should be_nil 
      end

      describe 'report de la première page' do
        it 'sauf s il est fixé par le doc' do
          doc.first_report_line = ["Soldes", 99]
          doc.page(1).table_report_line.should ==  ["Soldes", 99]
        end

        it 'le total à reporter prend en compte le report' do
          doc.first_report_line = ["Soldes", 99]
          doc.page(1).table_to_report_line.should == ['A reporter', "319,00"]
        end


      end




      
      it 'la page 3 doit avoir un report de 440' do
        doc.page(3).table_report_line.should == ['Reports', '440,00']
      end

      it 'la page a une ligne à reporter' do
        doc.page(3).table_to_report_line.should == ['A reporter', '660,00']
      end

      it 'la ligne à reporter est intitulée total general pour la dernière page' do
        doc.page(5).table_to_report_line.should == ['Total général', '1 100,00']
      end



      
    end


  end
end

