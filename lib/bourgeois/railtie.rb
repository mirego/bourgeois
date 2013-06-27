require 'bourgeois'
require 'rails'

module Bourgeois
  class Railtie < Rails::Railtie
    initializer 'bourgeois.action_view' do |app|
      ActiveSupport.on_load :action_view do
        ActionView::Base.send(:include, ViewHelper)
      end
    end
  end
end
