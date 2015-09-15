# coding: utf-8

require 'spec_helper'

describe Utilities::Transformer do

  it 'sait créeer les fonctions de transformations' do
    expect {Utilities::Transformer.create_transformer_functions}.not_to raise_error
  end

end
