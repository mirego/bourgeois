require 'bourgeois/version'

require 'active_support'
require 'active_model'
require 'action_view'

require 'bourgeois/errors'
require 'bourgeois/presenter'
require 'bourgeois/view_helper'

module Bourgeois
  def self.inject_into_action_view
    @inject_into_action_view ||= Proc.new do
      ActionView::Base.send(:include, ViewHelper)
    end
  end
end

require 'bourgeois/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3
