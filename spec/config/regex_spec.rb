# coding: utf-8

require 'spec_helper'


describe 'caractères autorisés' do

  it 'une écriture avec des accents est valide' do
    subject.should =~ NAME_REGEX 
  end

  describe 'débute par' do

    it '1 chiffre' do
      '1chiffre'.should =~ NAME_REGEX
    end

    it 'une lettre' do
      'une lettre'.should =~ NAME_REGEX
    end

    it 'é ou autre caractère accentué' do
      'é ou autre caractère accentué'.should =~ NAME_REGEX
    end

    it '?mais pas par un caractère spécial' do
      '?mais pas par un caractère spécial'.should_not =~ NAME_REGEX
    end
  end

  describe 'se termine par' do

    it 'les terminaisons autorisées' do
      ('a'..'z').each do |car|
        "une chaîne#{car}".should match NAME_REGEX
      end

      ('A'..'Z').each do |car|
        "une chaîne#{car}".should match NAME_REGEX
      end

      "une chaîne.".should match NAME_REGEX
      "une chaîne)".should match NAME_REGEX
      "une chaîne?".should match NAME_REGEX
    end

    it 'les terminaisons interdites' do
      "une chaîne ,".should_not match NAME_REGEX
    end


  end

  describe 'au milieu sont également autorisés' do

    it 'certains caractères spéciaux' do
      speciaux = %w(& _ - , ' . /)
      speciaux.each do |car|
        "une chaîne #{car} avec un caractère spécial".should match NAME_REGEX
      end
    end

    it 'mais pas certains autres' do
      speciaux = %w(\\ < >)
      speciaux.each do |car|
        "une chaîne #{car} avec un caractère spécial".should_not match NAME_REGEX
      end
    end

  end



end
