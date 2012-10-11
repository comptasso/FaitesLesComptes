# coding: utf-8

require 'spec_helper'

describe "in_out_writings/new" do
  include JcCapybara



  let(:o) {stub_model(Organism) }
  let(:book) {stub_model(Book) }
  let(:n) {stub_model(Nature, name:'nature')}
  let(:d) {stub_model(Destination, name:'destination')}

  before(:each) do
 assign(:in_out_writing, stub_model(InOutWriting, book_id:1, date:Date.today).as_new_record)
    assign(:line, stub_model(ComptaLine, ref:nil).as_new_record)
    assign(:counter_line, stub_model(ComptaLine).as_new_record)
    assign(:book, stub_model(IncomeBook, :title=>'Recettes'))
    assign(:period, stub_model(Period, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31)) )
    assign(:organism, o)

    o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque))
  end

  it 'le champs nature doit être précédé d une étoile' do
    render
    page.find(:xpath, '//label[@for="in_out_writing_compta_lines_attributes_0_nature_id"]').should have_content('*')
  end

  it 'le champ paiement doit être précédé d une étoile' do
    render
    page.find(:xpath, '//label[@for="in_out_writing_compta_lines_attributes_0_payment_mode"]').should have_content('*')
  end

  it 'test en cas d erreur dans le remplissage' do
    pending 'A faire'
  end


end
