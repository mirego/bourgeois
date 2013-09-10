$:.unshift File.expand_path('../../lib', __FILE__)

require 'coveralls'
Coveralls.wear!

require 'ostruct'
require 'rspec'
require 'bourgeois'

# Inject our helper into ActionView
ActionView::Base.class_eval(&Bourgeois.inject_into_action_view)
