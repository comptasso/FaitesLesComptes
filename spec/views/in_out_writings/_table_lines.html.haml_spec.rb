# coding: utf-8

describe "in_out_writings/_table_lines" do 
  include JcCapybara
  
  def mock_writing_line(montant)
    double(Request::Frontline,
      :ref=>'001',
      :date=>Date.today,
      :narration=>'le libellé',
      :nature_name=>'une dépense',
      :destination_name=>'destinée',
      :debit=>montant,
      :credit=>0,
      :id=>156,
      :payment_mode=>'CB',
      compta_line_id:457,
      acc_title:'Compte courant', 
      writing_type:'InOutWriting',
      'editable?'=>false)
  end

  before(:each) do
    assign(:monthly_extract, double(Object, frontlines:[mock_writing_line(10)]) )
    render
  end
  
  it 'la vue comprend 11 éléments td' do
    page.all('td').should have(11).elements
  end
  
  it 'qui donnent' do
    page.all('td').collect {|tag| tag.text}.join('; ').should ==  
      "#{l Date.today}; 156; 001; le libellé; une dépense; destinée; 10,00; -; CB; Compte courant;  "
  end
  
end
