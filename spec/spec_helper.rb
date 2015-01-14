$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'ostruct'
require 'rspec'
require 'bourgeois'

# Inject our helper into ActionView
ActionView::Base.class_eval(&Bourgeois.inject_into_action_view)

RSpec.configure do |config|
  # Disable `should` syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
