# coding: utf-8

describe "in_out_writings/_table_lines" do
  include JcCapybara
  
  def mock_writing_line(montant)
    mock_model(ComptaLine,
      :ref=>'001',
      :date=>Date.today,
      :narration=>'le libellé',
      :nature=>double(:name=>'une dépense'),
      :destination=>double(:name=>'destinée'),
      :debit=>montant,
      :credit=>0,
      :writing=>@w = mock_model(Writing, payment_mode:'CB', support:'Compte courant', 'editable?'=>false),
      
    )
  end

  before(:each) do
    assign(:monthly_extract, double(Object, lines:[mock_writing_line(10)]) )
    render
  end
  
  it 'la vue comprend 11 éléments td' do
    page.all('td').should have(11).elements
  end
  
  it 'qui donnent' do
    page.all('td').collect {|tag| tag.text}.join('; ').should ==  
      "#{l Date.today}; #{@w.id}; 001; le libellé; une dépense; destinée; 10,00; -; CB; Compte courant;  "
  end
  
end
