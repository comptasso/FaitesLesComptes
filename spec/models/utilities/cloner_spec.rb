# coding: utf-8

require 'spec_helper'

describe Utilities::Cloner do
  include OrganismFixtureBis

  before(:each) do
    Tenant.set_current_tenant(1)
    use_test_organism
  end

before(:each) do
  @cl = Utilities::Cloner.new(old_org_id:@o.id)
end

after(:each) do
  Organism.find_by_sql('DELETE FROM flccloner;')
  Organism.where('comment = ?', 'testclone').each {|o| o.destroy}
end

it 'clone_organism crée un nouvel organisme' do
  expect {@cl.clone_organism("aujourd'hui")}.to change{Organism.count}.by(1)
end

it 'clone copie les secteurs' do
  expect {@cl.clone_organism('testclone')}.
    to change{Sector.count}.by(@o.sectors.count)
end

context 'vérification du clone' do

  before(:each) do
   @cl.clone_organism('testclone')
   @norg = Organism.where('comment = ?', 'testclone').first
  end

it 'cet organisme a le même tenant' do
  expect( @norg.tenant_id).to eq(@o.tenant_id)
end

it 'les secteurs sont identiques' do
  champs_identiques = Sector.column_names.reject {|f| f == 'id' || f == 'organism_id'}
  @norg.sectors.each do |s|
    oldsect = @o.sectors.where('name = ?', s.name).first
    champs_identiques.each do |champ|
      expect(s.send(champ)).to eq oldsect.send(champ)
    end
  end
end

it 'les natures sont identiques pour les champs conservés' do
  expect(@o.natures.count).to eq(@norg.natures(true).count)
  champs_identiques = Nature.column_names.reject do |f|
    f == 'id' || f == 'book_id' || f == 'period_id' || f == 'account_id'
  end
  @norg.in_out_books.each do |b|
    oldbook = @o.books.where('title = ?', b.title).first

  b.natures.each do |r|
    oldnat = oldbook.natures.where('name = ?', r.name).first
    champs_identiques.each do |champ|
      expect(r.send(champ)).to eq oldnat.send(champ)
    end
  end
  end
end

it 'la banque et le compte de la banque sont disponibles' do
  nba = @norg.bank_accounts.first
  np = @norg.periods.first
  expect(nba.number).to eq(@ba.number)
  expect(nba.current_account(np)).to eq @baca
end

it 'la caisse et le compte de la caisse sont disponibles' do
  nca = @norg.cashes.first
  np = @norg.periods.first
  puts np.inspect
  puts nca.current_account(np).inspect
  expect(nca.name).to eq @c.name
  expect(nca.current_account(np)).to eq @caca
end

it 'toutes les données sont recopiées à l identique'

it 'les références sont conservées'

end

end
