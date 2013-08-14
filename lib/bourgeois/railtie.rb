require 'bourgeois'
require 'rails'

module Bourgeois
  class Railtie < Rails::Railtie
    initializer 'bourgeois.action_view' do |app|
      ActiveSupport.on_load :action_view, {}, &Bourgeois.inject_into_action_view
    end
  end
end
