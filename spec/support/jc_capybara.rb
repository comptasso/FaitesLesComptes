# coding: utf-8

module JcCapybara

 def page
    Capybara::Node::Simple.new(rendered)
 end

 def content(part)
   Capybara::Node::Simple.new(view.content_for(part))
 end
 
 def within(selector)
  yield rendered.find(selector)
 end





end