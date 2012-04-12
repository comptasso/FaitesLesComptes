# coding: utf-8

module JcCapybara

 def page
    Capybara::Node::Simple.new(rendered)
  end


end
